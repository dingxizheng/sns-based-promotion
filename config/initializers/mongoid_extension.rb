
module Mongoid::Document
  def get_id
    self.id.to_s
  end
end

module Mongoid
  module Keywordsable
    extend ActiveSupport::Concern

    included do

      before_save :keywords_validate

      field :keywords, type: Array, default: []

    end

    # keywords validate
    def keywords_validate
      if self.keywords.count != self.keywords.uniq.count
        self.errors.add :keywords, 'cannot add duplicate keyword'
        return false
      elsif self.keywords.count > 5
        self.errors.add :keywords, 'cannot have more than 5 keywords'
        return false
      elsif self.keywords.any? { |keyword| keyword.size < 3 }
        self.errors.add :keywords, 'a keyword should contain more than 3 characters'
        return false
      elsif self.keywords.any? { |keyword| keyword.size > 15 }
        self.errors.add :keywords, 'a keyword should contain less than 15 characters'
        return false
      else
        return true
      end
    end

    # def not_validate?(keyword)
    #   if keyword.size < 3
    #     return 'a keyword should contain more than 3 characters'
    #   elsif keyword.size > 15
    #     return 'a keyword should contain less than 15 characters'
    #   else
    #     return false
    #   end
    # end

    # add keyword to user
    def add_keyword(keyword)
      if self.keywords.include?(keyword)
        self.errors.add :keywords, 'cannot add duplicate keyword'
        # return false if an error added
        return false
      elsif self.keywords.size == 5
        self.errors.add :keywords, 'cannot have more than 5 keywords'
        return false
      elsif keyword.size < 3
        self.errors.add :keywords, 'a keyword should contain more than 3 characters'
        return false
      elsif keyword.size > 15
        self.errors.add :keywords, 'a keyword should contain less than 15 characters'
        return false
      else
        self.push(keywords: keyword)
      end
    end

  end
end
