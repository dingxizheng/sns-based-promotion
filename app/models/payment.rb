class Payment
  include Mongoid::Document
  include Mongoid::Timestamps

  field :amount, type: Float

end