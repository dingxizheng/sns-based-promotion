class ApplicationPolicy
	attr_reader :user, :record

	def initialize(user, record)
		@user = user
		@record = record
	end

	def user_activities
		@user.roles
end