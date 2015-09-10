class SearchController < ApplicationController

	def search_func(excludes = [])
		model_names = @model_names
		Sunspot.search *@models do
			
			without(:id, excludes)
			with(:subscripted, false) if !params[:subscripted].nil? and params[:subscripted] == 'false'
			with(:subscripted, true) if !params[:subscripted].nil? and params[:subscripted] == 'true'
			
			with(:roles, 'customer') if model_names.include? 'user' and !model_names.include? 'promotion'
			without(:status, ['submitted', 'rejected']) if model_names.include? 'promotion' and !model_names.include? 'user'

			if ['promotion', 'user'].all? { |i| model_names.include? i }
				any_of do
					# only customer users could be searched
					all_of do
						with(:class, User)
						with(:roles, 'customer')
					end
					# promotions on status 'submitted' or 'rejected' will not be able to searched
					all_of do
						with(:class, Promotion)				
						without(:status, ['submitted', 'rejected'])
					end
				end
			end

			if ['promotion', 'user'].any? { |i| model_names.include? i }
				with(:location).in_radius(get_location[:lat], get_location[:long], params[:distance] || 10000) if get_location.present? and params[:distance]
			end

			fulltext params[:query] do			
				if model_names.include? 'user'
					boost_fields :name => 10
					boost_fields :keywords => 5
				end

				if model_names.include? 'promotion'
					boost_fields :title => 8
				end
			end

			if params[:page].present?
				paginate(:page => params[:page] || 1, :per_page => params[:per_page] || 7)
			end

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
		query_scope = params[:query_scope]
		# if query_scope is not specified, set it to 'all' by default
		query_scope = 'all' unless params[:query_scope].present?
		query_scope = query_scope.downcase.split(',,')

		# store the models that will be searched
		@models = []

		@excludes = []
		@excludes = params[:excludes].split(',,') if params[:excludes].present?
		

		if ['all', 'user'].any? { |word| query_scope.include? word }
			@models << User
		end

		if ['all', 'promotion'].any? { |word| query_scope.include? word }
			@models << Promotion
		end

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

			without(:type, 'phone')

			fulltext params[:query]
			order_by(:searchs, :desc)
		end

		terms = results.hits.map(&:result)

		render json: terms
	end

end