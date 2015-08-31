class Term
  include Mongoid::Document
  include Mongoid::Timestamps
  include Sunspot::Mongoid2

  # fields
  field :term, type: String
  field :searchs, type: Integer, default: 0
  field :type, type: String

  # sunspot
  searchable do  
    
    text :term
    string :term, stored: true
    string :type
    integer :searchs

  end

  validates_uniqueness_of :term

  def self.index_user(user)
    Term.find_or_create_by(term: user.name, type: 'name')
    Term.find_or_create_by(term: user.email, type: 'email')
    Term.find_or_create_by(term: user.phone, type: 'phone') unless user.phone.nil?
    user.name.split(' ').each {|t|  Term.find_or_create_by(term: t, type: 'name') unless t.size < 3 }
    user.keywords.each {|k|  Term.find_or_create_by(term: k, type: 'keyword') unless k.size < 3 }
    user.description.split(' ').each {|w| Term.find_or_create_by(term: w, type: 'description') unless w.size < 5 } unless user.description.nil?
  end

  def self.index_user_on_demand(user)
    Term.find_or_create_by(term: user.name, type: 'name')
    Term.find_or_create_by(term: user.email, type: 'email')
    Term.find_or_create_by(term: user.phone, type: 'phone') unless user.phone.nil?
    user.name.split(' ').each {|t|  Term.find_or_create_by(term: t, type: 'name') unless t.size < 3 }
    user.keywords.each {|k|  Term.find_or_create_by(term: k, type: 'keyword') unless k.size < 3 }
    user.description.split(' ').each {|w| Term.find_or_create_by(term: w, type: 'description') unless w.size < 5 } unless user.description.nil?
  end

  def self.index_promotion(promotion)
    Term.find_or_create_by(term: promotion.title, type: 'title')
    Term.find_or_create_by(term: promotion.catagory.name, type: 'catagory')
    promotion.title.split(' ').each {|t|  Term.find_or_create_by(term: t, type: 'title') unless t.size < 3 }
    promotion.description.split(' ').each {|w| Term.find_or_create_by(term: w, type: 'description') unless w.size < 5 } unless promotion.description.nil?
  end

  def self.index_promotion_on_demand(promotion)
    Term.find_or_create_by(term: promotion.title, type: 'title')
    Term.find_or_create_by(term: promotion.catagory.name, type: 'catagory')
    promotion.title.split(' ').each {|t|  Term.find_or_create_by(term: t, type: 'title') unless t.size < 3 }
    promotion.description.split(' ').each {|w| Term.find_or_create_by(term: w, type: 'description') unless w.size < 5 } unless promotion.description.nil?
  end

end
