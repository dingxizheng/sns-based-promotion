#!/usr/bin/ruby
# @Author: dingxizheng
# @Date:   2016-01-18 20:04:41
# @Last Modified by:   dingxizheng
# @Last Modified time: 2016-01-19 17:12:15

module Mongoid
  # geo helper module
  module FileUploader
    extend ActiveSupport::Concern

    module ClassMethods

    	# include do
    	# 	attr_accessible :avatar_file
    	# end

    	def imageable(*fields)
    		fields = fields.is_a?(Enumerable) ? fields : [fields]
    		fields.each{ |field_name| 	
    			if self.fields["#{field_name.to_s}_id".to_sym].nil?
    				fileable(field_name, Image)
    			end
    		}
    	end

    	def videoable(*fields)
    		fields = fields.is_a?(Enumerable) ? fields : [fields]
    		fields.each{ |field_name|		
    			if self.fields["#{field_name.to_s}_id".to_sym].nil?
    				fileable(field_name, Video)
				end
    		}
    	end

    	private
    	def fileable(field_name, model)
    		define_method("set_#{field_name}") do |value|
    			if value.respond_to? "each" and not value.respond_to?("read")
    				puts "value >>> #{ value }"
    				self.save if self.new_record?
    				self.send("#{field_name}=", [])
    				files = self.send("#{field_name}")
    				value.each do |file|
    					if file.kind_of? String
    						file_to_add = model.find(file)
    						files << file_to_add
    					else file.respond_to? "read"
    						file_to_add = model.new({
								:file => file
							})
							if file_to_add.save
								files << file_to_add
							else
								errors = file_to_add.errors.to_hash
								errors.each do |key, error|
									puts "#{key} >>> #{error}"
									self.errors.add(key.to_sym, error[0])	
								end		
							end
    					end
    				end
    			else
					if value.kind_of? String
						file_to_add = model.find(value)
						self.send("#{field_name}=", file_to_add) if file_to_add.present?
					elsif value.respond_to? "read"
						file_to_add = model.new({
								:file => value
							})
						if file_to_add.save
							self.send("#{field_name}=", file_to_add)
						else
							errors = file_to_add.errors.to_hash
							errors.each do |key, error|
								puts "#{key} >>> #{error}"
								self.errors.add(key.to_sym, error[0])	
							end		
						end
					end
				end
			end
    	end

    end

  end
end