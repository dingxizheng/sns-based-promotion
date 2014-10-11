class User
  include Mongoid::Document
  include Mongoid::Timestamps

  # fields
  field :name, type: String
  field :email, type: String
  field :phone, type: String
  field :address, type: String
  field :description, type: String
  field :keywords, type: Array, default: []
  field :type, type: String, default: 'user'
  field :logo, type: String, default: 'url to default logo'

  embeds_many :reviews
  has_many :opioins
  has_many :promotions

  validates_uniqueness_of :name, :email, :phone
  validates_format_of :email, with: /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

end
