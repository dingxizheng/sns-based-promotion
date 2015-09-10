class PromotionPolicy < ApplicationPolicy

  class Scope < Scope
    def resolve
      if user.get_id == params[:customer_id]
        scope.all
      else
        scope.nin(:status => ['submitted', 'rejected'])
      end
    end
  end

  def create?
    # only admin and customer has to premision to add a promotion
    user.has_any_role? :admin, :customer
  end

  def update?
    user.has_role? :moderator, record
  end

  def destroy?
    user.has_role? :moderator, record
  end

  def approve?
    user.is_admin?
  end

  def reject?
    user.is_admin?
  end

end