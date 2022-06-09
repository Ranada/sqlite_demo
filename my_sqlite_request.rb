require 'csv'

class MySqliteRequest
    attr_accessor :request_hash

    def initialize(request_hash)
        @request_hash = request_hash
    end

    def run
        print @request_hash
        puts
        if @request_hash["SELECT"] != nil
            SelectCommand.new(@request_hash["SELECT"]).run
            FromCommand.new(@request_hash["FROM"]).run
        end
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

class SelectCommand
    attr_reader :selected_columns

    def initialize(selected_columns)
        @selected_columns = selected_columns
    end

    def run
        p "SELECTED COLUMNS #{self.selected_columns}"
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
    def run
        puts    "Type of request:      #{@type_of_request}"
        puts    "Selected columns:     #{@selected_columns}"
        puts    "Table name:           #{@table_name}"
        print   "Table data:          "
        p                              @table_data
        puts    "Joining table name:   #{@joining_table_name}"
        print   "Joining table data:  "
        p                              @joining_table_data
        puts    "Column on table:      #{@column_on_table}"
        puts    "Column on join table: #{@column_on_joining_table}"
        puts    "Joined csv name:      #{@joined_csv_name}"
        puts    "Order:                #{@order}"
        puts    "Query result:         #{@query_result}"

        # print_csv
    end
end

# debugger
# def _main()
#     request = MySqliteRequest.new



    # INSERT
    # request = request.insert('nba_player_data.csv')
    # request = request.values({"name"=>"Cahethel Dounou", "year_start"=>"2008", "year_end"=>"2012", "position"=>"G", "height"=>"5-7", "weight"=>"150", "birth_date"=>"January 1, 1980", "college"=>"University of Florida"})
    # request = request.values({"year_start"=>"2008", "name"=>"Gandalf the Grey", "year_end"=>"2012", "position"=>"G", "height"=>"5-7", "weight"=>"150", "birth_date"=>"January 1, 1980", "college"=>"University of Florida"})

    # JOIN
    # request = request.from('nba_player_data.csv')
    # request = request.select('*')
    # request.select(["name", "birth_date", "birth_state"])
    # request = request.join('name','nba_players_extra_info.csv', 'player')
    # request = request.where('name', 'Jerome Allen')
    # request = request.where('year_start', '1990')

    # Order
    # request = request.from('nba_player_data.csv')
    # # request = request.select('*')
    # request.select(["name", "birth_date", "birth_state"])
    # # request = request.join('name','nba_players_extra_info.csv', 'player')
    # # request = request.where('name', 'Jerome Allen')
    # request = request.where('year_start', '1990')
    # # request = request.order('asc', 'name')
    # request = request.order('dsc', 'name')
    # request.run
# end

# _main()
# Expect array of hashes: [{"name" => "Jerome Allen"]
