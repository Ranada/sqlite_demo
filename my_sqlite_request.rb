require_relative "process_csv.rb"

class MySqliteRequest
    attr_reader :query_type, :selected_columns, :current_table, :insert_table, :insert_columns, :insert_values, :insert_hash, :update_table, :set, :where, :join_table, :on
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
        @on                 = request_hash["ON"]
        @query_result       = []
    end
end

class RouteRequest
    def run(request)
        SelectProcess.new.run(request) if request.query_type == "SELECT"
        InsertProcess.new.run(request) if request.query_type == "INSERT"
        OrderProcess.new.run(request)
        JoinProcess.new.run(request) if request.join_table != nil
    end
end

class SelectProcess
    def run(request)
        ProcessData.new.run(request)
    end
end

class OrderProcess
    def run(request)
        if request.order == nil
            default_order(request)
        else
            cli_entry_order(request)
        end
    end

    def default_order(request)
        request.order = ["First column (default)", "ASC"]
        request.query_result.sort_by! { |hash| hash.values.first }
    end

    def cli_entry_order(request)
        column_name = request.order[0]
        order = request.order[1].upcase
        order_asc(request, column_name) if order == "ASC"
        order_desc(request, column_name) if order == "DESC"
    end

    def order_asc(request, column_name)
        if request.query_result.each.any? { |key, value| key[column_name] == nil }
            partition_nil_asc(request, column_name)
        else
            request.query_result = request.query_result.sort_by! { |key, value|  key[column_name]}
        end
    end

    def partition_nil_asc(request,column_name)
        partitioned_array = request.query_result.partition { |key, value| key[column_name] != nil }
        partitioned_array[0] = partitioned_array[0].sort_by! { |key, value|  key[column_name]}
        request.query_result = partitioned_array.flatten
    end

    def order_desc(request, column_name)
        if request.query_result.each.any? { |key, value| key[column_name] == nil }
            partition_nil_desc(request, column_name)
        else
            request.query_result = request.query_result.sort_by! { |key, value|  key[column_name]}.reverse
        end
    end

    def partition_nil_desc(request, column_name)
        partitioned_array = request.query_result.partition { |key, value| key[column_name] != nil }
        partitioned_array[0] = partitioned_array[0].sort_by! { |key, value|  key[column_name]}.reverse
        request.query_result =partitioned_array.flatten
    end
end

class InsertProcess
    def run(request)
        InsertIntoCSV.new.run(request)
    end
end

class JoinProcess
    def run(request)
        # JoinCsvs.new.run(request)
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
        puts "On:               #{request.on}"
        # puts "Query result:     #{request.query_result}"
        puts "Query result:"
        puts request.query_result
        puts "----------------------------------------------------------------------------------------------------------------------------------------"
        puts
    end
end
