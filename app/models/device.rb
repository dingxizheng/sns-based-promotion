class Device

  include Mongoid::Document
  include Mongoid::Timestamps

  # fields
  field :identity, type: String
  field :token, type: String 
  field :os, type: String
  field :user_id, type: String

  # validates :identity, uniqueness: true

end
