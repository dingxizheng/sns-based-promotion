class CatagoryPolicy < ApplicationPolicy

  def create?
    user.is_admin?
  end

  def update?
    user.is_admin?
  end

  def destory?
    user.is_admin?
  end

end