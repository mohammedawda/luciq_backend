class ApplicationsController < ApplicationController
    before_action :set_application, only: [:show, :update, :destroy]
  
    def index
      render json: Application.all.select(:token, :name, :chats_count), status: :ok
    end
  
    def create
      app = Application.new(application_params)
      app.token ||= SecureRandom.uuid
      if app.save
        render json: { token: app.token, name: app.name }, status: :created
      else
        render json: { errors: app.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    def show
      render json: { token: @application.token, name: @application.name, chats_count: @application.chats_count }, status: :ok
    end
  
    def update
      if @application.update(application_params)
        render json: { token: @application.token, name: @application.name }, status: :ok
      else
        render json: { errors: @application.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    def destroy
      @application.destroy
      head :no_content
    end
  
    private
  
    def application_params
      params.require(:application).permit(:name)
    end
  
    def set_application
      @application = Application.find_by!(token: params[:token])
    end
  end
  