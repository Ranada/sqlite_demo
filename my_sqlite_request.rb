# 00
# 1. Replicate SQL Query:
    # - Type of request: SELECT | INSERT | UPDATE | DELETE
    # - WHERE (max 1)
    # - JOIN ON
# 01
# 1. Create Command Line (CLI) for MySqlite
# 2. Create Class MySqlite
# 3. Create method
#     - def readline
# 4. Accept request with
#     # SELECT|INSERT|UPDATE|DELETE
#     # FROM
#     # WHERE (max 1 condition)
#     # JOIN ON (max 1 condition) Note, you can have multiple WHERE. Yes, you should save and load the database from a file.
# 5. Look up how to replicate sqlite command prompt
# 6. Look up B-Tree (not binary tree "B-Tree"), TRIE, Reverse Index
#

require 'csv'

class MySqliteRequest
    def initialize
        @type_of_request    = :none
        @selected_columns   = []
        @table_name         = nil
        @table_data         = nil
        @order              = :asc
        @query_result       = []
    end

    def from(table_name)
        @table_name = table_name
        @table_data = CSV.parse(File.read(@table_name), headers: true)
        self
    end

    def select(column_names)
        self.set_type_of_request(:select)
        if column_names.is_a?(String)
            @selected_columns += column_names.split(", ")
            # puts "I'm a string #{column_names.split(", ")}"
        else column_names.is_a?(Array)
            @selected_columns += column_names
            # puts "I'm an array #{column_names}"
        end
        self
    end

    def add_selected_columns(row)
        @selected_columns.each do |selected_column|
            if selected_column == '*'
                @query_result << row
            else
                @query_result << {selected_column => row[selected_column]}
            end
        end
    end

    def where(column_name, criteria)
        @table_data.each do |row|
            if row[column_name] == criteria
                add_selected_columns(row.to_hash)
            end
        end
        self
    end

    def join(column_on_db_a, filename_db_b, column_on_db_b)
        self
    end

    def order(order, column_name)
        self
    end

    def insert(table_name)
        self.set_type_of_request(:insert)
        @table_name = table_name
        self
    end

    def validate_hash_keys(headers_array, keys_array)
        headers_array.each do |header_name|
            if keys_array.none?(header_name)
                raise "Advisory: Your input does not include \"#{header_name}\" category"
                return
            end
        end
    end

    def values(data)
        headers_array = CSV.read(@table_name, headers: true).headers
        keys_array = data.keys
        validated_values_array = []

        validate_hash_keys(headers_array, keys_array)

        headers_array.each do |header_name|
            validated_values_array << data[header_name]
        end

        CSV.open(@table_name, "a+", :row_sep => "\r\n") do |csv| # `:row_sep => "\r\n"` needed to append a input values to a new line
                csv << validated_values_array
        end

        self
    end

    def update(table_name)
        self.set_type_of_request(:update)
        @table_name = table_name
        self
    end

    def set(data)
        self
    end

    def delete
        self.set_type_of_request(:delete)
    end

    def print_csv
        @table_data.each do |row|
            p row.to_hash
        end
    end

    def print_attributes
        puts    "Type of request:  #{@type_of_request}"
        puts    "Table name:       #{@table_name}"
        puts    "Selected columns: #{@selected_columns}"
        puts    "Order:            #{@order}"
        puts    "Query result:     #{@query_result}"

        # print_csv
    end

    def run
        print_attributes
    end

    def set_type_of_request(request_type)
        if @type_of_request == :none || @type_of_request == request_type
            @type_of_request = request_type
        else
            raise "Advisory: Type is already set to #{@type_of_request} (request type => #{request_type})"
        end
    end
end

def _main()
    request = MySqliteRequest.new

    # SELECT
    # request = request.from('nba_player_data.csv')
    # request = request.select('name')
    # request = request.select(["name", "birth_date"])
    # request = request.select('*')
    # request = request.where('name', 'Jerome Allen')
    # request = request.where('year_start', '1990')

    # INSERT
    request = request.insert('nba_player_data.csv')
    request = request.values({"name"=>"Neil Ranada", "year_start"=>"2008", "year_end"=>"2012", "position"=>"G", "height"=>"5-7", "weight"=>"150", "birth_date"=>"January 1, 1980", "college"=>"University of Florida"})
    request = request.values({"year_start"=>"2008", "name"=>"Gandalf the Grey", "year_end"=>"2012", "position"=>"G", "height"=>"5-7", "weight"=>"150", "birth_date"=>"January 1, 1980", "college"=>"University of Florida"})
    request.run
end

_main()
# Expect array of hashes: [{"name" => "Jerome Allen"]
