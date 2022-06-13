require_relative "csv_process.rb"
require_relative "order_process.rb"
require_relative "join_process.rb"

class MySqliteRequest
    attr_reader :query_type, :selected_columns, :current_table, :insert_table, :insert_columns, :insert_values, :insert_hash, :update_table, :set, :where, :join_table, :on_hash
    attr_accessor :order, :query_result

    def initialize(request_hash)
        @query_type         = request_hash["QUERY_TYPE"]
        @selected_columns   = request_hash["SELECT"]
        @current_table      = request_hash["FROM"]
        @order              = request_hash["ORDER"]
        @insert_table       = request_hash["INSERT_TABLE"]
        @insert_columns     = request_hash["INSERT_COLUMNS"]
        @insert_values      = request_hash["INSERT_VALUES"]
        @insert_hash        = request_hash["INSERT_HASH"]
        @update_table       = request_hash["UPDATE"]
        @set                = request_hash["SET"]
        @where              = request_hash["WHERE"]
        @join_table         = request_hash["JOIN"]
        @on_hash            = request_hash["ON"]
        @query_result       = []
    end
end

class RouteRequest
    def run(request)
        SelectProcess.new.run(request) if request.query_type == "SELECT"
        InsertProcess.new.run(request) if request.query_type == "INSERT"
    end
end

class SelectProcess
    def run(request)
        CsvProcess.new.run(request)
        OrderProcess.new.run(request)
        JoinProcess.new.run(request) if request.join_table != nil
    end
end

class InsertProcess
    def run(request)
        InsertIntoCSV.new.run(request)
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
        puts
        puts "---------------------------------------------------------------------------------------------------------------------------------------"
        puts "REQUEST ATTRIBUTES"
        puts "Query type:       #{request.query_type}"
        puts "Selected columns: #{request.selected_columns}"
        puts "Current table:    #{request.current_table}"
        puts "Order:            #{request.order}"
        puts "Insert table:     #{request.insert_table}"
        puts "Insert columns:   #{request.insert_columns}"
        puts "Insert values:    #{request.insert_values}"
        puts "Insert hash:      #{request.insert_hash}"
        puts "Update table:     #{request.update_table}"
        puts "Set:              #{request.set}"
        puts "Where:            #{request.where}"
        puts "Join_table:       #{request.join_table}"
        puts "On:               #{request.on_hash}"
        # puts "Query result:     #{request.query_result}"
        puts "Query result:"
        puts request.query_result
        puts "----------------------------------------------------------------------------------------------------------------------------------------"
        puts
    end
end
