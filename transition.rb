class Transition
	attr_accessor :probability, :to
	def initialize(to, probability)
		@to = to
		@probability = probability
	end
end

