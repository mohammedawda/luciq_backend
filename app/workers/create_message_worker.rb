class CreateMessageWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5

  def perform(data)
    Rails.logger.info "➡️ [CreateMessageWorker] Starting with data: #{data.inspect}"

    chat_id = data['chat_id']
    body    = data['body']

    begin
      chat = Chat.find(chat_id)
    rescue ActiveRecord::RecordNotFound
      Rails.logger.error "❌ Chat not found with id=#{chat_id}"
      return
    end

    redis_key = "chat:#{chat_id}:message_counter"
    number = REDIS.incr(redis_key)
    REDIS.set("chat:#{chat.id}:message_counter", chat.messages.maximum(:number) || 0)
    Rails.logger.info "🔢 Assigned message number=#{number} for chat_id=#{chat_id}"

    begin
      msg = Message.create!(chat: chat, number: number, body: body)
      Rails.logger.info "✅ Message created with id=#{msg.id}"
    rescue ActiveRecord::RecordNotUnique
      Rails.logger.info "⚠️ Duplicate message skipped for chat=#{chat_id}, number=#{number}"
    rescue => e
      Rails.logger.error "💥 Message creation failed: #{e.class} - #{e.message}\n#{e.backtrace.join("\n")}"
    end
  end
end
