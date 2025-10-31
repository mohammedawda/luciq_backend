class CreateChatWorker
    include Sidekiq::Worker
    sidekiq_options retry: 5
  
    def perform(application_id, number)
      application = Application.find(application_id)
      # attempt create; handle concurrent DB uniqueness
      begin
        Chat.create!(application: application, number: number, messages_count: 0)
      rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid => e
        # if already exists, fine — just log
        Rails.logger.info "Chat already exists for app=#{application_id} number=#{number}: #{e.message}"
      end
      # No heavy updates here; counter_cache auto-increments applications.chats_count
    end
  end
  