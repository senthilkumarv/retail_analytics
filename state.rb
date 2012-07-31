require 'set'

class State
	def initialize(description)
		@transitions = []
		@description = description
	end
	
	def add_transition(transition)
		@transitions << transition
	end

	def next_state
		sum = 0
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
			sum += transition_tables[transition].count
		end
		
		selected = rand(100) + 1
#		puts transition_tables.inspect
		index = transition_tables.keys.index {|transition| transition_tables[transition].include?(selected)}
#		puts "Number of numbers in all sets=#{sum}, searching for #{selected}"
		{ :state => transition_tables.keys[index].to, :time => transition_tables.keys[index].time }
	end

	def to_s
		@description
	end
	
	def execute(listener, time_step)
	end
end

class Purchase < State
	def initialize(description)
		super(description)
	end
	
	def execute(listener, time_step)
		listener.purchase_was_made(time_step)
	end
end

