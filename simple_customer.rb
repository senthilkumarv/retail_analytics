require 'set'
require 'date'

class Distribution
	def initialize(table)
		@table = table
	end
end

class Customer
	def initialize(id)
		@id = id
	end
end

customer_frequency_distribution = {1..1 => 0.4, 2..3 => 0.2, 4..5 => 0.1, 6..10 => 0.2}
order_value_frequency_distribution = {1..500 => 0.4, 500..2000 => 0.3, 2000..4000 => 0.2, 4000..10000 => 0.1}
recency_frequency_distribution = { 0..7 => 0.3, 8..30 => 0.5, 31..80 => 0.2}

num_customers = 100

ids = Set.new((1..num_customers).to_a)
transactions = []

customer_frequency_distribution.each_pair do |k,v|
	frequency = (v * num_customers).to_i
	frequency.times do |f|
		num_transactions = (rand(k.end - k.begin) + k.begin).to_i
		as_array = ids.to_a
		customer_index = as_array[rand(as_array.length).to_i]
		num_transactions.times do |i|
			transactions << {:id => customer_index}
		end
		ids.delete(customer_index)
	end
end

ids = Set.new((1..num_customers).to_a)
order_value_frequency_distribution.each_pair do |k,v|
	frequency = (v * num_customers).to_i
	puts frequency
	frequency.times do |f|
		as_array = ids.to_a
		customer_index = as_array[rand(as_array.length).to_i]
		selected = transactions.select {|t| t[:id] == customer_index}
		selected.each do |t|
			t[:value] = (rand(k.end - k.begin) + k.begin).to_i
		end
		ids.delete(customer_index)
	end
end

start = Date.new(2001, 1, 1)
stop = Date.new(2001, 4, 1)

transactions.each do |t|
	t[:date] = start + rand((stop - start).to_i)
end

ids = Set.new((1..num_customers).to_a)
recency_frequency_distribution.each_pair do |k,v|
	frequency = (v * num_customers).to_i
	frequency.times do |f|
		as_array = ids.to_a
		customer_index = as_array[rand(as_array.length).to_i]
		selected = transactions.select {|t| t[:id] == customer_index}
		
		selected.each do |t|
			
			next if (stop - t[:date] >= k.begin && stop - t[:date] <= k.end)
			t[:date] = stop - (k.begin + k.end).to_i/2 + rand(2)
		end
		ids.delete(customer_index)
	end
end

handle = File.open("op.csv", "w")
handle.puts("CustomerID, OrderValue, Date")
transactions.each do |t|
	handle.puts("#{t[:id]}, #{t[:value]}, #{t[:date]}")
end

handle.close


#ts = transactions.select {|t| t[:id] == 2}
#sum = 0
#ts.each do |t|
#	puts t
#	sum += t[:value]
#end
#puts sum/ts.length
##puts transactions.inspect

