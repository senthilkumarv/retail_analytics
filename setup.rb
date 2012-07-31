require './state.rb'
require './transition.rb'
require './machine.rb'

need = State.new("Need")
no_need = State.new("No Need")
view_advertisement = State.new("View advertisement")
browse_products = State.new("Browse products")
purchase_products = State.new("Purchase product")

need.add_transition(Transition.new(browse_products, 0.4))
need.add_transition(Transition.new(purchase_products, 0.4))
need.add_transition(Transition.new(need, 0.2))

no_need.add_transition(Transition.new(no_need, 0.2))
no_need.add_transition(Transition.new(browse_products, 0.2))
no_need.add_transition(Transition.new(view_advertisement, 0.6))

browse_products.add_transition(Transition.new(purchase_products, 0.2))
browse_products.add_transition(Transition.new(browse_products, 0.8))

view_advertisement.add_transition(Transition.new(browse_products, 0.2))
view_advertisement.add_transition(Transition.new(purchase_products, 0.5))
view_advertisement.add_transition(Transition.new(no_need, 0.3))

purchase_products.add_transition(Transition.new(no_need, 0.6))
purchase_products.add_transition(Transition.new(browse_products, 0.4))

m = Machine.new(no_need)
50.times do |i|
	p "#{m.next_state} -> "
end

