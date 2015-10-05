
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

module Mongoid
  module Randomizable
    extend ActiveSupport::Concern
      
      included do

        before_save :set_random_num
        field :random_num, type: Float, default: 0.0

        index({:random_num => 1})

        scope :randomized, -> (num) { 

          count = self.count
          queries = []

          if num / count.to_f < 0.5
            split = 60
          else
            split = count
          end
          
          (0..50).each{|i|
              random_start = rand * 1.4 - 0.2
              random_end = random_start + (1.4 / split.to_f) * rand
              queries.push(:$and => [{ :random_num.gt => random_start}, {:random_num.lte => random_end}])
          }
          
          self.or(*queries).limit(num)

        }

      end

      def set_random_num
        self.random_num = rand
      end

  end
end