#!/usr/bin/ruby
# @Author: dingxizheng
# @Date:   2016-01-17 16:31:19
# @Last Modified by:   dingxizheng
# @Last Modified time: 2016-01-20 15:10:25

class Tag
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Search
  include Mongoid::Likeable
  include Mongoid::Followable
  include Mongoid::TagModel
  include Mongoid::Enum
  include Mongoid::QueryHelper

  # fields
  field :body,       type: String
  field :decription, type: String
  field :category,   type: Boolean, :default => false

  enum :status, [:approved, :pending, :declined]

  validates_presence_of :body
  validates_length_of :body, minimum: 1, maximum: 100
  validate :tag_format

  # mongoid full text search
  search_in :body

  # if fulltext search on tags is enabled
  if Settings.sunspot.enable_tag
    # sunspot config 
    searchable do
        text :body, :decription
        time :created_at, :updated_at
        string :status
        string :id do
          get_id
        end
    end
  end

  private
  def tag_format
  	unless (/[\<\>@!#$%^&*()_\\+\[\]{}?:;|'"\.\/~`-]/ =~ self.body).nil?
  		self.errors.add(:body, I18n.t('errors.validations.tag'))
  	end
  end

end
