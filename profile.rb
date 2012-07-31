class Profile
	def initialize
		@need = State.new("Need", 1)
		@no_need = State.new("No Need", 1)
		@view_advertisement_on_tv = State.new("View advertisement on TV", 0.3)
		@view_advertisement_online = State.new("View advertisement online", 0.3)
		@view_advertisement_on_radio = State.new("View advertisement on radio", 0.3)
		@browse_products = State.new("Browse products", 2)
		@purchase_products = Purchase.new("Purchase product", 4)

		@need.add_transition(Transition.new(@no_need, 0.1))
		@need.add_transition(Transition.new(@need, 0.1))
		@need.add_transition(Transition.new(@browse_products, 0.6))
		@need.add_transition(Transition.new(@purchase_products, 0.2))

		@no_need.add_transition(Transition.new(@need, 0.1))
		@no_need.add_transition(Transition.new(@no_need, 0.1))
		@no_need.add_transition(Transition.new(@browse_products, 0.1))
		@no_need.add_transition(Transition.new(@view_advertisement_on_tv, 0.2))
		@no_need.add_transition(Transition.new(@view_advertisement_online, 0.2))
		@no_need.add_transition(Transition.new(@view_advertisement_on_radio, 0.3))

		@browse_products.add_transition(Transition.new(@purchase_products, 0.2))
		@browse_products.add_transition(Transition.new(@browse_products, 0.6))
		@browse_products.add_transition(Transition.new(@no_need, 0.2))

		@view_advertisement_on_tv.add_transition(Transition.new(@browse_products, 0.1))
		@view_advertisement_on_tv.add_transition(Transition.new(@purchase_products, 0.1))
		@view_advertisement_on_tv.add_transition(Transition.new(@no_need, 0.8))

		@view_advertisement_online.add_transition(Transition.new(@browse_products, 0.1))
		@view_advertisement_online.add_transition(Transition.new(@purchase_products, 0.1))
		@view_advertisement_online.add_transition(Transition.new(@no_need, 0.8))

		@view_advertisement_on_radio.add_transition(Transition.new(@browse_products, 0.1))
		@view_advertisement_on_radio.add_transition(Transition.new(@purchase_products, 0.1))
		@view_advertisement_on_radio.add_transition(Transition.new(@no_need, 0.8))

		@purchase_products.add_transition(Transition.new(@no_need, 0.9))
		@purchase_products.add_transition(Transition.new(@browse_products, 0.1))
	end
	
	def initial_state
		@no_need
	end
end

