
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

  geocoded_by :coordinates           # can also be an IP address
  # after_validation :geocode          # auto-fetch coordinates

  after_create :send_email
  before_save :set_coordinates, :set_subscripted_status
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

  # index({ coordinates: "2d" })

  # mark this model as reteable
  rate_config range: (0..5), raters: [User, Anonymity]

  has_one  :cover, class_name: 'Image'
  has_many :reviews, inverse_of: :promotion, class_name: 'Review'
  belongs_to :catagory
  belongs_to :customer, class_name: 'User', inverse_of: :promotions

  # sunspot
  searchable do
    text :title, :description, :keywords
    text :catagory do
      catagory.name
    end

    time :expire_at, :start_at
    string :status

    string :id do
      get_id
    end

    boolean :subscripted

    latlon(:location){
      Sunspot::Util::Coordinates.new(lat , lon)
    }
  end

  def set_subscripted_status
    self.subscripted = self.subscripted?
    return true;
  end

  def subscripted?
    self.customer && self.customer.subscriptions.any? { |s| s.activate? }
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

  def send_email
    PromotionMailer.notify_admin(self).deliver_now!
  end
  handle_asynchronously :send_email, :run_at => Proc.new { 1.minutes.from_now }

  def index_terms
    Term.index_promotion_on_demand(self)
  end
  handle_asynchronously :index_terms, :run_at => Proc.new { 3.minutes.from_now }

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
