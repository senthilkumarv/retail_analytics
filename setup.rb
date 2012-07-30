require './state.rb'
require './transition.rb'
require './machine.rb'

need = State.new
no_need = State.new
view_advertisement = State.new
browse_products = State.new
purchase_products = State.new

need.add_transition(Transition.new(browse_products, 0.2))
need.add_transition(Transition.new(purchase_products, 0.2))
need.add_transition(Transition.new(need, 0.2))
no_need.add_transition(Transition.new(no_need, 0.2))
no_need.add_transition(Transition.new(browse_products, 0.2))
no_need.add_transition(Transition.new(purchase_products, 0.2))
browse_products.add_transition(Transition.new(purchase_products, 0.2))
view_advertisement.add_transition(Transition.new(view_advertisement, browse_products, 0.2))
view_advertisement.add_transition(Transition.new(view_advertisement, purchase_products, 0.2))

m = Machine.new(no_need)
while(true)
	m.next
end

