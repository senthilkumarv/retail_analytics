require 'rubygems'
require 'gruff'
require 'set'
require 'date'
require 'sqlite3'

db = SQLite3::Database.new( "/home/avishek/Code/mystore/db/development.sqlite3" )

db_orders = db.execute("select total, user_id, created_at from spree_orders")
orders = db_orders.map {|o| {:user_id => o[1], :order_value => o[0], :date => o[2]}}

db_users = db.execute("select id from spree_users")
users = db_users.map {|u| {:user_id => u[0]}}

num_users = 100
users = users[0..(num_users - 1)]

customer_frequency_distribution = {1..1 => 0, 2..3 => 0, 4..5 => 0, 6..10 => 0}
order_value_frequency_distribution = {1..500 => 0, 
				      501..2000 => 0, 
				      2001..4000 => 0, 
				      4001..10000 => 0
				     }
recency_frequency_distribution = { 0..7 => 0, 8..30 => 0, 31..80 => 0}

transaction_counts = users.map {|u| {:user_id => u[:user_id], :transaction_count => orders.select {|o| o[:user_id] == u[:user_id]}.length}}

transaction_counts.each do |tc|
	customer_frequency_distribution.keys.each do |bucket|
		count = tc[:transaction_count]
		customer_frequency_distribution[bucket] = customer_frequency_distribution[bucket] + 1 if count >= bucket.begin && count <= bucket.end
	end
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
g.title = "My Graph" 
g.data("Data", sorted_values)
g.labels = labels
g.write('my_fruity_graph.png')

def average(orders)
	sum = 0
	orders.each {|o| sum += o[:order_value]}
	orders.length == 0 ? 0 : sum/orders.length
end

order_values_by_user = users.map {|u| {:user_id => u[:user_id], :average_order_value => average(orders.select {|o| o[:user_id] == u[:user_id]})}}
order_values_by_user.each do |ov|
	order_value_frequency_distribution.keys.each do |ovr|
		value = ov[:average_order_value]
		order_value_frequency_distribution[ovr] = order_value_frequency_distribution[ovr] + 1 if value >= ovr.begin && value <= ovr.end
	end
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
g.title = "My Graph" 
g.data("Data", sorted_values)
g.labels = labels
g.write('my_fruity_graph2.png')

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
g.title = "My Graph" 
g.data("Data", sorted_values)
g.labels = labels
g.write('my_fruity_graph3.png')

