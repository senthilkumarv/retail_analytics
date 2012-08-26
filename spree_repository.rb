class SpreeRepository
  def initialize(connection)
    @connection = connection
  end
  def create_search(options)
    @connection.execute("insert into spree_user_behaviors(Session_ID, User_ID, action, created_at, parameters) values(?, ?, ?, datetime(), ?)", options[:session], options[:user], "S", "{'product': #{options[:product]}}")
  end

  def add_to_cart(options)
    @connection.execute("insert into spree_user_behaviors(Session_ID, User_ID, action, created_at, parameters) values(?, ?, ?, datetime(), ?)", options[:session], options[:user], "AC", "{'product': #{options[:prodcut]}, 'availability': #{options[:availability]}, 'quantity': #{options[:quantity]}}")
  end

  def delete_from_cart(options)
    @connection.execute("insert into spree_user_behaviors(Session_ID, User_ID, action, created_at, parameters) values(?, ?, ?, datetime(), ?)", options[:session], options[:user], "DC", "{'product': #{options[:product]}, 'quantity': #{options[:quantity]}}")
  end

  def make_payment(options)
    @connection.execute("insert into spree_user_behaviors(Session_ID, User_ID, action, created_at, parameters) values(?, ?, ?, datetime(), ?)", options[:session], options[:user], "P", "{'order': #{options[:order]}}")
  end

  def products_bought_in_transaction(order)
    @connection.execute("select variant_id, quantity from spree_line_items where order_id=?", order);
  end

  def random_customers(count)
    @connection.execute("SELECT id FROM spree_users ORDER BY RANDOM() LIMIT #{count}")
  end

  def orders
    db.execute("select id, user_id from spree_orders")
  end
end
