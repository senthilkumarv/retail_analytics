require 'set'

class CustomerStocks
	attr_accessor :current_level

	def initialize(initial_amount)
		@current_level = initial_amount
	end
	
	def replenish(amount)
		@current_level += amount
	end
	
	def consume(amount)
		@current_level -= amount
	end
end

class State
	attr_accessor :customer_inventory
	def initialize(description, time, customer_inventory, block = (state) -> {})
		@transitions = []
		@description = description
		@time = time
		@customer_inventory = customer_inventory
		@block = block
	end
	
	def add_transition(transition)
		@transitions << transition
	end

	def next_state
		s = Set.new((1..100).to_a)
		transition_tables = {}
		@transitions.each do |transition|
			transition_tables[transition] = Set.new
			times = transition.probability * 100
			times.to_i.times do |t|
				a = s.to_a
				candidate = a[rand(a.length)]
				transition_tables[transition] << candidate
				s.delete(candidate)
			end
		end
		
		selected = rand(100) + 1
		index = transition_tables.keys.index {|transition| transition_tables[transition].include?(selected)}
		transition = transition_tables.keys[index]
		
		{ :state => transition.to, :time => @time }
	end

	def to_s
		@description
	end
	
	def execute
		block.call(self)
	end
end

class Purchase < State
	def initialize(description, time)
		super(description, time)
	end
end

