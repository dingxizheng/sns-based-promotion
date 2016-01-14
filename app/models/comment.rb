class Comment
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongo::Voter
  include Mongoid::Enum
  include Mongoid::QueryHelper

  resourcify

  before_update :validate_parent_id

  # fields
  field :body, type: String
  field :parent_id, type: String

  enum :status, [:approved, :pending, :declined]

  # relationships
  belongs_to :commentee, inverse_of: :comments, class_name: 'User'
  belongs_to :commenteer, inverse_of: :opinions, class_name: 'User'
  belongs_to :promotion

  validates_presence_of :body
  validate_length_of :body, minimum: 1, maximum: 300

  voteable self, :up => +1, :down => -1

  # return replies
  def replies
  end

  # get commented object
  def get_commentee
    if self.promotion_id
      self.promotion
    elsif self.commentee_id
      self.commentee
    else
      nil
    end
  end

  private
  # should not change parent id
  # when updating the comment
  def validate_parent_id
    not self.parent_id_changed?
  end

  # def self.commented_by?(user, query)
  #   if user.class.name == 'User'
  #     Review.where(:reviewer_id => user.id).where(query).first ? true : false
  #   elsif user.class.name == 'Anonymity'
  #     Review.where(:anonymity_id => user.id).where(query).first ? true : false
  #   else
  #     false
  #   end
  # end

  # def anonymity
  #   Anonymity.find(self.anonymity_id)
  # end

  # def anonymous?
  #   self.anonymity_id ? true : false
  # end

end
