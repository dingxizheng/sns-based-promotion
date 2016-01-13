require 'digest'
class Session
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Encryptable

  resourcify

  # filters
  before_create :generate_access_token
 
  # for security concern:
  #   only hashed access_token will be stored
  field :access_token_hashed, type: String
  
  # session can only last for 10 days
  field :expire_at, type: DateTime, default: DateTime.now + 240.hours

  field :provider, type: String
  field :provider_access_token, type: String

  # encrypted fileds
  encryptable :provider_access_token

  # relations
  belongs_to :user
  belongs_to :device

  # validaters
  validates :access_token_hashed, uniqueness: true

  # return true if session expires
  def expire?
  	DateTime.now > self.expire_at
  end

  # when a valid token is received, refresh the session
  def refresh
    # self.expire_at = DateTime.now + 24.hours 
    # will be implemented later
  end

  # return access_token
  def access_token
    @access_token
  end

  # return true if access token is matched
  def access_token_match?(access_token)
    self.access_token_hashed == Digest::SHA2.hexdigest(access_token)
  end
 
  private
    def generate_access_token
      begin
        # access_token will not be stored
        @access_token = SecureRandom.hex()
        self.access_token_hashed = Digest::SHA2.hexdigest(@access_token)
      end while self.class.where(access_token_hashed: self.access_token_hashed).exists?
    end

end
