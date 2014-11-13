require 'digest'

class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Sunspot::Mongoid2

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
  field :roles, type: Array, default: ['login']
  
  # relations
  has_many :reviews, inverse_of: :customer, class_name: 'Review'
  has_many :opinions, inverse_of: :reviewer, class_name: 'Review'
  has_many :promotions
  has_one  :session
  has_one  :logo, class_name: 'Image'

  # sunspot
  searchable do
    
    text :name, :email, :description, :keywords, :address

  end

  # validaters
  validates_uniqueness_of :name, :email
  # validates_format_of :email, with: /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  validates_format_of :phone,
      :message => "must be a valid telephone number.",
      :with => /\(?([0-9]{3})\)?([ .-]?)([0-9]{3})\2([0-9]{4})/,
      :allow_blank => true


  def get_id
    self.id.to_s
  end

  # add keyword to user
  def add_keyword(keyword)
    if self.keywords.include?(keyword)
      self.errors.add :keywords, 'could not have duplicate values'
      # return false if an error added
      return false
    else
      self.push(keywords: keyword)
    end
  end

  # see if passworkd matches or not
  def password_match?(password)
  	self.password == Digest::SHA2.hexdigest(password)
  end

  # set logo
  def set_logo(upload)
    logo = Image.new({ :user_id => self.get_id })
    if not logo.store(upload) or not logo.save
      self.errors.add :logo, upload.original_filename + ': could not set logo.'
      return false
    end
    return true
  end

  private
  	# encrypt password 
  	def encrypt_password
  		self.password = Digest::SHA2.hexdigest(self.password)
  	end

end
