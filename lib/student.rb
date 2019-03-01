require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade
  attr_reader :id

  @@all = []

  def initialize(name, grade, id=nil)
    @name = name
    @grade = grade
    @id = id
    @@all << self
  end

  def self.create_table
    sql = <<~SQL
      CREATE TABLE students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE students"
    DB[:conn].execute(sql)
  end

  def save
    if self.id    # this IF line is the same as "if self.id != nil"
      self.update
    else
      sql = "INSERT INTO students (name, grade) VALUES (?, ?)"
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create(name, grade, id=nil)
    new_student = Student.new(name, grade, id)
    new_student.save
    new_student
  end

  def self.new_from_db(array) # array contains DB data - id, name, grade
    Student.create(array[1], array[2], array[0])
  end

  def self.find_by_name(name_input)
    current_record = DB[:conn].execute("SELECT * FROM students WHERE name = \"#{name_input}\"")[0]
    Student.new_from_db(current_record)
  end

  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

end
