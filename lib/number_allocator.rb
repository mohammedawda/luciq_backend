# lib/number_allocator.rb
class NumberAllocator
  class << self
    # Returns next chat number for application (fast, atomic via Redis)
    def next_chat_number(application)
      key = "app:#{application.id}:next_chat_number"
      initialize_redis_key_from_db(key) { application.chats.maximum(:number) || 0 }
      REDIS.incr(key).to_i
    end

    # Returns next message number for chat
    def next_message_number(chat)
      key = "chat:#{chat.id}:next_message_number"
      initialize_redis_key_from_db(key) { chat.messages.maximum(:number) || 0 }
      REDIS.incr(key).to_i
    end

    private

    # Set key to db_max only if not present. Use setnx to avoid races.
    def initialize_redis_key_from_db(key)
      return if REDIS.exists?(key)

      db_max = yield.to_i
      # SETNX ensures only one process sets the value; other processes will keep it
      REDIS.setnx(key, db_max)
    end
  end
end
