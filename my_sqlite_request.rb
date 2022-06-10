require_relative "process_csv.rb"

class MySqliteRequest
    attr_reader :query_type, :selected_columns, :current_table, :insert_table, :keys, :values, :update_table, :set, :where, :join_table, :on
    attr_accessor :order, :query_result

    def initialize(request_hash)
        @query_type         = request_hash["QUERY_TYPE"]
        @selected_columns   = request_hash["SELECT"]
        @current_table      = request_hash["FROM"]
        @order              = request_hash["ORDER"]
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
end

class RouteRequest
    def run(request)
        SelectProcess.new.run(request) if request.query_type == "SELECT"
        OrderProcess.new.run(request)
    end
end

class SelectProcess
    def run(request)
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

class OrderProcess
    def run(request)
        if request.order == nil
            request.order = ["First column (default)", "ASC"]
            request.query_result.sort_by! { |hash| hash.values.first }
        else
            column_name = request.order[0]
            order = request.order[1]
            if order == "ASC"
                partitioned_array = request.query_result.partition { |key, value| key[column_name] != nil }
                partitioned_array[0].sort_by! { |key, value|  key[column_name]}
                request.query_result = partitioned_array.flatten
            elsif order == "DESC"
                partitioned_array = request.query_result.partition { |key, value| key[column_name] != nil }
                partitioned_array[0].sort_by! { |key, value|  key[column_name]}.reverse
                request.query_result = partitioned_array.flatten
            end
        end
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
        puts "Keys:             #{request.keys}"
        puts "Values:           #{request.values}"
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
