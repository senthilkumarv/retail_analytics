class State
	def initialize
		@transitions = []
	end
	
	def add_transition(transition)
		@transitions << transition
	end
end


