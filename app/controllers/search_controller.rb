class SearchController < ApplicationController

	def search_func(excludes = [])
		model_names = @model_names
		Sunspot.search *@models do
			
			without(:id, excludes)
			with(:subscripted, to_boolean(finalOptions[:subscripted])) if !finalOptions[:subscripted].nil?

			any_of do
				# only customer users could be searched
				model_names.include?('user') and all_of do
					with(:class, User)
					with(:roles, finalOptions[:roles].split(',,'))
				end
				
				# promotions on status 'submitted' or 'rejected' will not be able to searched
				model_names.include?('promotion')  and all_of do
					with(:class, Promotion)			
					with(:catagory, finalOptions[:catagory]) if finalOptions[:catagory] != 'all'
					with(:status, finalOptions[:promotion_status].split(',,'))
				end
			end

			with(:location).in_radius(get_location[:lat], get_location[:long], finalOptions[:distance]) if get_location.present?

			# sort results
			if finalOptions[:sortBy] == 'distance'
				order_by_geodist(:location, get_location[:lat], get_location[:long]) if get_location.present?
			elsif finalOptions[:sortBy] == 'start' && model_names.include?('promotion')
				order_by(:start_at, :asc)
			elsif finalOptions[:sortBy] == 'rating'
				order_by(:rating, :asc)
			elsif finalOptions[:sortBy] == 'rate_count'
				order_by(:rate_count, :asc)
			elsif finalOptions[:sortBy] == 'random'
				order_by(:random)
			end
				
			order_by(:score, :asc)
			
			fulltext finalOptions[:query] do			
				if model_names.include? 'user'
					boost_fields :name => 12.0
					boost_fields :keywords => 8.0
					boost_fields :email => 5.0
				end

				if model_names.include? 'promotion'
					boost_fields :title => 12.0
					boost_fields :keywords => 8.0
				end
			end

			paginate(:page => finalOptions[:page], :per_page => finalOptions[:per_page])	
		end
	end

	# public search function
	# it takes following parameters:
	# 	query_scope:
	# 	    1. this parameter tells solr app the scope which it should be searching in  
	# 		2. this one is optional, could be left blank
	# 		3. could be 'all', 'user' or 'promotion'
	# 			or all combinations seperated by ',,': 'user,,promotion'
	# 	excludes: 
	# 		1. results should not be included the result list
	# 		2. it should be model ids'
	# 			  for example:  excludes=1233344t,,5464564646
	#   subscripted:
	#   	1. if only searching in subscripted users and promotions
	#   	2. could be nil, true or false
	#   lat: latitude
	#   long: longtitude
	#   distance: results within the distance 
	#   page:
	#   per_page:
	def query

		puts finalOptions

		# get query scope
		query_scope = finalOptions[:query_scope].downcase.split(',,')
		# store the models that will be searched
		@models = []
		# get excludes (which should not be included in the results)
		@excludes = finalOptions[:excludes].split(',,')
		
		@models << User if query_scope.include? 'user'
		@models << Promotion if query_scope.include? 'promotion'
		@model_names = @models.map { |model| model.name.downcase }

		@search = self.search_func(@excludes)
		@hits = @search.hits.map { |hit| { :class_name => hit.class_name, :result => hit.result } }

		render 'search/results', :locals => { :hits => @hits }
	end

	# GET /suggest
	def suggest
		
		results = Term.search do
			
			if params[:type].present?
				with(:type, params[:type].split(',,'))
			end

			# if params[:model].present?
			# 	with(:model, params[:model])
			# end

			without(:type, 'phone')

			fulltext params[:query]
			order_by(:searchs, :desc)
		end

		terms = results.hits.map(&:result)

		render json: terms
	end


	private

	# get the final search options
	def finalOptions
		defaultOptions.merge!(searchOptions)
	end

	# default search options
	def defaultOptions
		{
			:query_scope => 'user,,promotion',
			:excludes => '',
			:subscripted => nil,
			:roles => 'customer',
			:page => 1,
			:per_page => 10,
			:catagory => 'all',
			:promotion_status => 'reviewed',
			:query => '',
			:distance => 100000, # in kms
			:sortBy => 'score'
		}
	end

	def searchOptions
		options = params.permit(:query_scope, :subscripted, :roles, :page, :per_page, :catagory, :promotion_status, :query, :distance, :excludes, :sortBy)
		options.symbolize_keys
	end

end