require_relative "./lib/csv_process.rb"
require_relative "./lib/order_process.rb"
require_relative "./lib/insert_into_csv_process.rb"
require_relative "./lib/join_process.rb"
require_relative "./lib/update_csv_process.rb"

class MySqliteRequest
    attr_reader :query_type, :selected_columns, :current_table, :insert_table, :insert_columns, :insert_values, :insert_hash, :update_table, :set, :where, :join_table, :on_hash
    attr_accessor :order, :query_result, :new_joined_table

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
        @new_joined_table   = "new_joined.csv"
        @on_hash            = request_hash["ON"]
        @query_result       = []
    end
end

class RouteRequest
    def run(request)
        SelectProcess.new.run(request) if request.query_type == "SELECT"
        InsertProcess.new.run(request) if request.query_type == "INSERT"
        UpdateProcess.new.run(request) if request.query_type == "UPDATE"
    end
end

class SelectProcess
    def run(request)
        JoinProcess.new.run(request) if request.join_table != nil
        CsvProcess.new.run(request)
        OrderProcess.new.run(request)
    end
end

class InsertProcess
    def run(request)
        InsertIntoCsvProcess.new.run(request)
    end
end

class UpdateProcess
    def run(request)
        UpdateCsvProcess.new.run(request)
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

class PrintAttributes
    def run(request)
        puts
        puts "---------------------------------------------------------------------------------------------------------------------------------------"
        puts "REQUEST ATTRIBUTES"
        puts "Query type:       #{request.query_type}"
        puts "Selected columns: #{request.selected_columns}"    if request.selected_columns != nil
        puts "Current table:    #{request.current_table}"       if request.current_table != nil
        puts "Order:            #{request.order}"               if request.order != nil
        puts "Insert table:     #{request.insert_table}"        if request.insert_table != nil
        puts "Insert columns:   #{request.insert_columns}"      if request.insert_columns != nil
        puts "Insert values:    #{request.insert_values}"       if request.insert_values != nil
        puts "Insert hash:      #{request.insert_hash}"         if request.insert_hash != nil
        puts "Update table:     #{request.update_table}"        if request.update_table != nil
        puts "Set:              #{request.set}"                 if request.set != nil
        puts "Where:            #{request.where}"               if request.where != nil
        puts "Join_table:       #{request.join_table}"          if request.join_table != nil
        puts "New joined table: #{request.new_joined_table}"    if request.join_table != nil
        puts "On:               #{request.on_hash}"             if request.on_hash != nil
        puts "Query result:"
        puts request.query_result
        puts "----------------------------------------------------------------------------------------------------------------------------------------"
        puts
    end
end
