class ImagesController < ApplicationController

  before_action :restrict_access, only: [:create]
  before_action :set_image, only: [:show]
  before_action :set_user, except: []

  def show
    render :partial => 'images/image', :locals => { :image => @image }
  end

  def create
    # create a new image record
    @image = Image.new
    @image.store(params[:image])
    raise UnprocessableEntityError.new(@image.errors) unless @image.save
    render :partial => 'images/image', :locals => { :image => @image }
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_image
    @image = Image.find(params[:id] || params[:image_id])
    raise NotfoundError.new('Image', { :id => params[:id] || params[:image_id] }.to_s ) unless @image
  end

  # load customer resources
  def set_user
    if params[:user_id]
      @user = User.find(params[:user_id])
      raise NotfoundError.new('User', { :id => params[:user_id] }.to_s ) unless @user
    else
      @user = current_user
    end
  end

end
