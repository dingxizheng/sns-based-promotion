class CommentPolicy < ApplicationPolicy

  class Scope < Scope
    def resolve
      if user.present? and user.has_role?(:admin)
        scope.all
      else
        scope.approved
      end
    end
  end

  # user can not comment him/her self nor the promotions belong to them
  def create?
    not user.muted?
  end

  def update?
    user.has_role?(:moderator, record)
  end

  def destory?
    user.has_role?(:moderator, record) or user.has_role?(:admin)
  end

end