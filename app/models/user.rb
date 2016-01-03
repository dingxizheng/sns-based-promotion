
require 'digest'
require 'query_helper'
require 'geo_helper'
require 'rating'
require 'rateable'

class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Sunspot::Mongoid2
  include Mongoid::Rateable
  include Geocoder::Model::Mongoid
  include Mongoid::QueryHelper
  include Mongoid::GeoHelper
  include Mongoid::Keywordsable
  include Mongoid::Randomizable
  
  geocoded_by :address 
  after_validation :geocode
  after_save :index_terms
  before_create :encrypt_password, :set_default_role
  before_save :set_subscripted_status, :set_role, :check_address
  after_create :send_new_user_email

  rolify

  # fields
  field :name, type: String
  field :email, type: String
  field :password, type: String, default: '1234'
  field :phone, type: String
  field :address, type: String
  field :description, type: String
  field :coordinates, type: Array
  field :guest, type: Boolean, default: false
  field :subscripted, type: Boolean, default: false
  
  # business operation hours
  field :hours, type: Hash, default: {
    :Monday => { :from => '9:00', :to => '17:00' },
    :Tuesday => { :from => '9:00', :to => '17:00' },
    :Wednesday => { :from => '9:00', :to => '17:00' },
    :Thursday => { :from => '9:00', :to => '17:00' },
    :Friday => { :from => '9:00', :to => '17:00' }
  }

  # mark this model as reteable
  rate_config range: (0..5), raters: [User, Anonymity]
  
  # relations
  has_many :reviews, inverse_of: :customer, class_name: 'Review'
  has_many :opinions, inverse_of: :reviewer, class_name: 'Review'
  has_many :promotions
  has_many :sessions
  has_one  :logo, inverse_of: :logo_owner, class_name: 'Image'
  has_one  :background, inverse_of: :background_owner, class_name: 'Image'
  has_many :photos, inverse_of: :photos_owner, class_name: 'Image'
  has_many :subscriptions

  # appointments
  has_many :booked_appointments, inverse_of: :booker, class_name: 'Appointment'
  has_many :accepted_appointments, inverse_of: :accepter, class_name: 'Appointment'
  has_many :timeslots

  # messages
  has_many :out_going_msgs, inverse_of: :sender, class_name: 'Message'
  has_many :in_coming_msgs, inverse_of: :receiver, class_name: 'Message'

  # sunspot
  searchable do   
    text :name, :email, :description, :keywords, :address, :phone

    string :id do 
      get_id
    end

    boolean :subscripted

    string :roles, :multiple => true do
    	roles.map{ |r| r.name }.uniq
    end

    time :start_at

    double :rating
    double :rate_count

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

  # indexes
  # index({ coordinates: "2d" })
  index({ subscripted: 1 })

  def set_subscripted_status
    self.subscripted = self.subscripted?
    return true
  end

  # check if user still has any active subscriptions
  def subscripted?
    self.subscriptions.any? { |s| s.activate? }
  end

  def lon
    if not self.coordinates.nil? then self.coordinates[0] else 0 end
  end
 
  def lat
    if not self.coordinates.nil? then self.coordinates[1] else 0 end 
  end

  # validate address
  def check_address
    if self.address_changed?
      # search address by using google api
      results = Geocoder.search(self.address)
      # if no result returned, then is not a valid address
      if results.count == 0
        self.errors.add :address, 'it is not a valid address!'
        return false
      # otherwise, check if the address is a valid canada address
      else
        new_results = results.select{ |addr|
          addr.formatted_address.include? 'Canada'
        }
        if new_results.count == 0
          self.errors.add :address, 'please input a valid canada address!'
          return false
        else
          self.address = new_results[0].formatted_address
        end 
      end
    end
  end

  # see if password matches or not
  def password_match?(password)
  	self.password == Digest::SHA2.hexdigest(password)
  end

  # add a new photo
  def add_photo(upload)
    # create a new image record
    image = Image.new({ :user_id => self.get_id })
    if not image.store(upload) and not image.save
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

  # if user has completed the profile, then mark it as a business user
  def set_role
    if self.has_role? :customer
      if self.address.nil? or self.phone.nil? or self.description.nil?
        self.remove_role :customer
      end
    else
      unless self.address.nil? or self.phone.nil? or self.description.nil?
        self.add_role :customer
        self.send_customer_confirmation_email
      end
    end
    return true
  end

  # reset user's password
  def reset_password
    self.password = ('0'..'9').to_a.shuffle.first(5).join
    # self.encrypt_password
  end

  # is admin
  def is_admin?
    self.has_role? :admin
  end

  # send email after a user creation
  def send_new_user_email
    UserMailer.welcome(self).deliver_now!
    UserMailer.new_user(self).deliver_now!
  end
  # handle_asynchronously :send_new_user_email, :run_at => Proc.new { 1.minutes.from_now }

  def send_customer_confirmation_email
    UserMailer.customer_confirmation(self).deliver_now!
  end
  # handle_asynchronously :send_customer_confirmation_email, :run_at => Proc.new { 1.minutes.from_now }

  # break user's info into small chunks and index them
  def index_terms
    Term.index_user_on_demand(self)
  end
  # handle_asynchronously :index_terms, :run_at => Proc.new { 3.minutes.from_now }
 
	# encrypt password 
	def encrypt_password
		self.password = Digest::SHA2.hexdigest(self.password)
	end

end
