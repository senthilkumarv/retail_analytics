require 'set'
require 'date'
require 'sqlite3'

def p(product, quantity)
	{:product => product, :quantity => quantity}
end

def by_description(name, db)
	row = db.get_first_row("select * from spree_products where name='#{name}'")
	product = {:id => row[0], :name => row[1]}
	variant = db.get_first_row("select id, price from spree_variants where product_id=#{product[:id]} and is_master='t'")
	product[:variant_id] = variant[0]
	product[:price] = variant[1]
	product
end

def users(db)
	row = db.execute("select id from spree_users").map {|c| c[0]}
end

def value(basket)
	sum = 0
	basket.each {|i| sum += i[:product][:price]}
	sum
end

db = SQLite3::Database.new( "/home/avishek/Code/mystore/db/development.sqlite3" )

phone = by_description("Zen Full Touch Dual Sim Phone - M28", db)
sdcard = by_description("Sandisk 32 GB Micro SD Ultra Card (Class 10)", db)
s3 = by_description("Samsung Galaxy S3 i9300 Mobile Phone - 16GB", db)
linen_kurta = by_description("Fab India Linen Kurta", db)
red_kurta = by_description("Fab India Red Kurta", db)
bracelet = by_description("Multicoloured Bracelet", db)
watch = by_description("Croco Pattern Leather Strap Watch", db)
tikkis = by_description("Kebabs & Tikkis - Tarla Dalal", db)
kitchen_set = by_description("Kitchen Linen Set", db)
biography = by_description("Steve Jobs: The Exclusive Biography", db)
ring = by_description("Ring", db)

customers = users(db)
customer_frequency_distribution = {1..1 => 0.4, 2..3 => 0.2, 4..5 => 0.1, 6..10 => 0.2}
order_value_frequency_distribution = {1..500 => { :fraction_customers =>0.4, :basket_mix => [[p(ring,1)], [p(bracelet,1)], [p(ring,1), p(bracelet,1)]]}, 
				      501..2000 => { :fraction_customers =>0.3, :basket_mix => [[p(kitchen_set,1)], [p(tikkis,1)], [p(biography,1), p(ring, 1)]]}, 
				      2001..4000 => { :fraction_customers =>0.2, :basket_mix => [[p(sdcard,1), p(biography,1)], [p(watch,1), p(kitchen_set,1)], [p(linen_kurta,1), p(bracelet,1)]]}, 
				      4001..10000 => { :fraction_customers =>0.1, :basket_mix => [[p(linen_kurta,1), p(bracelet,1), p(watch,1)], [p(red_kurta,1), p(ring,1)], [p(s3, 1)]]}}
recency_frequency_distribution = { 0..7 => 0.3, 8..30 => 0.5, 31..80 => 0.2}

num_customers = 100
customers = customers[0..(num_customers - 1)]

ids = Set.new(customers)
transactions = []

transaction_number = 0
customer_frequency_distribution.each_pair do |k,v|
	frequency = (v * num_customers).to_i
	frequency.times do |f|
		num_transactions = (rand(k.end - k.begin) + k.begin).to_i
		as_array = ids.to_a
		customer_index = as_array[rand(as_array.length).to_i]
		num_transactions.times do |i|
			transactions << {:id => customer_index, :transaction_id => transaction_number}
			transaction_number += 1
		end
		ids.delete(customer_index)
	end
end

ids = Set.new(customers)
order_value_frequency_distribution.each_pair do |k,v|
	frequency = (v[:fraction_customers] * num_customers).to_i
	frequency.times do |f|
		as_array = ids.to_a
		customer_index = as_array[rand(as_array.length).to_i]
		selected = transactions.select {|t| t[:id] == customer_index}
		selected.each do |t|
			t[:basket] = v[:basket_mix][rand(v[:basket_mix].length)]
			t[:value] = value(t[:basket])
		end
		ids.delete(customer_index)
	end
end


start = Date.new(2001, 1, 1)
stop = Date.new(2001, 4, 1)

transactions.each do |t|
	t[:date] = start + rand((stop - start).to_i)
end

ids = Set.new(customers)
recency_frequency_distribution.each_pair do |k,v|
	frequency = (v * num_customers).to_i
	frequency.times do |f|
		as_array = ids.to_a
		customer_index = as_array[rand(as_array.length).to_i]
		selected = transactions.select {|t| t[:id] == customer_index}
		
		selected.each do |t|
			next if (stop - t[:date] >= k.begin && stop - t[:date] <= k.end)
			t[:date] = stop - (k.begin + k.end).to_i/2 + rand(4) - 2
		end
		ids.delete(customer_index)
	end
end

handle = File.open("op.csv", "w")
handle.puts("CustomerID, OrderValue, Date, TransactionID, ProductID, Quantity")

db.execute( "delete from spree_orders")
db.execute( "delete from spree_line_items")
transactions.each do |t|
	db.execute( "insert into spree_orders (id, item_total, total, user_id, payment_total, created_at, updated_at, state) values (?, ?, ?, ?, ?, ?, ?, ?)", t[:transaction_id], t[:value], t[:value], t[:id], t[:value], t[:date].to_s, t[:date].to_s, "complete")
end

transactions.each do |t|
	t[:basket].each do |mix|
	db.execute( "insert into spree_line_items (order_id, variant_id, quantity, price, created_at, updated_at) values (?, ?, ?, ?, ?, ?)", t[:transaction_id], mix[:product][:variant_id], mix[:quantity], mix[:product][:price], t[:date].to_s, t[:date].to_s)
		handle.puts("#{t[:transaction_id]}, #{t[:value]/t[:basket].length}, #{t[:date]}, #{t[:transaction_id]}, #{mix[:product][:id]}, #{mix[:quantity]}")
	end
end

handle.close

