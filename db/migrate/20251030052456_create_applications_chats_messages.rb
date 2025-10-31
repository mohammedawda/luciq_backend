class CreateApplicationsChatsMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :applications do |t|
      t.string :name, null: false
      t.string :token, null: false
      t.integer :chats_count, null: false, default: 0

      t.timestamps
    end
    add_index :applications, :token, unique: true

    create_table :chats do |t|
      t.references :application, null: false, foreign_key: true
      t.integer :number, null: false
      t.integer :messages_count, null: false, default: 0

      t.timestamps
    end
    add_index :chats, [:application_id, :number], unique: true

    create_table :messages do |t|
      t.references :chat, null: false, foreign_key: true
      t.integer :number, null: false
      t.text :body, null: false

      t.timestamps
    end
    add_index :messages, [:chat_id, :number], unique: true
    add_index :messages, :created_at
  end
end
