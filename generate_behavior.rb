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
    purchase[:session] = uuid_generator.generate
    generator = BehaviorGenerator.new(repository, purchase)
    generator.make_purchase_of_searched_product
  }
end

def generate_random_search_behavior_for_users(repository, uuid_generator, orders)
  customers = repository.random_customers 30
  
end
#products = db.execute("select id from spree_products").map {|p| p[0]}
#users = db.execute("select id from spree_users").map {|u| u[0]}
