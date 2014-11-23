class Review
  include Mongoid::Document
  include Mongoid::Timestamps

  resourcify

  # fields
  field :body, type: String

  # relationships
  belongs_to :reviewer, inverse_of: :opinions, class_name: 'User'
  belongs_to :customer, inverse_of: :reviews, class_name: 'User'

  def get_id
  	self.id.to_s
  end


end
