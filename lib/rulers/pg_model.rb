require 'pg'

DB_NAME = 'best_quotes_development'

module Rulers
  module Model
    class PGModel
      def initialize(data = nil)
        @hash = data
      end

      def db_connection
        begin
          connection = PG.connect(dbname: DB_NAME)
          yield(connection)
        ensure
          connection.close
        end
      end
    end
  end
end
