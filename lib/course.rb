require 'pry'
class Course
  attr_accessor :id, :name, :department_id
  @@instances = []

  def initialize(id = nil, name = nil, department_id = nil)
    @id = id
    @name = name
    @department_id = department_id
    @@instances << self
  end

  def insert
    sql = <<-SQL
      INSERT INTO courses (name, department_id)
      VALUES (?, ?);
    SQL
    DB[:conn].execute(sql, self.name, self.department_id)
    sql = "SELECT last_insert_rowid() FROM courses"
    self.id = DB[:conn].execute(sql).flatten.first
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS courses (
        id INTEGER PRIMARY KEY AuTOINCREMENT,
        name TEXT,
        department_id INTEGER REFERENCES department
      );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS courses"
    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    new(row[0], row[1], row[2])
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM courses WHERE name = ?"
    row = DB[:conn].execute(sql, name).first
    self.new_from_db(row) unless row.nil?
  end

  def self.find_all_by_department_id(department_id)
    sql = "SELECT * FROM courses WHERE department_id = ?"
    row = DB[:conn].execute(sql, department_id)
    row.map { |row| self.new_from_db(row) }
  end

  def persists?
    !!id
  end

  def update
    sql = "UPDATE courses SET department_id = ? WHERE id = ?"
    DB[:conn].execute(sql, name, id)
  end

  def save
    persists? ? update : insert
  end
end
