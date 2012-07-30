class Machine
	def initialize(initial_state)
		@current = initial_state
	end
	
	def next
		@current = @current.next
		@current
	end
end

