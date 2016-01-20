class Promotion
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Search
  include Sunspot::Mongoid2
  include Mongoid::Likeable
  include Mongoid::Taggable
  include Mongoid::Enum
  include Geocoder::Model::Mongoid
  include Mongoid::QueryHelper
  include Mongoid::GeoHelper
  include Mongoid::FileUploader
  include Mongoid::RelationCounter
  # include Mongoid::Encryptable

  geocoded_by :coordinates
  after_save  :set_ancestors
  before_destroy :destroy_children

  resourcify

  # fields
  field :body, type: String
  field :coordinates, type: Array
  field :start_at, type: DateTime, default: Time.now
  field :expire_at, type: DateTime, default: Time.now + 2.weeks
  
  # field :cover_id

  enum :status, [:approved, :pending, :declined, :expired, :ongoing, :deleted], :multiple => true

  tags_separator ';'

  count_relations :leaves, :reposts, :ancestors, :comments, :photos

  belongs_to :user

  belongs_to :root, inverse_of: :leaves , class_name: 'Promotion'
  has_many   :leaves, inverse_of: :root, class_name: 'Promotion'

  belongs_to :parent, inverse_of:  :reposts, class_name: 'Promotion'
  has_many   :reposts, inverse_of: :parent,  class_name: 'Promotion'

  
  has_and_belongs_to_many  :ancestors, class_name: 'Promotion'
  # has_and_belongs_to_many  :descendants, inverse_of: :ancestors, class_name: 'Promotion'

  has_one  :video, autosave: true, dependent: :destroy
  has_many :comments, autosave: true, dependent: :destroy
  has_many :photos, inverse_of: :promotion, class_name: 'Image', autosave: true, dependent: :destroy

  validates_presence_of :body
  validates_length_of :body, minimum: 1, maximum: 300

  imageable :photos
  videoable :video

  # mongoid full text search
  search_in :body, :user => :name, :parent => :body

  # if fulltext search on promotion model is enabled
  if Settings.sunspot.enable_promotion
  	# sunspot config 
  	searchable do
  	    text :body, :tags
  	    time :expire_at, :start_at, :created_at, :updated_at
  	    string :status
  	    string :id do
  	      get_id
  	    end
  	    latlon(:location){
  	      Sunspot::Util::Coordinates.new(lat, lon)
  	    }
  	end

    # after_save :index_terms
    # # to enable the 
    # def index_terms
    #   Term.index_promotion_on_demand(self)
    # end
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

  def set_ancestors
    if self.parent.present? and self.root.nil?
      self.root = (self.parent.root || self.parent)
      self.ancestors = self.parent.ancestors
      self.ancestors << self.parent
      self.save
    end
  end

  # destroy all children
  def destroy_children

  end

end
