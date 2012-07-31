class Machine
	def initialize(initial_state)
		@current = initial_state
	end
	
	def next_state
		@current = @current.next_state
		@current
	end
end

