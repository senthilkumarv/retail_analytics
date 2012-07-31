class Machine
	def initialize(initial_state, listener)
		@time_step = 0.0
		@current = initial_state
		@listener = listener
	end
	
	def next_state
		x = @current.next_state
		@current = x[:state]
		@time_step += x[:time]
		@current.execute(@listener, @time_step)
		x
	end
end

