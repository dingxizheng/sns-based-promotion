class Device

  include Mongoid::Document
  include Mongoid::Timestamps

  # fields
  field :identity, type: String
  field :token, type: String 
  field :os, type: String

  has_one :session

  # validates :identity, uniqueness: true

end
