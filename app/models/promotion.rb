class Promotion
  include Mongoid::Document
  include Mongoid::Timestamps

  # fields
  field :title, type: String
  field :body, type: String
  field :start_at, type: Date, default: Time.now
  field :expire_at, type: Date, default: Time.now + 2.weeks

  belongs_to :customer, class_name: 'User', inverse_of: :promotions

end
