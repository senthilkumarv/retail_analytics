class Profile
	def initialize
		@need = State.new("Need", 1)
		@no_need = State.new("No Need", 1)
		@view_advertisement = State.new("View advertisement", 0.3)
		@browse_products = State.new("Browse products", 2)
		@purchase_products = Purchase.new("Purchase product", 4)

		@need.add_transition(Transition.new(@no_need, 0.1))
		@need.add_transition(Transition.new(@need, 0.1))
		@need.add_transition(Transition.new(@browse_products, 0.6))
		@need.add_transition(Transition.new(@purchase_products, 0.2))

		@no_need.add_transition(Transition.new(@need, 0.1))
		@no_need.add_transition(Transition.new(@no_need, 0.1))
		@no_need.add_transition(Transition.new(@browse_products, 0.1))
		@no_need.add_transition(Transition.new(@view_advertisement, 0.7))

		@browse_products.add_transition(Transition.new(@purchase_products, 0.2))
		@browse_products.add_transition(Transition.new(@browse_products, 0.6))
		@browse_products.add_transition(Transition.new(@no_need, 0.2))

		@view_advertisement.add_transition(Transition.new(@browse_products, 0.1))
		@view_advertisement.add_transition(Transition.new(@purchase_products, 0.1))
		@view_advertisement.add_transition(Transition.new(@no_need, 0.8))

		@purchase_products.add_transition(Transition.new(@no_need, 0.9))
		@purchase_products.add_transition(Transition.new(@browse_products, 0.1))
	end
	
	def initial_state
		@no_need
	end
end

