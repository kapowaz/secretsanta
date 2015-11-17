require 'bundler'
Bundler.require

class SecretSanta
  DataMapper.setup :default, "sqlite3:./db/participants.db"
end

Dir[File.join(File.dirname(__FILE__), 'app/**/*.rb')].sort.each { |f| require f }

DataMapper.finalize
DataMapper.auto_upgrade!
