class Review
  include Mongoid::Document
  include Mongoid::Timestamps

  # fields
  field :body, type: String

  belongs_to :author, class_name: 'User'
  embedded_in :customer, inverse_of: :reviews, class_name: 'User'
end
