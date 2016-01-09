class Promotion
  include Mongoid::Document
  include Mongoid::Timestamps
  include Sunspot::Mongoid2
  include Mongo::Voteable
  include Geocoder::Model::Mongoid
  include Mongoid::QueryHelper
  include Mongoid::GeoHelper

  geocoded_by :coordinates

  before_save :set_coordinates
  after_save :index_terms

  before_destroy :destroy_children

  resourcify

  # fields
  field :title, type: String
  field :description, type: String
  field :status, type: String, default: 'submitted'
  field :coordinates, type: Array
  field :start_at, type: DateTime, default: Time.now
  field :expire_at, type: DateTime, default: Time.now + 2.weeks
  field :cover_id

  # set points for each vote
  voteable self, :up => +1, :down => -1

  has_one  :video
  has_many :photos, inverse_of: :promotion, class_name: 'Image'
  has_many :reviews, inverse_of: :promotion, class_name: 'Review'
  belongs_to :customer, class_name: 'User', inverse_of: :promotions

  # sunspot config 
  searchable do
    text :title, :description, :tags

    time :expire_at, :start_at
    
    string :status

    string :id do
      get_id
    end

    latlon(:location){
      Sunspot::Util::Coordinates.new(lat , lon)
    }
  end

  # retrieve longtitude info
  def lon
    if not self.coordinates.nil? then self.coordinates[0] else 0 end
  end

  # retrieve latitude info
  def lat
    if not self.coordinates.nil? then self.coordinates[1] else 0 end
  end

  def index_terms
    Term.index_promotion_on_demand(self)
  end

  private
  # set the coordinates of promotion
  def set_coordinates
    self.coordinates = self.customer.coordinates
    return true
  end

  # destroy all children
  def destroy_children

  end

end
