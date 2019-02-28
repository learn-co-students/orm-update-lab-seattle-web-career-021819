require_relative "../config/environment.rb"

class Student
  attr_reader :id
  attr_accessor :name, :grade
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  def initialize(id=nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  # Adds this student to the students table in the db
  def save
    if @id
      self.update
    else
      sql = <<~SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, @name, @grade)
      sql = "SELECT last_insert_rowid() FROM students LIMIT 1"
      @id = DB[:conn].execute(sql)[0][0]
    end
  end

  # Updates the student attributes (by id) in the db
  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, @name, @grade, @id)
  end

  # Creates a new student and adds it to the db
  def self.create(name, grade)
    self.new(name, grade).save
  end

  # Creates a new student from the given row of table from db
  def self.new_from_db(row)
    self.new(row[0], row[1], row[2])
  end

  # Returns the student that has a name matching the given name
  def self.find_by_name(name)
    sql = "SELECT * FROM students WHERE name = ?"
    self.new_from_db(DB[:conn].execute(sql, name)[0])
  end

  # Creates a new students table in the db
  def self.create_table
    sql = <<~SQL
      CREATE TABLE students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      );
    SQL

    DB[:conn].execute(sql)
  end

  # Removes students table
  def self.drop_table
    DB[:conn].execute("DROP TABLE students")
  end
end
