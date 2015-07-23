class SubscriptionPolicy < ApplicationPolicy

  def create?
    # only admin has the premision to add a promotion
    user.is_admin? or record.user_id.to_s == user.get_id
  end

  def destory?
    user.is_admin?
  end

  def cancel?
    user.is_admin?
  end

end