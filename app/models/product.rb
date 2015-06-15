class Product
  include Mongoid::Document
  include Mongoid::Timestamps

  field :price, type: Float
  field :name,  type: String
  field :description, type: String
  field :time, type: Integer

  def get_hash
    {
      :price => self.price,
      :name => self.name,
      :description => self.description,
      :time => self.time
    }
  end

  def get_id
  	self.id.to_s
  end

end