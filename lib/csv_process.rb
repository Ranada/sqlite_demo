class CsvProcess
    attr_accessor :table_data

    def initialize
        @table_data = nil
    end
    def run(request)
        self.table_data = CSV.parse(File.read(request.current_table), headers: true) if request.join_table == nil
        self.table_data = CSV.parse(File.read(request.new_joined_table), headers: true) if request.join_table != nil
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
