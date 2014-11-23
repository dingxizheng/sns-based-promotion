class Promotion
  include Mongoid::Document
  include Mongoid::Timestamps

  resourcify

  # fields
  field :title, type: String
  field :body, type: String
  field :start_at, type: DateTime, default: Time.now
  field :expire_at, type: DateTime, default: Time.now + 2.weeks

  belongs_to :customer, class_name: 'User', inverse_of: :promotions

  def get_id
  	self.id.to_s
  end

end
