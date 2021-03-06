class Registration
  attr_accessor :id, :course_id, :student_id

  def self.create_table
		sql = <<-SQL
		  CREATE TABLE IF NOT EXISTS registrations(
		  id INTEGER PRIMARY KEY AUTOINCREMENT,
		  course_id INTEGER REFERENCES courses,
		  student_id INTEGER REFERENCES students)
		SQL
		DB[:conn].execute(sql)
	end

	def self.drop_table
		sql = "DROP TABLE IF EXISTS registrations"
		DB[:conn].execute(sql)
	end
end
