require './state.rb'

class EventListener
	def initialize
		@sales = Array.new(900, 0)
		@events = {}
	end

	def log(event, time_step, customer_id)
		@events[customer_id] = [] if @events[customer_id].nil?
		@events[customer_id] << {:event => event, :time => time_step}
	end
	
	def purchases
		purchase_events = []
#		puts "Purchase was made at [#{time.ceil}]"
		@events.values.each do |evs|
			purchase_events = purchase_events.concat(evs.select {|v| v[:event].instance_of?Purchase})
		end
		purchases = Array.new(200, 0)
		purchase_events.each {|p| purchases[p[:time].ceil] = purchases[p[:time].ceil] + 1}
		purchases
	end
end

