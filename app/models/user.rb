require 'digest'
class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Search
  include Sunspot::Mongoid2
  include Mongoid::Taggable
  include Mongoid::Likeable
  include Mongoid::Liker
  include Mongoid::Followable
  include Mongoid::Follower
  include Mongoid::Enum
  include Geocoder::Model::Mongoid
  include Mongoid::QueryHelper
  include Mongoid::GeoHelper
  include Mongoid::Encryptable
  include Mongoid::FileUploader
  include Mongoid::RelationCounter
  include PublicActivity::Common
  
  rolify

  geocoded_by :address
  after_validation :geocode
  before_create :encrypt_password, :set_default_role
  before_save :validates_address
  before_destroy :destroy_children

  # after_save    :add_create_activity
  after_update  :add_update_activity
  # after_destroy :add_destroy_activity

  # fields
  field :name, type: String
  field :email, type: String
  field :password, type: String, default: '1234'
  field :phone, type: String
  field :address, type: String
  field :description, type: String
  field :coordinates, type: Array

  # if user signed up via third parties
  field :provider, type: String
  field :id_from_provider, type: String
  field :profile_picture, type: String

  imageable   :avatar, :background, :photos
  encryptable :address, :phone
  enum :status, [:approved, :pending, :declined, :muted]

  count_relations :comments, :opinions, :promotions, :sessions, :photos, :likers, :dislikers

  # change tags separator to ;;
  tags_separator ';'

  # relations
  has_many :comments, inverse_of: :commentee, class_name: 'Comment', autosave: true, dependent: :destroy
  has_many :opinions, inverse_of: :commenteer, class_name: 'Comment', autosave: true
  has_many :promotions, autosave: true, dependent: :destroy
  has_many :sessions, autosave: true, dependent: :destroy

  # a user only has one logo
  has_one  :avatar, inverse_of: :avatar_owner, class_name: 'Image', autosave: true, dependent: :destroy
  # a user only has on background
  has_one  :background, inverse_of: :background_owner, class_name: 'Image', autosave: true, dependent: :destroy
  # a user could have many photos
  has_many :photos, inverse_of: :photos_owner, class_name: 'Image', autosave: true, dependent: :destroy

  # messages
  has_many :out_going_msgs, inverse_of: :sender, class_name: 'Message'
  has_many :in_coming_msgs, inverse_of: :receiver, class_name: 'Message'

  # validaters
  validates_uniqueness_of :name, :email
  validates_uniqueness_of :id_from_provider, :allow_nil => true
  validates_uniqueness_of :phone, :allow_nil => true
  validate :email_format, :phone_format
  
  def email_format
    if (self.email =~ /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i).nil?
      self.errors.add(:email, I18n.t('errors.validations.email'))
    end
  end

  def phone_format
    if self.phone.present? and (self.phone =~ /\(?([0-9]{3})\)?([ .-]?)([0-9]{3})\2([0-9]{4})/i).nil?
      self.errors.add(:phone, I18n.t('errors.validations.phone'))
    end
  end
  
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

  def get_avatar
    if self.avatar
      self.avatar.file.url
    else
      self.profile_picture
    end
  end

  def get_roles

  end

  # setting mongoid search fields
  search_in :name, :email, :address, :description

  # Search block
  # 
  if Settings.sunspot.enable_user
    # sunspot
    searchable do   
      text :name, :email, :description, :tags, :address, :phone
      string :status
      string :id do 
        get_id
      end
      time :created_at
      time :updated_at
      string :roles, :multiple => true do
        roles.map{ |r| r.name }.uniq
      end
      latlon(:location) {
        Sunspot::Util::Coordinates.new(lat , lon)
      }
    end

    # #index terms after save
    # after_save :index_terms

    # # break user's info into small chunks and index them
    # def index_terms
    #   Term.index_user_on_demand(self)
    # end
  end
  
  private
  # validate address
  def validates_address
    if self.address_changed?
      # search address by using google api
      results = Geocoder.search(self.address)
      # if no result returned, then is not a valid address
      if results.count == 0
        self.errors.add :address, I18n.t('errors.validations.address')
        return false
      # otherwise, check if the address is a valid canada address
      else
        new_results = results.select{ |addr|
          addr.formatted_address.include? 'Canada'
        }
        if new_results.count == 0
          self.errors.add :address, I18n.t('errors.validations.address_ca')
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

  def add_update_activity
    if self.name_changed?
      self.create_activity key: 'user.updated_name', owner: self
    end
  end

  # destroy all related children
  def destroy_children
  end

end
