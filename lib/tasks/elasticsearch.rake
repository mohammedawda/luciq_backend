namespace :es do
  desc "Create messages index (safe to run multiple times)"
  task create_index: :environment do
    settings = {
      settings: {
        number_of_shards: 1,
        number_of_replicas: 0,
        analysis: {
          analyzer: {
            default: { type: 'standard' }
          }
        }
      },
      mappings: {
        properties: {
          id: { type: 'long' },
          chat_id: { type: 'long' },
          application_id: { type: 'long' },
          number: { type: 'integer' },
          body: { type: 'text', analyzer: 'standard' },
          created_at: { type: 'date' }
        }
      }
    }

    ES_CLIENT.indices.create(index: 'messages', body: settings, ignore: 400)
    puts "ES index 'messages' created (or already exists)."
  end
end
