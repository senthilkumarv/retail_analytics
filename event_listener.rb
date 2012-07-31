class EventListener
	def initialize
		@sales = Array.new(900, 0)
	end

	def purchase_was_made(time)
		puts "Purchase was made at [#{time.ceil}]"
		@sales[time.ceil] = @sales[time.ceil] + 1
	end
end

