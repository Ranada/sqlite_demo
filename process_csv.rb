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
        filter_col_hash = {}
        request.selected_columns.each do |col_name|
            filter_col_hash[col_name] = row_hash[col_name]
        end
        FilterCriteria.new.run(filter_col_hash, request)
        # p filter_col_hash
    end
end

class FilterCriteria
    def run(filter_col_hash, request)
        p request.where

        if filter_col_hash[col_name] == criteria
            p filter_col_hash
        end
    end
end
