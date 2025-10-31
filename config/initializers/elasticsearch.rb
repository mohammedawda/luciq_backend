# config/initializers/elasticsearch.rb
require 'elasticsearch'

ES_CLIENT = Elasticsearch::Client.new(url: ENV.fetch('ELASTICSEARCH_URL', 'http://elasticsearch:9200'), log: false)