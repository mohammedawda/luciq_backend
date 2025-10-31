class Chat < ApplicationRecord
  belongs_to :application, counter_cache: true
  has_many :messages, dependent: :destroy

  validates :number, presence: true,
                   numericality: { only_integer: true, greater_than: 0 },
                   uniqueness: { scope: :application_id }

  after_create_commit :init_message_counter

  private

  def init_message_counter
    REDIS.set("chat:#{id}:message_counter", 0)
  end
end
