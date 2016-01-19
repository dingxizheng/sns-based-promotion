#!/usr/bin/ruby
# @Author: dingxizheng
# @Date:   2016-01-17 00:39:39
# @Last Modified by:   dingxizheng
# @Last Modified time: 2016-01-18 16:51:48

# This module introduces
# 	tag and untag actions to controllers
#
module TaggableActions
  extend ActiveSupport::Concern

  class_variable_set(:@@before_callbacks, [])
  class_variable_set(:@@taggable, nil)
  class_variable_set(:@@taggable_param, "tags")

  class_variable_set(:@@after_tag, :render_after_tag)
  class_variable_set(:@@after_untag, :render_after_untag)

  # POST /tag
  def tag
    self.class.class_variable_get(:@@before_callbacks).each {|cb| send(cb) }
    get_taggable.add_tags get_tags
    send(self.class.class_variable_get(:@@after_tag))
  end

  # POST /untag
  def untag
    self.class.class_variable_get(:@@before_callbacks).each {|cb| send(cb) }
    get_taggable.remove_tags get_tags
    send(self.class.class_variable_get(:@@after_untag))
  end

  def render_after_tag
  	render :json => { :tags => get_taggable.tags }
  end

  def render_after_untag
  	render :json => { :tags => get_taggable.tags }
  end

  private
  def get_tags
  	tags_name = self.class.class_variable_get(:@@taggable_param)
  	params[tags_name.to_sym]
  end

  def get_taggable
  	instance_variable_get(:"@#{@@taggable.to_s}")
  end

  module ClassMethods

    def before_tag(*actions)
      current_actions = self.class_variable_get(:@@before_callbacks)
      self.class_variable_set(:@@before_callbacks, current_actions | actions)
    end

    def taggable(resource)
      self.class_variable_set(:@@taggable, resource)
    end

    def taggable_param(param_name)
      self.class_variable_set(:@@taggable_param, param_name)
    end

    def after_tag(method_name)
    	self.class_variable_set(:@@after_tag, model_name)
    end

    def after_untag(method_name)
    	self.class_variable_set(:@@after_untag, model_name)
    end

  end

end

module Mongoid
  @@taggable_models = []
  @@init_callback = nil
  module Taggable
    extend ActiveSupport::Concern

    class_variable_set(:@@tags_separator, ",")
    class_variable_set(:@@maximun_tags, 20)

    included do
	  models = Mongoid.class_variable_get(:@@taggable_models)
	  Mongoid.class_variable_set(:@@taggable_models, models << self.name.to_s.downcase)
	  Mongoid.class_variable_get(:@@init_callback).call(self.name.to_s.downcase) if Mongoid.class_variable_get(:@@init_callback)

      field :tags, type: Array, default: []
      has_and_belongs_to_many :tag_objects , class_name: 'Tag', autosave: true
      # belongs_to :tag_model, as:, class_name: 'Tag'
    end

    module ClassMethods
      def tags_separator(separator)
        if separator.kind_of? String
          self.class_variable_set(:@@tags_separator, separator)
        else
          raise ArgumentError.new("Only strings are allowed")
        end
      end

      def maximun_tags(num)
        if separator.is_a? Integer
          self.class_variable_set(:@@maximun_tags, num)
        else
          raise ArgumentError.new("Only numbers are allowed")
        end
      end
    end

    def tags=(tags)
      if tags.respond_to? "each"
        if tags.size < 1
          self.tags = []
        elsif tags.all? {|tag| tag.kind_of? String }
          set_array tags
        elsif tags.all? {|tag| tag.is_a? Tag }
          set_array tags.map(&:body)
        else
          raise ArgumentError.new("The type of items in array should be either a Tag or a String")
        end
      elsif tags.kind_of? String
        set_array tags.split(self.class.class_variable_get(:@@tags_separator))
      else
        raise ArgumentError.new("Only arrays are allowed")
      end
    end

    def add_tags(tags)
      if tags.respond_to? "each"
        if tags.size < 1
          return
        elsif tags.all? {|tag| tag.kind_of? String }
          add_array tags
        elsif tags.all? {|tag| tag.is_a? Tag }
          add_tags(tags.map(&:body))
        else
          raise ArgumentError.new("The type of items in array should be either a Tag or a String")
        end
      elsif tags.kind_of? String
        add_array tags.split(self.class.class_variable_get(:@@tags_separator))
      else
        raise ArgumentError.new("Only arrays are allowed")
      end
    end

    def remove_tags(tags)
      if tags.respond_to? "each"
      	 if tags.size < 1
      	 	return
	     elsif tags.all? {|tag| tag.kind_of? String }
	     	remove_array tags
	     elsif tags.all? {|tag| tag.is_a? Tag }
	     	remove_tags(tags.map(&:body))
	     else
	     	raise ArgumentError.new("The type of items in array should be either a Tag or a String")
	     end
	  elsif tags.kind_of? String
	  	remove_array tags.split(self.class.class_variable_get(:@@tags_separator))
	  else
	  	raise ArgumentError.new("Only arrays are allowed")
      end			
    end

    private
    def add_models_to_tag(tag)
       method_name = self.class.name.downcase + 's'
       tag.send(method_name + '=', tag.send(method_name) + [self])
    end

    def remove_models_from_tag(tag)
       method_name = self.class.name.downcase + 's'
       tag.send(method_name + '=', tag.send(method_name) - [self])
    end

    def set_array(tags)
      self[:tags] = tags
      self.save if self.new_record?
      self.tag_objects = [];
      tags.each{ |tag|
      	tag_to_add = Tag.find_or_create_by(body: tag)
      	add_models_to_tag(tag_to_add)
        self.tag_objects += [tag_to_add]
      }
      self.save
    end

    def add_array(tags)
      self[:tags] = self[:tags] | tags
      self.save if self.new_record?
      tags.each { |tag|
      	tag_to_add = Tag.find_or_create_by(body: tag)
      	add_models_to_tag(tag_to_add)
        self.tag_objects += [tag_to_add]
      }
      self.save
    end

    def remove_array(tags)
    	self[:tags] = self[:tags] - tags
    	self.save if self.new_record?
    	tags.each { |tag|
	      	tag_to_remove = Tag.find_by(body: tag)
	      	if tag_to_remove.present?
		      	remove_models_from_tag(tag_to_remove)
		        self.tag_objects -= [tag_to_remove]
		    end
	    }
	    self.save
    end

  end

  module TagModel
    extend ActiveSupport::Concern

    included do

      # for each model
      Mongoid.class_variable_get(:@@taggable_models).each do |model_name|
      	add_relations_to_model(model_name)
      end

      Mongoid.class_variable_set(:@@init_callback, method(:add_relations_to_model))
   
    end

    module ClassMethods

      def add_relations_to_model(model_name)
      	puts "ADD RELATION TO MODEL #{model_name}"
      	has_and_belongs_to_many "#{model_name}s".to_sym
      end

      def make_as_tag_model
      	# has_and_belongs_to_many :taggables, :polymorphic => true
      end
    end

  end
end
