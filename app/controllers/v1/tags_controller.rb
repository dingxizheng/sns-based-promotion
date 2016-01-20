#!/usr/bin/ruby
# @Author: dingxizheng
# @Date:   2016-01-19 17:49:11
# @Last Modified by:   dingxizheng
# @Last Modified time: 2016-01-20 15:19:45
class V1::TagsController < ApplicationController
	
	before_action :set_tag, :except => [:index]

	def index
		@tags = Tag.query_by_params(query_params)
		           .query_by_text(search)
	               .sortby(sortBy)
	               .paginate(page, per_page)
    	render_json "tags/tags", :locals => { :tags => @tags }
	end

	def show
		render_json "tags/tag", :locals => { :tag => @tag }
	end

	def update
	end

	private
	def set_tag
		@tag = Tag.find(params[:id] || params[:tag_id])
		@tag ||= Tag.find_by(:body => (params[:id] || params[:tag_id]))
		raise NotfoundError.new(I18n.t('errors.requests.default_not_found') % request.path) if @tag.nil?
	end

end