require './state.rb'
require './transition.rb'
require './machine.rb'
require './event_listener.rb'
require './profile.rb'

def run(profile, listener, machine_id)
	m = Machine.new(profile.initial_state, listener, machine_id)
	(0..100).each do |i|
		s = m.next_state
	end
end

listener = EventListener.new
200.times do |x|
	puts "Running for customer ##{x}"
	run(Profile.new, listener, x)
end

puts listener.purchases.inspect
