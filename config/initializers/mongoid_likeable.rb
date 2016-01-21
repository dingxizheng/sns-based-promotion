#!/usr/bin/ruby
# @Author: dingxizheng
# @Date:   2016-01-21 01:08:10
# @Last Modified by:   dingxizheng
# @Last Modified time: 2016-01-21 02:30:55

module Mongoid
  @@set_liker_model_name = nil
  @@set_liker_model_callback = []
  @@set_likeable_model_callback = []
  @@set_likeable_model_names = []
  
  module Likeable
    extend ActiveSupport::Concern

    included do
    	Mongoid.class_variable_get(:@@set_likeable_model_names) << self.name.to_s.downcase
    	Mongoid.class_variable_get(:@@set_liker_model_callback) << method(:add_likers_relation)
    	    	
    	if not Mongoid.class_variable_get(:@@set_liker_model_name).nil?
    		add_likers_relation Mongoid.class_variable_get(:@@set_liker_model_name)
    	end
    	Mongoid.class_variable_get(:@@set_likeable_model_callback).each{ |cb| 
    		cb.call(self.name.to_s.downcase)
    	}

    end

    def likes
    	self.likers.count
    end

    def dislikes
    	self.dislikers.count
    end

    module ClassMethods
    	def add_likers_relation(liker_class)
    		puts "ADDING likers >> #{liker_class} to model #{ self.name.to_s.downcase }"
    		has_and_belongs_to_many :likers, inverse_of: "liked_#{self.name.to_s.downcase}s".to_sym, class_name: liker_class.capitalize, autosave: true
    		has_and_belongs_to_many :dislikers, inverse_of: "dislikedf_#{self.name.to_s.downcase}s".to_sym, class_name: liker_class.capitalize, autosave: true
    	end
    end
  end

  # geo helper module
  module Liker
    extend ActiveSupport::Concern

    puts "LOADS LIKER"
    included do   	
    	Mongoid.class_variable_set(:@@set_liker_model_name, self.name.to_s.downcase)
    	Mongoid.class_variable_get(:@@set_liker_model_callback).each{ |cb| 
    		cb.call(self.name.to_s.downcase)
    	}
    	Mongoid.class_variable_get(:@@set_likeable_model_names).each{ |class_name| 
    		add_likeable_relation class_name
    	}
    	Mongoid.class_variable_get(:@@set_likeable_model_callback) << method(:add_likeable_relation)
    end

    def liked?(likeable)
    	likeable.likers.find_by(:id => likeable.id).present?
    end

    def disliked?(likeable)
    	likeable.likers.find_by(:id => likeable.id).present?
    end

    def like(likeable)
    	if Mongoid.class_variable_get(:@@set_likeable_model_names).include?(likeable.class.to_s.downcase)
    		likeable.likers << self
    		likeable.save
    	end
    end

    def unlike(likeable)
    	if Mongoid.class_variable_get(:@@set_likeable_model_names).include?(likeable.class.to_s.downcase)
    		likeable.likers.delete self
    		likeable.save
    	end
    end

    def dislike(likeable)
    	if Mongoid.class_variable_get(:@@set_likeable_model_names).include?(likeable.class.to_s.downcase)
    		likeable.dislikers << self
    		likeable.save
    	end
    end

    def undislike(likeable)
    	if Mongoid.class_variable_get(:@@set_likeable_model_names).include?(likeable.class.to_s.downcase)
    		likeable.dislikers.delete self
    		likeable.save
    	end
    end

    module ClassMethods
    	def add_likeable_relation(likeable_class)
    		has_and_belongs_to_many "liked_#{likeable_class}s".to_sym, inverse_of: :likers, class_name: likeable_class.capitalize
    		has_and_belongs_to_many "disliked_#{likeable_class}s".to_sym, inverse_of: :dislikers, class_name: likeable_class.capitalize
    		puts "LIKES::#{likeable_class}"
    	end
    end
  end
end
