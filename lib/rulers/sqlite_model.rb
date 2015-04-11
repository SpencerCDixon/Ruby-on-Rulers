require 'sqlite3'
require 'rulers/util'
require 'pry'

DB = SQLite3::Database.new "test.db"

module Rulers
  module Model
    class SQLite
      def initialize(data = nil)
        @hash = data
      end

      def self.to_sql(val)
        case val
        when Numeric
          val.to_s
        when String
          "'#{val}'"
        else
          raise "Can't change #{val.class} to SQL!"
        end
      end

      def self.create(values)
        values.delete "id"
        keys = schema.keys - ["id"]
        vals = keys.map do |key|
          values[key] ? to_sql(values[key]) : "null"
        end

        DB.execute <<-SQL
          INSERT INTO #{table} (#{keys.join(",")})
          VALUES (#{vals.join(",")});
        SQL

        data = Hash[keys.zip vals]
        sql = "SELECT last_insert_rowid();"
        data["id"] = DB.execute(sql)[0][0]
        self.new data
      end

      def self.count
        DB.execute(<<-SQL)[0][0]
          SELECT COUNT(*) FROM #{table}
        SQL
      end

      def self.table
        Rulers.to_underscore name
      end

      def self.schema
        return @schema if @schema
        @schema = {}
        DB.table_info(table) do |row|
          @schema[row["name"]] = row["type"]
        end
        @schema # schema is actually an instance method of the class itself
      end

      def self.find(id)
        row = DB.execute <<-SQL
          select #{schema.keys.join(",")} from #{table}
          where id = #{id};
        SQL
        data = Hash[schema.keys.zip row[0]]
        self.new data

        # row return a 2d array, inner array is all the columns from DB
        # schema returns hash with keys as columns and values as column types
        # schema.keys returns array of all keys
        # zip is an enumerable method that iterates over the two arrays and
        # combines them together
        # passing in a 2d array to Hash[2d_array] will make a Hash wish the keys
        # as 0 and values as 1
      end

      # Getter/Setters for Model Instance Objects
      def [](name)
        @hash[name.to_s]
      end

      def []=(name, value)
        @hash[name.to_s] = value
      end
    end
  end
end
