class Review
  include Mongoid::Document
  include Mongoid::Timestamps

  # fields
  field :body, type: String

  # relationships
  belongs_to :reviewer, inverse_of: :opinions, class_name: 'User'
  belongs_to :customer, inverse_of: :reviews, class_name: 'User'


end
