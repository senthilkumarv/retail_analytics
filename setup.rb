require './state.rb'
require './transition.rb'

need = State.new
view_advertisement = State.new
browse_products = State.new
purchase_products = State.new

browse_given_need = Transition.new(need, browse_products, 0.2)
purchase_given_need = Transition.new(need, purchase_products, 0.2)
purchase_given_browse = Transition.new(browse_products, purchase_products, 0.2)
browse_given_view = Transition.new(view_advertisement, browse_products, 0.2)
purchase_given_view = Transition.new(view_advertisement, purchase_products, 0.2)

