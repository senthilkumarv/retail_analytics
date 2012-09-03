class BehaviorGenerator
  def initialize(repository, order)
    @repository = repository
    @order = order
  end

  def search_for_product(item)
    @repository.create_search({:session => @order[:session], :user => @order[:user], :product => item[:id]})
  end

  def search_for_available_product_and_add_to_cart(item)
    search_for_product_and_add_to_cart(item, true)
  end

  def search_for_unavailable_product_and_add_to_cart(item)
    search_for_product_and_add_to_cart(item, false)
  end

  def make_purchase_of_searched_product
    @order[:items].each { |item|
      search_for_available_product_and_add_to_cart({:id => item[0], :quantity => item[1]})
    }
    @repository.make_payment({:session => @order[:session], :user => @order[:user], :order => @order[:order]})
  end
  
  private

  def search_for_product_and_add_to_cart(item, availability)
    search_for_product(item)
    @repository.add_to_cart({:session => @order[:session], :user => @order[:user], :product => item[:id], :quantity => item[:quantity], :availability => availability})
  end
end
