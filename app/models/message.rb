class Message < ApplicationRecord
  belongs_to :chat, counter_cache: true
  validates :number, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :body, presence: true

  after_commit :index_to_elasticsearch, on: :create

  def index_to_elasticsearch
    begin
      ES_CLIENT.index index: 'messages', id: id, body: {
        id: id,
        chat_id: chat_id,
        application_id: chat.application_id,
        number: number,
        body: body,
        created_at: created_at
      }
    rescue => e
      Rails.logger.error "ES index error for Message #{id}: #{e.message}"
    end
  end
end
