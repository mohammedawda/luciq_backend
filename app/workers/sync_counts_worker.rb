class SyncCountsWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform
    Application.find_each do |app|
      actual = app.chats.count
      app.update_column(:chats_count, actual) if app.chats_count != actual
    end

    Chat.find_each do |chat|
      actual = chat.messages.count
      chat.update_column(:messages_count, actual) if chat.messages_count != actual
    end
  end
end
