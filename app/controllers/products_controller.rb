class ProductsController < ApplicationController

  # GET /products
  def index
    @products = Product.query_by_params(request.query_parameters.except!(*(params_to_skip)))
                       .sortby(params[:sortBy])
    				   .paginate(params[:page], params[:per_page])
    render 'products/products', :locals => { :products => @products }
  end

end