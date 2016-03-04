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
  include PublicActivity::Common
  # include Mongoid::Encryptable

  geocoded_by         :address
  before_validation   :geocode, if: ->(obj){ obj.address_changed? or obj.coordinates.nil? or (obj.coordinates.present? and obj.coordinates[0].nil?) }
  # geocoded_by           :address

  after_save    :set_ancestors
  after_create  :add_create_activity, :add_subscribable_activity
  after_update  :add_update_activity
  after_destroy :add_destroy_activity
  after_destroy :destroy_children

  resourcify

  # fields
  field :body, type: String
  field :coordinates, type: Array
  field :address, type: String
  field :price, type: Float, default: -1
  field :start_at, type: DateTime, default: Time.now
  field :expire_at, type: DateTime, default: Time.now + 2.weeks
  
  # field :cover_id

  enum :status, [:approved, :pending, :declined, :expired, :ongoing, :deleted], :multiple => true, :default => [:approved]

  tags_separator ';'

  count_relations :leaves, :reposts, :ancestors, :comments, :photos, :likers, :dislikers, :tag_objects

  belongs_to :user, inverse_of: :promotions, class_name: 'User'

  belongs_to :root, inverse_of: :leaves , class_name: 'Promotion'
  has_many   :leaves, inverse_of: :root, class_name: 'Promotion'

  belongs_to :parent, inverse_of:  :reposts, class_name: 'Promotion'
  has_many   :reposts, inverse_of: :parent,  class_name: 'Promotion'

  
  has_and_belongs_to_many  :ancestors, class_name: 'Promotion'
  # has_and_belongs_to_many  :descendants, inverse_of: :ancestors, class_name: 'Promotion'

  has_one  :video, autosave: true, dependent: :destroy
  has_many :comments, inverse_of: :commentee, class_name: 'Comment', autosave: true, dependent: :destroy
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

  alias longitude lon

  # retrieve latitude info
  def lat
    if not self.coordinates.nil? then self.coordinates[1] else 0 end
  end

  alias latitude lat

  # private

  def set_ancestors
    if self.parent.present? and self.root.nil?
      self.root = (self.parent.root || self.parent)
      self.ancestors = self.parent.ancestors
      self.ancestors << self.parent
      self.save
    end
  end

  def add_create_activity
    if self.parent.present?
      self.create_activity key: 'promotion.reposted', owner: self.user, recipient: self.parent.user 
    else
      self.create_activity key: 'promotion.created', owner: self.user, recipient: nil
    end
  end
  handle_asynchronously :add_create_activity, :run_at => Proc.new { 2.minutes.from_now }

  def add_update_activity
    # if self.body_changed?
    #   self.create_activity key: 'promotion.updated', owner: self.user
    # end
  end

  def add_subscribable_activity
    if self.tags.size > 1
      quries = []
      2.upto(self.tags.size) do |s|
        self.tags.combination(s).to_a.each do |arr|
          quries << {:tags.all => arr}
        end
      end
      if quries.size > 0
        Subscribable.or(*quries).and({:minimum_price.lte => self.price}, {:maximum_price.gte => self.price}).each do |sub|
          self.create_activity key: 'promotion.subscribable.new', owner: sub, recipient: self.user
        end
      end
    end
  end
  handle_asynchronously :add_subscribable_activity, :run_at => Proc.new { 2.minutes.from_now }

  def add_destroy_activity
    # self.create_activity key: 'promotion.deleted', owner: self.user
  end

  # destroy all children
  def destroy_children

  end

end
