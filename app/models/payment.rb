class Payment
  include Mongoid::Document
  include Mongoid::Timestamps

  field :amount, type: Float

  def get_id
  	self.id.to_s
  end

end