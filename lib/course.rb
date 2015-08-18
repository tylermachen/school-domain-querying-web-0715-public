require 'pry'
class Course
  attr_accessor :id, :name, :department_id
  attr_reader   :department

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS courses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        department_id INTEGER REFERENCES departments)
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS courses"
    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    c = new
    c.id = row[0]
    c.name = row[1]
    c.department_id = row[2]
    c
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM courses WHERE name = ?"
    results = DB[:conn].execute(sql, name)
    results.map { |row| self.new_from_db(row) }.first
  end

  def self.find_all_by_department_id(department_id)
    sql = "SELECT * FROM courses WHERE department_id = ?"
    row = DB[:conn].execute(sql, department_id)
    row.map { |row| self.new_from_db(row) }
  end

  def insert
    sql = "INSERT INTO courses (name, department_id) VALUES (?, ?)"
    DB[:conn].execute(sql, self.name, self.department_id)

    sql = "SELECT last_insert_rowid() FROM courses"
    self.id = DB[:conn].execute(sql).flatten.first
  end

  def persists?
    !!id
  end

  def save
    persists? ? update : insert
  end

  def update
    sql = "UPDATE courses SET name = ?, department_id = ? WHERE id = ?"
    DB[:conn].execute(sql, name, department_id, id)
  end

  def department
    @department = Department.find_by_id(department_id)
  end

  def department=(department)
    @department = department
    @department_id = department.id
  end

  def students
    sql = <<-SQL
      SELECT *
      FROM students
      JOIN registrations
      ON students.id = registrations.student_id
      JOIN courses
      ON courses.id = registrations.course_id
      WHERE course_id = ?
    SQL
    row = DB[:conn].execute(sql, id)
    row.map { |row| Student.new_from_db(row) }
  end

  def add_student(student)
    student.add_course(self)
  end
end
