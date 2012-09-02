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
    @connection.execute("select variant_id, quantity from spree_line_items where order_id=?", order)
  end

  def random_customers(count)
    @connection.execute("SELECT id FROM spree_users ORDER BY RANDOM() LIMIT #{count}")
  end

  def select_random_product_variant
    @connection.execute("SELECT id FROM spree_variants ORDER BY RANDOM() LIMIT 1")
  end

  def orders
    @connection.execute("select id, user_id from spree_orders")
  end

  def customers_who_bought_variants_of_a_product(number)
    @connection.execute("select li.order_id, o.user_id, li.variant_id, li.quantity from spree_line_items li, spree_orders o where li.order_id = o.id and variant_id in (select id from spree_variants where product_id in (select product_id from spree_variants group by product_id having count(*) > 1)) order by RANDOM() limit #{number}")
  end
  
  def session_id_for_order(order)
    @connection.execute("select session_id from spree_user_behaviors where parameters like '%#{order}%' limit 1")
  end
end
