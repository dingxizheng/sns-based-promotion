class CatagorysController < ApplicationController

  before_action :restrict_access, only: [:create, :update, :destory]
  before_action :set_catagory, except: [:index, :create]

  # GET /catagorys
  # GET /catagorys.json
  def index
    @catagorys = Catagory.all
    render 'catagorys/catagorys', :locals => { :catagorys => @catagorys }
  end

  # POST /catagorys
  # POST /catagorys.json
  def create
    @catagory = Catagory.new(catagory_params)
    authorize @catagory
    raise UnprocessableEntityError.new(@catagory.errors) unless @catagory.save
    head :no_content
  end

  # PATCH/PUT /catagorys/1
  # PATCH/PUT /catagorys/1.json
  def update
    authorize @catagory
    raise UnprocessableEntityError.new(@catagory.errors) unless @catagory.update(catagory_params)     
    head :no_content
  end

  # DELETE /catagorys/1
  # DELETE /catagorys/1.json
  def destroy
    authorize @catagory
    @catagory.destroy
    head :no_content
  end

  private
    # only permit the trusted paramsters
    def catagory_params
      params.require(:catagory).permit(:name, :icon)
    end

    def set_catagory
      @catagory = Catagory.find(params[:id])
      raise NotfoundError.new('Catagory', { :id => params[:id] }.to_s ) unless @catagory
    end

end
