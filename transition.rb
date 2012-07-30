class Transition
	attr_accessor :probability, :from, :to
	def initialize(from, to, probability)
		@from = from
		@to = to
		@probability = probability
	end
end

