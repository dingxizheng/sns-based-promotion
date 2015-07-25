Dir["#{Rails.root}/lib/modules/mongoid_rateable/*.rb"].each {|file| require file }
require 'rake'

class Promotion
  include Mongoid::Document
  include Mongoid::Timestamps
  include Sunspot::Mongoid2
  include Mongoid::Rateable
  include Geocoder::Model::Mongoid

  geocoded_by :coordinates           # can also be an IP address
  after_validation :geocode          # auto-fetch coordinates

  after_create :send_email
  before_save  :set_coordinates

  after_save   :reindex_coordinates

  resourcify

  # fields
  field :title, type: String
  field :description, type: String
  field :status, type: String, default: 'submitted'
  field :reject_reason, type: String, default: 'unknown'
  field :coordinates, type: Array
  field :start_at, type: DateTime, default: Time.now
  field :expire_at, type: DateTime, default: Time.now + 2.weeks

  index({ coordinates: "2d" })

  # mark this model as reteable
  rate_config range: (0..5), raters: [User, Anonymity]

  has_many :reviews, inverse_of: :promotion, class_name: 'Review'

  belongs_to :catagory
  belongs_to :customer, class_name: 'User', inverse_of: :promotions

  # sunspot
  searchable do  
    text :title, :description
    time :expire_at, :start_at
    string :status

    string :id do 
      get_id
    end

    boolean :subscripted do
      subscripted?
    end

    latlon(:location){
      Sunspot::Util::Coordinates.new(lat , lon)
    }
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

  def get_id
  	self.id.to_s
  end

  def send_email
    Thread.start {
      PromotionMailer.notify_admin(self).deliver_now!
    }
  end

  # reindex coordinates after save
  def reindex_coordinates
    if self.coordinates_changed?
      Rake::Task['db:mongoid:create_indexes'].invoke
    end
  end

  def set_coordinates
    self.coordinates = self.customer.coordinates
  end

end
