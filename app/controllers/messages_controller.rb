class MessagesController < ApplicationController
  before_action :set_application
  before_action :set_chat

  def index
    messages = @chat.messages.order(:number).limit(100)
    render json: messages.map { |m| { number: m.number, body: m.body, created_at: m.created_at } }, status: :ok
  end

  def create
    application_token = params[:application_token]
    chat_number       = params[:chat_number]
    body              = params.require(:body)

    # Find the chat based on application token and chat number
    application = Application.find_by!(token: application_token)
    chat        = application.chats.find_by!(number: chat_number)

    # Prepare job data
    message_data = {
      'chat_id' => chat.id,
      'body'    => body
    }

    # Enqueue job
    CreateMessageWorker.perform_async(message_data)

    render json: { status: 'queued', message: 'Message creation scheduled' }, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Application or chat not found' }, status: :not_found
  rescue ActionController::ParameterMissing
    render json: { error: 'Missing message body' }, status: :unprocessable_entity
  end
  

  def show
    msg = @chat.messages.find_by!(number: params[:number])
    render json: { number: msg.number, body: msg.body, created_at: msg.created_at }, status: :ok
  end

  def search
    q = params[:q].to_s.strip
    return render json: { results: [] }, status: :ok if q.blank?

    body = {
      query: {
        bool: {
          must: [
            { term: { chat_id: @chat.id } },
            {
              match_phrase_prefix: { body: { query: q } }
            }
          ]
        }
      }
    }

    resp = ES_CLIENT.search index: 'messages', body: body
    hits = resp['hits']['hits'].map { |h| h['_source'].slice('number', 'body', 'created_at') }
    render json: { results: hits }, status: :ok
  end

  private

  def set_application
    @application = Application.find_by!(token: params[:application_token] || params[:token])
  end

  def set_chat
    @chat = @application.chats.find_by!(number: params[:chat_number] || params[:number] || params[:chat_id])
  end

  def message_params
    params.require(:message).permit(:body)
  end
end
