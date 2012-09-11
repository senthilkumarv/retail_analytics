class Transition
	attr_accessor :to
	def initialize(to, probability)
		@to = to
		@probability = probability
	end
	
	def probability(state)
		@probability
	end
end

class VariableTransition
	attr_accessor :to
	def initialize(to)
		@to = to
	end

	def probability(state)
		x = state.customer_inventory.current_level
		Math.exp(-x)/(1 + Math.exp(-x))
	end
end

