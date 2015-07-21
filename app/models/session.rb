class Session
  include Mongoid::Document
  include Mongoid::Timestamps

  resourcify

  # filters
  before_create :generate_access_token
 
  # fields
  field :access_token, type: String
  field :expire_at, type: DateTime, default: DateTime.now + 24.hours

  # relations
  belongs_to :user

  # validaters
  validates :access_token, uniqueness: true

  # return true if session expires
  def expire?
  	DateTime.now > self.expire_at
  end

  # when a valid token is received, refresh the session
  def refresh
    self.expire_at = DateTime.now + 24.hours
  end
 
  private
    def generate_access_token
      begin
        self.access_token = SecureRandom.hex
      end while self.class.where(access_token: access_token).exists?
    end

end
