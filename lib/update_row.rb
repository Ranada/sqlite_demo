class UpdateRow
    def run(request)
        headers = CSV.read(request.update_table, :headers => true).headers
        rows_to_update = []
        CollectRowsToUpdate.new.run(request, rows_to_update)
        CSV.open(request.update_table, "w+", :row_sep => "\r\n", :headers => true)
        AddRowsToUpdate.new.run(request, headers, rows_to_update)
    end
end

class CollectRowsToUpdate
    def run(request, rows_to_update)
        p "COLLECT ROWS"
        p where_column_name = request.where.keys.first
        p where_criteria = request.where.values.first
        p set_column_name = request.set.keys.first
        p set_criteria = request.set.values.first
        CSV.parse(File.read(request.update_table), :headers => true) do |row|
            if row.to_hash[where_column_name] == where_criteria
                rows_to_update << row.to_hash.merge!({set_column_name => set_criteria})
            else
                rows_to_update << row.to_hash
            end
        end
    end
end

class AddRowsToUpdate
    def run(request, headers, rows_to_update)
        CSV.open(request.update_table.chomp, "a+", :row_sep => "\r\n", :headers => true) do |csv|
            csv << headers
            rows_to_update.each do |row|
                csv << row.values
            end
        end
    end
end
