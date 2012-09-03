require 'sqlite3'
require_relative 'spree_repository'
require_relative 'behavior_generator'
require 'uuid'

db = SQLite3::Database.new( "/.datastore/dev.sqlite3" )

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
      behavior_generator.search_for_product({:id => product[0]})
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

db.execute("delete from spree_user_behaviors")
generate_random_search_behavior_for_users(repository, uuid_generator, 30)
generate_substitution_behavior_for_users(repository, uuid_generator)
generate_purchase_behavior_for_purchased_product(repository, uuid_generator)

