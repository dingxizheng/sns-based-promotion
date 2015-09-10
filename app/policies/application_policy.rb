class ApplicationPolicy

	class Scope
		attr_reader :user, :scope, :params

		def initialize(user, scope, params = {})
			@user = user
			@scope = scope
			@params = params
		end

		def resolve
		end
		
	end

	attr_reader :user, :record

	def initialize(user, record)
		@user = user
		@record = record
	end

end
