class Rater
  include Mongoid::Document
  include Mongoid::Timestamps

  field :user, type: String
  field :type, type: String, default: 'id'
  field :rating, type: Integer, default: 0
  field :expire_at, type: DateTime, default: DateTime.now + 5.hours

  # validaters
  validates :user, uniqueness: true

  def self.rated?(identity, type='id')
    Rater.where(:user => identity).where(:type => type).first
  end

  def unrate
    self.destroy
  end

  def expire?
    DateTime.now > self.expire_at
  end

  def refresh
    self.expire_at = DateTime.now + 5.hours
  end

  def get_id
  	self.id.to_s
  end

end