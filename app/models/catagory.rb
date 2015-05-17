class Catagory

  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String

  has_many :promotion
  has_one :icon, class_name: 'Image'

  def initialize(args = nil)
    super(args.except!(:icon)) unless args.nil?
    super(nil) if args.nil?
    self.set_icon(args[:icon]) if args[:icon].present?
  end

  # set icon
  def set_icon(upload)
    # create a new image record
    icon = Image.new
    if not icon.store(upload) or not icon.save
      self.errors.add :icon, upload.original_filename + ': could not set icon.'
      return false
    end
    self.icon = icon
    return true
  end

  validates_uniqueness_of :name
  validates_length_of :name, minimum: 4, maximum: 30

  def get_id
    self.id.to_s
  end

end
