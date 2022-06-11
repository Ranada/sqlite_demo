require 'csv'

class ProcessData
    attr_accessor :table_data

    def initialize
        @table_data = nil
    end

    def run(request)
        self.table_data = CSV.parse(File.read(request.current_table), headers: true)
        RowToHash.new.run(request, self.table_data)
    end
end

class RowToHash
    def run(request, table_data)
        table_data.each do |row|
            row = row.to_hash
            if request.selected_columns.first == '*'
                if request.where
                    FilterByCriteria.new.run(row, request)
                else
                    request.query_result << row
                end
            elsif request.selected_columns
                FilterByColumns.new.run(row, request)
            end
        end
    end
end

class FilterByColumns
    def run(row, request)
        row_filtered = {}
        request.selected_columns.each do |col_name|
            row_filtered[col_name] = row[col_name]
        end

        if request.where
            FilterByCriteria.new.run(row_filtered, request)
        else
            request.query_result << row_filtered
        end
    end
end

class FilterByCriteria
    def run(row_filtered, request)
        column_name = request.where.keys.first
        criteria = request.where.values.first

        if (row_filtered[column_name] != nil) && (row_filtered[column_name].downcase == criteria.downcase)
            request.query_result << row_filtered
        end
    end
end

class InsertIntoCSV
    def run(request)
        existing_headers_array = CSV.read(request.insert_table, headers: true).headers
        insert_headers_array = request.insert_hash.keys
        validated_values_array = []

        ValidateHashKeys.new.run(existing_headers_array, insert_headers_array)

        existing_headers_array.each do |header_name|
            validated_values_array << request.insert_hash[header_name]
        end

        CSV.open(request.insert_table, "a+", :row_sep => "\r\n") do |csv| # `:row_sep => "\r\n"` needed to append a input values to a new line
                csv << validated_values_array
        end
    end
end

class ValidateHashKeys
    def run(existing_headers_array, insert_headers_array)
        existing_headers_array.each do |header_name|
            if insert_headers_array.none?(header_name)
                raise "Advisory: Your input does not include \"#{header_name}\" category"
                return
            end
        end
    end
end

class JoinCsvs
    attr_accessor :join_result

    def initialize
        @join_result = []
    end

    def run(request)
        p "JOINCSVS"

        CreateJoinCSV.new.run(request)
        AddRows.new.run(request)
        self.join_result = CSV.parse(File.read("new_joined.csv"), headers: true)
    end
end

class CreateJoinCSV
    def run(request)
        CSV.open("new_joined.csv", "a+", :row_sep => "\r\n") do |new_joined_csv|
            combined_headers = add_combined_headers(request)
            add_combined_headers_to_joined(new_joined_csv, combined_headers)
        end
    end

    def add_combined_headers(request)
        current_table_headers = CSV.read(request.current_table, headers: true).headers
        join_table_headers = CSV.read(request.join_table, headers: true).headers
        combined_headers = []
        combined_headers += current_table_headers + join_table_headers
    end

    def add_combined_headers_to_joined(new_joined_csv, combined_headers)
            new_joined_csv << combined_headers
    end
end

class AddRows
    def run(request)
        current_table_column = request.on_hash[request.current_table.chomp('.csv')]
        join_table_column = request.on_hash[request.join_table.chomp('.csv')]

        CSV.open("new_joined.csv", "a+", :row_sep => "\r\n") do |new_joined_csv|
            combined_values_array = []
            current_table_array = []
            join_table_hash = {}

            CSV.parse(File.read(request.current_table), headers: true) do |current_table_row|
                current_table_array << current_table_row.to_hash
            end

            CSV.parse(File.read(request.join_table), headers: true) do |join_table_row|
                current_table_array.each do |current_table_row|
                    if current_table_row[current_table_column] == join_table_row.to_hash[join_table_column]
                        temp_array = []
                        temp_array += current_table_row.to_hash.values
                        temp_array += join_table_row.to_hash.values
                        new_joined_csv << temp_array
                    end
                end
            end
        end
    end

    # def add_current_table_rows(new_joined_csv, current_table_data)
    #     p "ADD CURRENT TABLE ROWS"
    #     # puts RowToHash.new.run(request, table_data)

    #     index = 0
    #     current_table_data[0].each do |row|
    #         index += 1
    #         p row
    #         p row.to_hash
    #         p row.to_hash.values
    #         puts
    #     end
    # end

    # def add_join_table_rows(combined_values_array, join_table_data)
    #      join_table_data.each do |row|
    #         if row.to_hash[request.on_hash[request.join_table]] == original_row.to_hash[@column_on_table]
    #             combined_values_array += joining_row.to_hash.values
    #         end
    #     end
    #     combined_values_array
    # end
end
