require './state.rb'
require './transition.rb'
require './machine.rb'
require './event_listener.rb'
require './profile.rb'

def run
	p = Profile.new
	listener = EventListener.new
	m = Machine.new(p.initial_state, listener)
	(0..100).each do |i|
		s = m.next_state
	end
end

run
#Thread.new {
#	
#}

