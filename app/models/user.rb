require 'digest'

class User
  include Mongoid::Document
  include Mongoid::Timestamps

   # filters
  before_create :encrypt_password

  # fields
  field :name, type: String
  field :email, type: String
  field :password, type: String, default: '1234'
  field :phone, type: String
  field :address, type: String
  field :description, type: String
  field :keywords, type: Array, default: []
  field :role, type: String, default: 'user'
  field :logo, type: String, default: 'url to default logo'

  # relations
  has_many :reviews, inverse_of: :customer, class_name: 'Review'
  has_many :opinions, inverse_of: :reviewer, class_name: 'Review'
  has_many :promotions
  has_one  :session

  # validaters
  validates_uniqueness_of :name, :email, :phone
  validates_format_of :email, with: /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

  # see if passworkd matches or not
  def password_match?(password)
  	self.password == Digest::SHA2.hexdigest(password)
  end

  private
  	# encrypt password 
  	def encrypt_password
  		self.password = Digest::SHA2.hexdigest(self.password)
  	end

end
