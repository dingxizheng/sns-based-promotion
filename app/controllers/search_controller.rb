class SearchController < ApplicationController

	def query
		@search = User.search do    
			fulltext params[:query]
		end

		puts @search.hits.to_yaml

		render json: @search.results
	end

	def autocomplete
		@search = User.search do  
			fulltext params[:query]
			facet :name, :email, :keywords, :address
		end

		bucket = [] 
		bucket << @search.facet(:name).rows.first(5).map{|x| x.value }
		bucket << @search.facet(:email).rows.first(5).map{|x| x.value }
		bucket << @search.facet(:keywords).rows.first(5).map{|x| x.value }
		bucket << @search.facet(:address).rows.first(5).map{|x| x.value }

		render json: bucket.flatten
	end

end