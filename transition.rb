class Transition
	attr_accessor :probability, :to, :time
	def initialize(to, probability, time)
		@to = to
		@probability = probability
		@time = time
	end
end

