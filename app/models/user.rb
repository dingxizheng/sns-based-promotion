
require 'digest'

class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Sunspot::Mongoid2
  include Mongo::Voter
  include Mongoid::Taggable
  include Geocoder::Model::Mongoid
  include Mongoid::QueryHelper
  include Mongoid::GeoHelper
  
  geocoded_by :address 
  after_validation :geocode
  after_save :index_terms
  before_create :encrypt_password, :set_default_role
  before_save :lowercase_email, :validates_address
  before_destroy :destroy_children

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

  # change tags separator to ;;
  tags_separator ';'
  
  # relations
  has_many :reviews, inverse_of: :customer, class_name: 'Review'
  has_many :opinions, inverse_of: :reviewer, class_name: 'Review'
  has_many :promotions
  has_many :sessions
  
  # a user only has one logo
  has_one  :logo, inverse_of: :logo_owner, class_name: 'Image'
  # a user only has on background
  has_one  :background, inverse_of: :background_owner, class_name: 'Image'
  # a user could have many photos
  has_many :photos, inverse_of: :photos_owner, class_name: 'Image'

  # messages
  has_many :out_going_msgs, inverse_of: :sender, class_name: 'Message'
  has_many :in_coming_msgs, inverse_of: :receiver, class_name: 'Message'

  # sunspot
  searchable do   
    text :name, :email, :description, :tags, :address, :phone

    string :id do 
      get_id
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
  validates_format_of :email, 
      :message => I18n.t 'errors.validations.email',
      :with => /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  validates_format_of :phone,
      :message => I18n.t 'errors.validations.phone',
      :with => /\(?([0-9]{3})\)?([ .-]?)([0-9]{3})\2([0-9]{4})/,
      :allow_blank => true
  
  # get longtitude
  def lon
    if not self.coordinates.nil? then self.coordinates[0] else 0 end
  end
  
  # get latitude
  def lat
    if not self.coordinates.nil? then self.coordinates[1] else 0 end 
  end

  # see if password matches or not
  def password_match?(password)
  	self.password == Digest::SHA2.hexdigest(password)
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

  # break user's info into small chunks and index them
  def index_terms
    Term.index_user_on_demand(self)
  end
  # handle_asynchronously :index_terms, :run_at => Proc.new { 3.minutes.from_now }


  private
  # lowercase email address
  def lowercase_email
    self.email = self.email.downcase
  end

  # validate address
  def validates_address
    if self.address_changed?
      # search address by using google api
      results = Geocoder.search(self.address)
      # if no result returned, then is not a valid address
      if results.count == 0
        self.errors.add :address, I18n.t 'errors.validations.address'
        return false
      # otherwise, check if the address is a valid canada address
      else
        new_results = results.select{ |addr|
          addr.formatted_address.include? 'Canada'
        }
        if new_results.count == 0
          self.errors.add :address, I18n.t 'errors.validations.address_ca'
          return false
        else
          self.address = new_results[0].formatted_address
        end 
      end
    end
  end

  # encrypt password 
  def encrypt_password
    self.password = Digest::SHA2.hexdigest(self.password)
  end

  # set user as normal user
  def set_default_role
    self.add_role :user
  end

  # destroy all related children
  def destroy_children
    self.logo.destroy
    self.background.destroy
    self.photos.destroy_all

    self.promotions.destroy_all
  end

end
