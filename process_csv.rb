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
                    puts
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
    def run(request)

    end
end
