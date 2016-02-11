#!/usr/bin/ruby
# @Author: dingxizheng
# @Date:   2016-02-10 20:23:53
# @Last Modified by:   dingxizheng
# @Last Modified time: 2016-02-10 21:07:43
# 
class V1::SubscribablesController < ApplicationController
  # always put this at top
  include VoteableActions
  voteable :sub

  include TaggableActions
  taggable :sub

  include FollowableActions
  followable :sub

  before_action :restrict_access, except: [:index, :show,]
  before_action :set_sub, except: [:create, :index]
  before_action :set_owner

  def index
    @subs = Subscribable.query_by_params(query_params)
                    .query_by_text(search)
                    .sortby(sortBy)
                    .paginate(page, per_page)

    render_json "subscribables/subscribables", :locals => { :subscribables => @subs }
  end

  def show
    render_json 'subscribables/subscribable_full', :locals => { :subscribable => @sub }
  end

  def create
    @sub = current_user.subscribables.new(sub_params)
    current_user.follow @sub
    raise UnprocessableEntityError.new(@sub.errors) unless @sub.save  
    moderatorize current_user, @sub
    render_json 'subscribables/subscribable_full', :locals => { :subscribable => @sub }, status: :created
  end

  def update
    raise UnprocessableEntityError.new(@sub.errors) unless @sub.update(sub_params)     
    render_json 'subscribables/subscribable_full', :locals => { :subscribable => @sub }
  end

  def destroy
    @sub.destroy
    head :no_content
  end

  private
  def set_sub
    @sub = Subscribable.find(params[:id] || params[:subscribable_id])
    raise NotfoundError.new(I18n.t('errors.requests.default_not_found') % request.path) if @sub.nil?
  end

  def set_owner
    @owner = User.find(params[:user_id] || "")
  end

  def sub_params
    params.permit(:name, :description, :maximum_price, :minimum_price, :tags => [])
  end

end