require_relative "process_csv.rb"

class MySqliteRequest
    attr_reader :query_type, :selected_columns, :current_table, :insert_table, :keys, :values, :update_table, :set, :where, :join_table, :on, :query_result

    def initialize(request_hash)
        @query_type         = request_hash["QUERY_TYPE"]
        @selected_columns   = request_hash["SELECT"]
        @current_table      = request_hash["FROM"]
        @insert_table       = request_hash["INSERT"]
        @keys               = request_hash["KEYS"]
        @values             = request_hash["VALUES"]
        @update_table       = request_hash["UPDATE"]
        @set                = request_hash["SET"]
        @where              = request_hash["WHERE"]
        @join_table         = request_hash["JOIN"]
        @on                 = request_hash["ON"]
        @query_result       = []
    end

    def run
        PrintCommand.new.run(self)
    end
end

class RouteRequest
    def run(request)
        SelectProcess.new.run(request) if request.query_type == "SELECT"
    end
end

class SelectProcess
    # attr_reader :selected_columns

    # def initialize(selected_columns)
    #     @selected_columns = selected_columns
    # end

    def run(request)
        p "SELECTED COLUMNS #{request.selected_columns}"
        p "FROM TABLE #{request.current_table}"
        ProcessData.new.run(request)
    end
end

class FromCommand
    attr_reader :current_table

    def initialize(current_table)
        @current_table = current_table
    end

    def run
        p "CURRENT TABLE: #{self.current_table}"
    end
end

class WhereCommand
    def initialize(column_name, criteria)
        @column_name
    end

    def run
    end
end

class InsertCommand
    def initialize(table_name)
        @table_name = table_name
    end

    def run
    end
end

class ValuesCommand
    def initialize(data_hash)
        @data_hash = data_hash
    end

    def run
    end
end

class JoinCommand
    def initialize(column_on_db_a, filename_db_b, column_on_db_b)
        @column_on_db_a = column_on_db_a
        @filename_db_b = filename_db_b
        @column_on_db_b = column_on_db_b
    end

    def run
    end
end

class OrderCommand
    def initialize(order, column_name)
        @order = :asc
        @column_name = column_name
    end

    def run
    end
end

class UpdateCommand
    def initialize(table_name)
        @table_name = table_name
    end

    def run
    end
end

class SetCommand
    def initialize(hash_data)
        @hash_data = hash_data
    end

    def run
    end
end

class DeleteCommand
    def initialize(selected_columns)
        @selected_columns = selected_columns
    end

    def run
    end
end

class PrintCommand
    def run(request)
        puts "-----------------------------------------------"
        puts "REQUEST ATTRIBUTES"
        puts "Query type:       #{request.query_type}"
        puts "Selected columns: #{request.selected_columns}"
        puts "Current table:    #{request.current_table}"
        puts "Insert table:     #{request.insert_table}"
        puts "Keys:             #{request.keys}"
        puts "Values:           #{request.values}"
        puts "Update table:     #{request.update_table}"
        puts "Set:              #{request.set}"
        puts "Where:            #{request.where}"
        puts "Join_table:       #{request.join_table}"
        puts "On:               #{request.on}"
        puts "Query result:     #{request.query_result}"
        puts "-----------------------------------------------"
        puts
    end
end
