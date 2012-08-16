require 'rubygems'
require 'gruff'
require 'set'
require 'date'
require 'sqlite3'

def by_description(name, db)
	row = db.get_first_row("select * from spree_products where name='#{name}'")
	product = {:id => row[0], :name => row[1]}
	variant = db.get_first_row("select id, price from spree_variants where product_id=#{product[:id]} and is_master='t'")
	product[:name] = name
	product[:variant_id] = variant[0]
	product[:price] = variant[1]
	product
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

products = [phone, sdcard, s3, linen_kurta, red_kurta, bracelet, watch, tikkis, kitchen_set, biography, ring]

db_orders = db.execute("select total, user_id, created_at, id from spree_orders")
orders = db_orders.map {|o| {:user_id => o[1], :order_value => o[0], :date => o[2], :id => o[3]}}

orders.each do |o|
	line_items = db.execute("select variant_id, quantity from spree_line_items where order_id = #{o[:id]}")
	o[:basket] = line_items.map {|line_item| { :product => products.select {|p| p[:variant_id] == line_item[0]}[0], :quantity => line_item[1]}}
end

db_users = db.execute("select id from spree_users")
users = db_users.map {|u| {:user_id => u[0]}}

num_users = 100
users = users[0..(num_users - 1)]

customer_frequency_distribution = {1..1 => 0, 2..3 => 0, 4..5 => 0, 6..10 => 0}
customer_frequencywise_transaction_buckets = {1..1 => [], 2..3 => [], 4..5 => [], 6..10 => []}
customer_frequencywise_product_distribution = {1..1 => {}, 2..3 => {}, 4..5 => {}, 6..10 => {}}

order_value_frequency_distribution = {1..500 => 0, 
				      501..2000 => 0, 
				      2001..4000 => 0, 
				      4001..10000 => 0
				     }
order_valuewise_transaction_buckets = {1..500 => [], 
				      501..2000 => [], 
				      2001..4000 => [], 
				      4001..10000 => []
				     }
order_valuewise_product_distribution = {1..500 => {}, 
				      501..2000 => {}, 
				      2001..4000 => {}, 
				      4001..10000 => {}
				     }

recency_frequency_distribution = { 0..7 => 0, 8..30 => 0, 31..80 => 0}


transactions = users.map {|u| {:user_id => u[:user_id], :transactions => orders.select {|o| o[:user_id] == u[:user_id]}}}

transactions.each do |tc|
	customer_frequency_distribution.keys.each do |bucket|
		count = tc[:transactions].length
		if count >= bucket.begin && count <= bucket.end
			customer_frequency_distribution[bucket] = customer_frequency_distribution[bucket] + 1
			customer_frequencywise_transaction_buckets[bucket] = customer_frequencywise_transaction_buckets[bucket] + tc[:transactions]
		end
	end
end

customer_frequencywise_transaction_buckets.keys.each do |r|
	customer_frequencywise_transaction_buckets[r].each do |tx|
		tx[:basket].each do |mix|
			customer_frequencywise_product_distribution[r][mix[:product]] = 0 if customer_frequencywise_product_distribution[r][mix[:product]].nil?
			customer_frequencywise_product_distribution[r][mix[:product]] = customer_frequencywise_product_distribution[r][mix[:product]] + 1
		end
	end
end

customer_frequencywise_product_distribution.each_pair do |range, distribution|
	g = Gruff::Pie.new
	g.title = "product_distribution_transaction_frequency"
	distribution.each_pair do |k,v|
		g.data(k[:name], v)
	end
	g.write("product_distribution_transaction_frequency#{range.to_s}.png")
end

puts customer_frequency_distribution.inspect

sorted_ranges = customer_frequency_distribution.keys.sort {|r1, r2| (r1.begin + r1.end)/2 <=> (r2.begin + r2.end)/2}

sorted_values = sorted_ranges.map {|r| customer_frequency_distribution[r]}
index = 0
labels = {}
sorted_ranges.each do |r|
	labels[index] = r.to_s
	index += 1
end

g = Gruff::Bar.new
g.title = "Transaction Frequency" 
g.data("Customers", sorted_values)
g.labels = labels
g.write('transaction_frequency.png')

def average(orders)
	sum = 0
	orders.each {|o| sum += o[:order_value]}
	orders.length == 0 ? 0 : sum/orders.length
end

order_values_by_user = users.map {|u| {:user_id => u[:user_id], :average_order_value => average(orders.select {|o| o[:user_id] == u[:user_id]}), :transactions => orders.select {|o| o[:user_id] == u[:user_id]}}}
order_values_by_user.each do |ov|
	order_value_frequency_distribution.keys.each do |ovr|
		value = ov[:average_order_value]
		if value >= ovr.begin && value <= ovr.end
			order_value_frequency_distribution[ovr] = order_value_frequency_distribution[ovr] + 1
			order_valuewise_transaction_buckets[ovr] = order_valuewise_transaction_buckets[ovr] + ov[:transactions]
		end
	end
end

order_valuewise_transaction_buckets.keys.each do |r|
	order_valuewise_transaction_buckets[r].each do |tx|
		tx[:basket].each do |mix|
			order_valuewise_product_distribution[r][mix[:product]] = 0 if order_valuewise_product_distribution[r][mix[:product]].nil?
			order_valuewise_product_distribution[r][mix[:product]] = order_valuewise_product_distribution[r][mix[:product]] + 1
		end
	end
end

order_valuewise_product_distribution.each_pair do |range, distribution|
	g = Gruff::Pie.new
	g.title = "product_distribution_order_value"
	distribution.each_pair do |k,v|
		g.data(k[:name], v)
	end
	g.write("product_distribution_order_value#{range.to_s}.png")
end

puts order_value_frequency_distribution.inspect

sorted_ranges = order_value_frequency_distribution.keys.sort {|r1, r2| (r1.begin + r1.end)/2 <=> (r2.begin + r2.end)/2}

sorted_values = sorted_ranges.map {|r| order_value_frequency_distribution[r]}
index = 0
labels = {}
sorted_ranges.each do |r|
	labels[index] = r.to_s
	index += 1
end

g = Gruff::Bar.new
g.title = "Order Value Distribution" 
g.data("Customers", sorted_values)
g.labels = labels
g.write('order_value_distribution.png')

start = Date.new(2001, 1, 1)
stop = Date.new(2001, 4, 1)

order_dates_by_user = users.map {|u| {:user_id => u[:user_id], :order_dates => orders.select {|o| o[:user_id] == u[:user_id]}.map {|o| Date.parse(o[:date])}}}
order_dates_by_user.each do |od|
	latest = od[:order_dates].sort[-1]
	earliest = od[:order_dates].sort[0]
	if latest.nil?
		od[:latest] = od[:earliest] = 9000
		next
	end
	od[:latest] = (stop - latest).to_i
	od[:earliest] = (stop - earliest).to_i
end

order_dates_by_user.each do |od|
	recency_frequency_distribution.keys.each do |recency|
		recency_frequency_distribution[recency] = recency_frequency_distribution[recency] + 1 if od[:earliest] >= recency.begin && od[:latest] <= recency.end
	end
end

puts recency_frequency_distribution.inspect

sorted_ranges = recency_frequency_distribution.keys.sort {|r1, r2| (r1.begin + r1.end)/2 <=> (r2.begin + r2.end)/2}

sorted_values = sorted_ranges.map {|r| recency_frequency_distribution[r]}
index = 0
labels = {}
sorted_ranges.each do |r|
	labels[index] = r.to_s
	index += 1
end

g = Gruff::Bar.new
g.title = "Order Recency Distribution" 
g.data("Customers", sorted_values)
g.labels = labels
g.write('order_recency_distribution.png')

