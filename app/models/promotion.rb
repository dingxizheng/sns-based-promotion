class Promotion
  include Mongoid::Document
  include Mongoid::Timestamps
  include Sunspot::Mongoid2

  resourcify

  # fields
  field :title, type: String
  field :description, type: String
  field :status, type: String, default: 'submitted'
  field :rating, type: Float, default: 0
  field :rates,  type: Integer, default: 0 
  field :rating_sum, type: Integer, default: 0
  field :reject_reason, type: String, default: 'unknown'
  field :start_at, type: DateTime, default: Time.now
  field :expire_at, type: DateTime, default: Time.now + 2.weeks

  belongs_to :catagory
  belongs_to :customer, class_name: 'User', inverse_of: :promotions

  # sunspot
  searchable do  
    text :title, :description
    time :expire_at, :start_at
    string :status

    string :id do 
      get_id
    end

    boolean :subscripted do
      subscripted?
    end

    latlon(:location){
      Sunspot::Util::Coordinates.new(lat , lon)
    }
  end

  def subscripted?
    self.customer.subscriptions.any? { |s| s.activate? }
  end

  def lon
    self.customer.lon
  end
 
  def lat
    self.customer.lat 
  end

  def rate(num, identity, type='id')
    rated = Rater.rated?(identity, type)
    # unrate
    if rated.present? and not rated.expire?
      self.rates -= 1
      self.rating_sum -= rated.rating
      if self.rates > 0
        self.rating = self.rating_sum / self.rates
      else
        self.rating = 0
        self.rating_sum = 0
        self.rates = 0
      end
      rated.unrate
    elsif rated.present? and rated.expire?
      self.rates += 1
      self.rating_sum += num
      self.rating = self.rating_sum / self.rates
      rated.rating = num
      rated.refresh
      rated.save
    else
      self.rates += 1
      self.rating_sum += num
      self.rating = self.rating_sum / self.rates
      
      rated = Rater.new({ :rating => num, :user => identity, :type => type })
      rated.save
    end
    self.save
  end

  def approve
    self.status = 'reviewed'
  end

  def is_reviewed?
    'reviewed' == self.status
  end

  def reject(reason)
    self.status = 'rejected'
    self.reject_reason = 'reason'
  end

  def is_rejected?
    'rejected' == self.status
  end

  def get_id
  	self.id.to_s
  end

end
