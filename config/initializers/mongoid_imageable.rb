#!/usr/bin/ruby
# @Author: dingxizheng
# @Date:   2016-01-18 20:04:41
# @Last Modified by:   dingxizheng
# @Last Modified time: 2016-01-18 21:08:03

module Mongoid
  # geo helper module
  module Imageable
    extend ActiveSupport::Concern

    module ClassMethods

    	# include do
    	# 	attr_accessible :avatar_file
    	# end

    	def imageable(*fields)
    		fields = fields.is_a?(Enumerable) ? fields : [fields]

    		fields.each{ |field_name| 
    			
    			if self.fields["#{field_name.to_s}_id".to_sym].nil?
    				define_method("set_#{field_name}") do |value|
    					if value.kind_of? String
    						image_to_add = Image.find(value)
    						(self["#{field_name.to_s}_id".to_sym] = image_to_add.get_id) if image_to_add.present?
    					elsif value.respond_to? "read"
    						image_to_add = Image.new({
    								:file => value
    							})
    						if image_to_add.save
    							self["#{field_name.to_s}_id".to_sym] = image_to_add.get_id
    						else
    							errors = image_to_add.errors.to_hash
    							errors.each do |key, error|
    								puts "#{key} >>> #{error}"
    								self.errors.add(key.to_sym, error[0])	
    							end		
    						end
    					end
			        end
    			end
    		}

    	end

    end

  end
end