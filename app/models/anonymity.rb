class Anonymity
  include Mongoid::Document
  include Mongoid::Timestamps

  field :ip, type: String
  
  def get_id
  	self.id.to_s
  end

end