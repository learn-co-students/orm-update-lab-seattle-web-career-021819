require_relative "../config/environment.rb"

class Student
  attr_accessor :id, :name, :grade

  def initialize(id= nil, name, grade)
    @name = name
    @grade = grade
    @id = id
  end

  #This class method creates the students table with columns that match the attributes of our individual students: an id (which is the primary key), the name and the grade.

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE students"
    DB[:conn].execute(sql)
  end

  def save
    if self.id !=nil
      sql = <<-SQL
        UPDATE students SET name = ? , grade = ? WHERE id = ?
      SQL
      DB[:conn].execute(sql, self.name, self.grade, self.id)
    else
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?,?);
      SQL
      DB[:conn].execute(sql, self.name,self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid()FROM students")[0][0]
    end
  end

  def self.create(name,grade)
    student = Student.new(name, grade)
    student.save
    student
  end

  def self.new_from_db(row)
    self.new(row[0],row[1],row[2])
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM students WHERE name = ? LIMIT 1;"
    DB[:conn].execute(sql,name).map {|row| self.new_from_db(row)}.first
  end

  def update
    sql = "UPDATE students SET name = ? , grade = ? WHERE id = ?;"
    DB[:conn].execute(sql,self.name,self.grade,self.id)
  end
end
  # Remember, you can access your database connection anywhere in this class
