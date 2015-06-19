class Token
  include Mongoid::Document

  field :token, type: String

  def get_id
    self.id.to_s
  end

end
