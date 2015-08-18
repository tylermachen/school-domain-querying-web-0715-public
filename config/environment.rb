require 'sqlite3'
require_relative '../lib/student'
require_relative '../lib/department'
require_relative '../lib/course'
require_relative '../lib/registration'

DB = {:conn => SQLite3::Database.new("db/school.db")}
# DB.results_as_hash = true
