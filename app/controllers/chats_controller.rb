class ChatsController < ApplicationController
  before_action :set_application

  def index
    chats = @application.chats.order(:number).limit(100)
    render json: chats.as_json(only: [:number, :messages_count]), status: :ok
  end

  def create
    # allocate number quickly via Redis
    number = NumberAllocator.next_chat_number(@application)
    # queue persistence
    Rails.logger.info "Sidekiq client: #{Sidekiq.redis { |conn| conn.client.id rescue 'no redis' }}"
    jid = CreateChatWorker.perform_async(@application.id, number)
    Rails.logger.info "Job enqueued: #{jid.inspect}"
    render json: { number: number }, status: :accepted
  end

  def show
    chat = @application.chats.find_by!(number: params[:number])
    render json: { number: chat.number, messages_count: chat.messages_count }, status: :ok
  end

  private

  def set_application
    @application = Application.find_by!(token: params[:application_token] || params[:token])
  end
end
