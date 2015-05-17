class SearchController < ApplicationController

	def query

		@search = User.search do

			fulltext params[:query] do

				boost_fields :name => 10
				boost_fields :keywords => 5

			end

			paginate(:page => params[:page] || 1, :per_page => 7)

			with(:location).in_radius(*Geocoder.coordinates(params[:search_near]), params[:distance]) if params[:search_near].present?
		end

		@users = @search.results
		render 'users/users', :locals => { :users => @users }
	end

end