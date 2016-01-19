class Promotion
  include Mongoid::Document
  include Mongoid::Timestamps
  include Sunspot::Mongoid2
  include Mongoid::Likeable
  include Mongoid::Taggable
  include Mongoid::Enum
  include Geocoder::Model::Mongoid
  include Mongoid::QueryHelper
  include Mongoid::GeoHelper
  include Mongoid::Encryptable

  geocoded_by :coordinates
  before_save :set_coordinates
  before_destroy :destroy_children

  resourcify

  # fields
  field :title, type: String
  field :description, type: String
  field :coordinates, type: Array
  field :start_at, type: DateTime, default: Time.now
  field :expire_at, type: DateTime, default: Time.now + 2.weeks
  field :cover_id

  enum :status, [:approved, :pending, :declined]

  encryptable :title, :description

  tags_separator ';'

  belongs_to :customer

  has_one  :video
  has_many :comments
  has_many :photos, inverse_of: :promotion, class_name: 'Image'

  # if fulltext search on promotion model is enabled
  if Settings.sunspot.enable_promotion
  	# sunspot config 
  	searchable do
  	    text :title, :description, :tags
  	    time :expire_at, :start_at 
  	    string :status
  	    string :id do
  	      get_id
  	    end
  	    latlon(:location){
  	      Sunspot::Util::Coordinates.new(lat, lon)
  	    }
  	end

    after_save :index_terms
    # to enable the 
    def index_terms
      Term.index_promotion_on_demand(self)
    end
  end

  # retrieve longtitude info
  def lon
    if not self.coordinates.nil? then self.coordinates[0] else 0 end
  end

  # retrieve latitude info
  def lat
    if not self.coordinates.nil? then self.coordinates[1] else 0 end
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
