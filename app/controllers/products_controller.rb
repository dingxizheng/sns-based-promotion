class ProductsController < ApplicationController

  # GET /products
  def index
    @products = query_by_conditions(Product, request.query_parameters)
    render 'products/products', :locals => { :products => @products }
  end

end