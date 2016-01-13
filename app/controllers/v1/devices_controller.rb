module V1
  class DevicesController < ApplicationController

    before_action :set_device, only: [:show, :update, :destroy]

    # GET /devices
    def index
      # TODO
    end

    # GET /devices/1
    def show
      # TODO
    end

    # POST /devices
    def create
      if Device.where({ :identity => device_params[:identity] }).first.nil?
        @device = Device.new(device_params)
        @device.session = @session
        raise UnprocessableEntityError.new(@device.errors) unless @device.save
      else
        @device = Device.where({ :identity => device_params[:identity] }).first
        @device.session = @session
        raise UnprocessableEntityError.new(@device.errors) unless @device.update(device_params)
      end
      # send message to the device
      if not @session.nil?
        Message.where({ msg_send: false, receiver_id: @session.user.get_id }).each{|msg|
          msg.send_msg
        }
      end
      head :no_content
    end

    # PUT /devices/1
    def update
    end

    # DELETE /devices/1
    def destroy
      @review.destroy
      head :no_content
    end

    private

    def set_device
      @device = Device.find(params[:id] || params[:device_id])
      raise NotfoundError.new('Device', { :id => params[:id] || params[:device_id] }.to_s) unless @device
    end

    def device_params
      params.require(:device).permit(:identity, :token, :user_id, :os)
    end

  end
end
