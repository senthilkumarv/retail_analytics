class Database
    def self.create
        SQLite3::Database.new("#{File.dirname(__FILE__)}/../db/dev.sqlite3")
    end
end
