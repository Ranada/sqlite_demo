class JoinProcess
    def run(request)
        JoinCsvs.new.run(request)
    end
end

class JoinCsvs
    attr_accessor :join_result

    def initialize
        @join_result = []
    end

    def run(request)
        p "Creating new joined csv. This may take a few moments for large data sets."
        CreateJoinCSV.new.run(request)
        AddRows.new.run(request)
        self.join_result = CSV.parse(File.read(request.new_joined_table ), headers: true)
    end
end

class CreateJoinCSV
    def run(request)
        CSV.open(request.new_joined_table , "a+", :row_sep => "\r\n") do |new_joined_csv|
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
        CSV.open(request.new_joined_table , "a+", :row_sep => "\r\n") do |new_joined_csv|
            current_table_array = []
            AddCurrentTableRows.new.run(request, current_table_array)
            AddJoinTableRows.new.run(request, current_table_array, new_joined_csv)
        end
    end
end

class AddCurrentTableRows
    def run(request, current_table_array)
        CSV.parse(File.read(request.current_table), headers: true) do |current_table_row|
            current_table_array << current_table_row.to_hash
        end
    end
end

class AddJoinTableRows
    def run(request, current_table_array, new_joined_csv)
        CSV.parse(File.read(request.join_table), headers: true) do |join_table_row|
            current_table_array.each do |current_table_row|
                ConnectMatchingRows.new.run(request, current_table_row, join_table_row, new_joined_csv)
            end
        end
    end
end

class ConnectMatchingRows
    def run(request, current_table_row, join_table_row, new_joined_csv)
        current_table_column = request.on_hash[request.current_table.chomp('.csv')]
        join_table_column = request.on_hash[request.join_table.chomp('.csv')]
        if current_table_row[current_table_column] == join_table_row.to_hash[join_table_column]
            temp_array = []
            temp_array += current_table_row.to_hash.values
            temp_array += join_table_row.to_hash.values
            new_joined_csv << temp_array
        end
    end
end
