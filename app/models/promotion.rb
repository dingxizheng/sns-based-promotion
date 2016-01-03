
require 'rateable'
require 'rating'
require 'query_helper'
require 'geo_helper'

class Promotion
  include Mongoid::Document
  include Mongoid::Timestamps
  include Sunspot::Mongoid2
  include Mongoid::Rateable
  include Geocoder::Model::Mongoid
  include Mongoid::QueryHelper
  include Mongoid::GeoHelper
  include Mongoid::Keywordsable
  include Mongoid::Randomizable

  geocoded_by :coordinates           # can also be an IP address
  # after_validation :geocode          # auto-fetch coordinates

  after_create :send_email
  before_save :set_coordinates
  after_save :index_terms

  resourcify

  # fields
  field :title, type: String
  field :description, type: String
  field :status, type: String, default: 'submitted'
  field :reject_reason, type: String, default: 'unknown'
  field :coordinates, type: Array
  field :subscripted, type: Boolean, default: false
  field :start_at, type: DateTime, default: Time.now
  field :expire_at, type: DateTime, default: Time.now + 2.weeks

  # mark this model as reteable
  rate_config range: (0..5), raters: [User, Anonymity]

  has_one  :cover, class_name: 'Image'
  has_many :reviews, inverse_of: :promotion, class_name: 'Review'
  belongs_to :catagory
  belongs_to :customer, class_name: 'User', inverse_of: :promotions

  # indexes
  # index({ coordinates: "2d" })
  index({ subscripted: 1 })

  # sunspot config 
  searchable do
    text :title, :description, :keywords
    text :catagory do
      catagory.name
    end
    text :customer_name do
      customer.name
    end
    text :customer_address do
      customer.address
    end
    text :customer_email do
      customer.email  
    end

    time :expire_at, :start_at
    
    string :status
    string :id do
      get_id
    end

    double :rating
    double :rate_count

    boolean :subscripted

    latlon(:location){
      Sunspot::Util::Coordinates.new(lat , lon)
    }
  end

  def lon
    if not self.coordinates.nil? then self.coordinates[0] else 0 end
  end

  def lat
    if not self.coordinates.nil? then self.coordinates[1] else 0 end
  end

  def approve
    self.status = 'reviewed'
  end

  def is_reviewed?
    'reviewed' == self.status
  end

  def reject(reason)
    self.status = 'rejected'
    self.reject_reason = 'reason'
  end

  def is_rejected?
    'rejected' == self.status
  end

  # create a message asynchronously 
  def create_approval_msg(admin = nil)
    params = { 
        :msg_type => 'promotion_approval_notify',
        :msg_body => {
          :title => 'Promotion Approved',
          :message => "[ #{ self.title } ] has been approved",
          :promotion_id => self.get_id,
          :promotion_type => self.title,
          :promotion_description => self.description,
          :msg_type => 'promotion_approval_notify'
        },
        :receiver_id => self.customer.get_id,
        :sender_id => if admin.nil? then nil else admin.get_id end
    }
    message = Message.new(params)
    message.save
  end
  # handle_asynchronously :create_approval_msg, :run_at => Proc.new { 3.minutes.from_now }

  # create a message asynchronously 
  def create_rejection_msg(admin = nil)
    params = { 
        :msg_type => 'promotion_rejection_notify',
        :msg_body => {
          :title => 'Promotion Rejected',
          :message => "[ #{ self.title } ] has been rejected. please see email for details",
          :promotion_id => self.get_id,
          :promotion_type => self.title,
          :promotion_description => self.description,
          :msg_type => 'promotion_rejection_notify'
        },
        :receiver_id => self.customer.get_id,
        :sender_id => if admin.nil? then nil else admin.get_id end
    }
    message = Message.new(params)
    message.save
  end
  # handle_asynchronously :create_rejection_msg, :run_at => Proc.new { 3.minutes.from_now }

  # send email to admin users, when a new promotion is created
  def send_email
    PromotionMailer.notify_admin(self).deliver_now!
  end
  # handle_asynchronously :send_email, :run_at => Proc.new { 1.minutes.from_now }

  def index_terms
    Term.index_promotion_on_demand(self)
  end
  # handle_asynchronously :index_terms, :run_at => Proc.new { 3.minutes.from_now }

  def set_coordinates
    self.coordinates = self.customer.coordinates
    return true
  end

  class << self
    def by_category(catagory_id)
      category = Catagory.find(catagory_id)
      if category.present? and category.promotions.count > 0
        category.promotions
      else
        []
      end
    end
  end

end
