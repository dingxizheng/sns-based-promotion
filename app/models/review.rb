class Review
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::QueryHelper

  resourcify

  # fields
  field :body, type: String

  field :anonymity_id, type: String

  # relationships
  belongs_to :reviewer, inverse_of: :opinions, class_name: 'User'
  belongs_to :customer, inverse_of: :reviews, class_name: 'User'
  belongs_to :promotion, inverse_of: :reviews, class_name: 'Promotion'

  def self.commented_by?(user, query)
    if user.class.name == 'User'
      Review.where(:reviewer_id => user.id).where(query).first ? true : false
    elsif user.class.name == 'Anonymity'
      Review.where(:anonymity_id => user.id).where(query).first ? true : false
    else
      false
    end
  end

  def anonymity
    Anonymity.find(self.anonymity_id)
  end

  def anonymous?
    self.anonymity_id ? true : false
  end

end
