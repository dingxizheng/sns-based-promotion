#!/usr/bin/ruby
# @Author: dingxizheng
# @Date:   2016-02-10 15:55:18
# @Last Modified by:   dingxizheng
# @Last Modified time: 2016-02-10 21:00:57

class Subscribable
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Search
  include Mongoid::Likeable
  include Mongoid::Followable
  include Mongoid::Taggable
  include Mongoid::QueryHelper

  # fields
  field :name,          type: String
  field :description,   type: String
  field :maximum_price, type: Float, default: 1000000000
  field :minimum_price, type: Float, default: -100

  belongs_to :user, inverse_of: :subscribables, class_name: 'User'

  # validates_presence_of :nam
  validates_length_of :name, minimum: 1, maximum: 100, allow_blank: true
  validates_length_of :description, minimum: 10, maximum: 300, allow_blank: true

  # mongoid full text search
  search_in :name, :description

  # # if fulltext search on tags is enabled
  # if Settings.sunspot.enable_subscriptable
  #   # sunspot config 
  #   searchable do
  #       text :body, :decription
  #       time :created_at, :updated_at
  #       string :status
  #       string :id do
  #         get_id
  #       end
  #   end
  # end

  private

end
