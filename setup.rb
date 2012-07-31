require './state.rb'
require './transition.rb'
require './machine.rb'
require './event_listener.rb'

def run
	need = State.new("Need")
	no_need = State.new("No Need")
	view_advertisement = State.new("View advertisement")
	browse_products = State.new("Browse products")
	purchase_products = Purchase.new("Purchase product")

	need.add_transition(Transition.new(browse_products, 0.4, 0.2))
	need.add_transition(Transition.new(purchase_products, 0.4, 0.2))
	need.add_transition(Transition.new(need, 0.2, 0.2))

	no_need.add_transition(Transition.new(no_need, 0.2, 0.2))
	no_need.add_transition(Transition.new(browse_products, 0.2, 0.2))
	no_need.add_transition(Transition.new(view_advertisement, 0.6, 0.2))

	browse_products.add_transition(Transition.new(purchase_products, 0.2, 0.2))
	browse_products.add_transition(Transition.new(browse_products, 0.8, 0.2))

	view_advertisement.add_transition(Transition.new(browse_products, 0.5, 0.2))
	view_advertisement.add_transition(Transition.new(purchase_products, 0.2, 0.2))
	view_advertisement.add_transition(Transition.new(no_need, 0.3, 0.2))

	purchase_products.add_transition(Transition.new(no_need, 0.6, 0.2))
	purchase_products.add_transition(Transition.new(browse_products, 0.4, 0.2))

	listener = EventListener.new
	m = Machine.new(no_need, listener)
	(0..100).each do |i|
		s = m.next_state
	end
end

run
#Thread.new {
#	
#}

