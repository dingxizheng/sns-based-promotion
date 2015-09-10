class Anonymity
  include Mongoid::Document
  include Mongoid::Timestamps

  field :ip, type: String

end