class DeleteRow
    def run(request)
        headers = CSV.read(request.current_table, :headers => true).headers
        rows_to_keep = []
        CollectRowsToKeep.new.run(request, rows_to_keep)
        CSV.open(request.current_table, "w+", :row_sep => "\r\n", headers: true)
        AddRowsToKeep.new.run(request, headers, rows_to_keep)
    end
end

class CollectRowsToKeep
    def run(request, rows_to_keep)
        column_name = request.where.keys.first
        criteria = request.where.values.first
        CSV.parse(File.read(request.current_table), headers: true) do |row|
            rows_to_keep << row.to_hash if row.to_hash[column_name] != criteria
        end
    end
end

class AddRowsToKeep
    def run(request, headers, rows_to_keep)
        CSV.open(request.current_table.chomp, "a+", :row_sep => "\r\n", headers: true) do |csv|
            csv << headers
            rows_to_keep.each do |row|
                csv << row.values
            end
        end
    end
end
