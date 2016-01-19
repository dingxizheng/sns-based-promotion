class PromotionPolicy < ApplicationPolicy

  class Scope < Scope
    def resolve
      if params[:owner]
        if params[:owner].get_id == user.get_id or (user and user.has_role? :admin)
          scope.promotions.approved
        else
          scope.promotions
        end
      else
        if user and user.has_role? :admin
          scope
        else
          scope.approved
        end
      end
    end
  end

  def show?
    if record.approved?
      true
    else 
      user.has_role?(:admin) or user.has_role?(:moderator, record)
    end
  end

  def create?
    not user.muted?
  end

  def update?
    user.has_role?(:moderator, record) or user.has_role?(:admin)
  end

  def destroy?
    user.has_role?(:moderator, record) or user.has_role?(:admin)
  end

end