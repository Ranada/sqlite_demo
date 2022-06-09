require 'csv'

class ProcessData
    attr_accessor :table_data

    def initialize
        @table_data = nil
    end

    def run(request)
        puts "Hello from CSV class!!!"
        self.table_data = CSV.parse(File.read(request.current_table), headers: true)
        RowToHash.new.run(request, self.table_data)
    end
end

class RowToHash
    def run(request, table_data)
        table_data.each do |row|
            row_hash = row.to_hash
            FilterColumns.new.run(row_hash, request)
        end
    end
end

class FilterColumns
    def run(row_hash, request)
        row_filtered_by_col_hash = {}
        request.selected_columns.each do |col_name|
            row_filtered_by_col_hash[col_name] = row_hash[col_name]
        end
        FilterCriteria.new.run(row_filtered_by_col_hash, request)
        # p filter_col_hash
    end
end

class FilterCriteria
    def run(row_filtered_by_col_hash, request)
        column_name = request.where.keys.first
        criteria = request.where.values.first

        if row_filtered_by_col_hash[column_name] == criteria
            p row_filtered_by_col_hash
        end
    end
end
