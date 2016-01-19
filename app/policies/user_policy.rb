class UserPolicy < ApplicationPolicy

  def create?
  	# only admin user is able to create a user
  	user.is_admin?
  end

  def update?
  	user.is_admin? or user.id == record.id
  end

  def destory?
  	user.is_admin?
  end

end