require 'rubygems'
require 'sqlite3'
require './spree_repository'
require './behavior_generator'
require 'uuid'
require 'json'

db = SQLite3::Database.new( "dev.sqlite3" )

repository = SpreeRepository.new db
uuid_generator = UUID.new

def generate_purchase_behavior_for_purchased_product(repository, uuid_generator)
  purchases = []
  repository.orders.each { |order| 
    purchases << {:order => order[0], :user => order[1], :items => repository.products_bought_in_transaction(order[0])}
  }

  purchases.each { |purchase|
    session = repository.session_id_for_substitution(purchase[:user])
    session = uuid_generator.generate unless session.any?
    purchase[:session] = session
    generator = BehaviorGenerator.new(repository, purchase)
    generator.make_purchase_of_searched_product
  }
end

def generate_random_search_behavior_for_users(repository, uuid_generator, no_of_customers)
  customers = repository.random_customers no_of_customers
  customers.each { |customer|
    no_of_search = Random.rand(1..10)
    no_of_search.times { 
      product = repository.select_random_product_variant
      order = {:session => uuid_generator.generate, :user => customer[0]}
      behavior_generator = BehaviorGenerator.new(repository, order)
      behavior_generator.search_for_product({:id => product[0][0]})
    }
  }
end

def generate_substitution_behavior_for_users(repository, uuid_generator)
  customers = repository.customers_who_bought_variants_of_a_product 10
  customers.each { |customer|
    variant = repository.variant_of_a_product(customer[2])
    order = {:session => uuid_generator.generate, :order => customer[0], :user => customer[1], :id => variant[0][0], :quantity => customer[3]}
    behavior_generator = BehaviorGenerator.new(repository, order)
    behavior_generator.search_for_unavailable_product_and_add_to_cart(order)
  }

end

def aggregate_product_views(repository)  
  results = repository.group_by_product_views  
  results.each { |row| 
    variant  = JSON.parse(row[0])["product"]
    repository.add_to_product_views(variant,row[1])
  }
end

def find_people_who_searched_and_bought_same_category(repository)
  behavior = repository.product_searched_and_bought
  valid_substitutions = []
  behavior.each { |b|
    searched_category = repository.category_for_a_variant(b[1])[0][0]
    bought_category = repository.category_for_a_variant(b[2])[0][0]
    valid_substitutions << {:searched => b[1], :bought => b[2], :session => b[0]} if(searched_category == bought_category)  
  }
  valid_substitutions
  repository.persist_substitution_behavior(valid_substitutions)
end

db.execute("delete from product_views")
db.execute("delete from spree_user_behaviors")
generate_random_search_behavior_for_users(repository, uuid_generator, 30)
generate_substitution_behavior_for_users(repository, uuid_generator)
generate_purchase_behavior_for_purchased_product(repository, uuid_generator)
aggregate_product_views(repository)
find_people_who_searched_and_bought_same_category(repository)
