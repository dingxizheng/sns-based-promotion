class ReviewPolicy < ApplicationPolicy

  class Scope < Scope
    def resolve
      if user.guest
        scope.all
      elsif user.is_admin?
        scope.all
      else
        user.reviews
      end
    end
  end

  # user can not comment him/her self nor the promotions belong to them
  def create?
    if record.customer.present?
      user.id != record.customer.id
    else
      user.id != record.promotion.customer.id
    end
  end

  def update?
    user.has_role? :moderator, record
  end

  def destory?
    user.has_role? :moderator, record
  end

end