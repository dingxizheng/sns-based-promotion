require 'digest'

class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Sunspot::Mongoid2
  include Geocoder::Model::Mongoid
  
  geocoded_by :address 
  after_validation :geocode
  after_create :send_email

  rolify

  # filters
  before_create :encrypt_password, :set_default_role

  # fields
  field :name, type: String
  field :email, type: String
  field :password, type: String, default: '1234'
  field :phone, type: String
  field :address, type: String
  field :description, type: String
  field :keywords, type: Array, default: []
  field :coordinates, type: Array
  field :guest, type: Boolean, default: false
  
  # relations
  has_many :reviews, inverse_of: :customer, class_name: 'Review'
  has_many :opinions, inverse_of: :reviewer, class_name: 'Review'
  has_many :promotions
  has_one  :session
  has_one  :logo, class_name: 'Image'
  has_many :photos, class_name: 'Image'
  has_many :subscriptions

  # appointments
  has_many :booked_appointments, inverse_of: :booker, class_name: 'Appointment'
  has_many :accepted_appointments, inverse_of: :accepter, class_name: 'Appointment'
  has_many :timeslots

  # sunspot
  searchable do   
    text :name, :email, :description, :keywords, :address, :phone

    string :id do 
      get_id
    end

    boolean :subscripted do
      subscripted?
    end

    string :roles, :multiple => true do
    	roles.map{ |r| r.name }.uniq
    end

    latlon(:location) {
      Sunspot::Util::Coordinates.new(lat , lon)
    }
  end

  # validaters
  validates_uniqueness_of :name, :email
  # validates_format_of :email, with: /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  validates_format_of :phone,
      :message => "must be a valid telephone number.",
      :with => /\(?([0-9]{3})\)?([ .-]?)([0-9]{3})\2([0-9]{4})/,
      :allow_blank => true

  def subscripted?
    self.subscriptions.any? { |s| s.activate? }
  end

  def lon
    if not self.coordinates.nil? then self.coordinates[0] else 0 end
  end
 
  def lat
    if not self.coordinates.nil? then self.coordinates[1] else 0 end 
  end

  # return id object to id string
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

  # see if password matches or not
  def password_match?(password)
  	self.password == Digest::SHA2.hexdigest(password)
  end

  # set logo
  def set_logo(upload)
    # create a new image record
    logo = Image.new({ :user_id => self.get_id })
    if not logo.store(upload) or not logo.save
      self.errors.add :logo, upload.original_filename + ': could not set logo.'
      return false
    end
    self.logo = logo
    return true
  end

  # add a new photo
  def add_photo(upload)
    # create a new image record
    image = Image.new({ :user_id => self.get_id })
    if not image.store(upload) or not image.save
      self.errors.add :photos, upload.original_filename + ': could not add image.'
      return false
    end
    self.photos.push(image);
    return true
  end

  # set user as normal user
  def set_default_role
    self.add_role :user
  end

  def reset_password
    self.password = ('0'..'z').to_a.shuffle.first(5).join
    self.encrypt_password
  end

  # is admin
  def is_admin?
    self.has_role? :admin
  end

  # send email after a user creation
  def send_email
    UserMailer.welcome(self).deliver_later!(wait: 10.seconds)
    UserMailer.new_user(self).deliver_later!(wait: 10.seconds)
  end

  private
  	# encrypt password 
  	def encrypt_password
  		self.password = Digest::SHA2.hexdigest(self.password)
  	end

end
