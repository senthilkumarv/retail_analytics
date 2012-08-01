class Machine
	def initialize(initial_state, listener, id)
		@time_step = 0.0
		@current = initial_state
		@listener = listener
		@id = id
	end
	
	def next_state
		x = @current.next_state
		@current = x[:state]
		@time_step += x[:time]
		@current.execute
		@listener.log(@current, @time_step, @id)
		x
	end
end

