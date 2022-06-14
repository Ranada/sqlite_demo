class UpdateCsvProcess
    def run(request)
        CSV.open(request.update_table , "a+", :row_sep => "\r\n", headers: true) do |csv|
            csv.each do |update_table_row|
                column_name = request.where.keys.first
                criteria = request.where.values.first
                if (update_table_row[column_name] != nil) && (update_table_row[column_name].downcase == criteria.downcase)
                    p "UPDATE THIS ROW"
                    p update_table_row.to_hash["name"] = "New Name"
                    p
                end
                p "UPDATE RESULT"
                p update_table_row.to_hash
                p
            end

            # CSV.parse(File.read(request.update_table), headers: true) do |update_table_row|
            #     column_name = request.where.keys.first
            #     criteria = request.where.values.first
            #     if (update_table_row[column_name] != nil) && (update_table_row[column_name].downcase == criteria.downcase)
            #         p "UPDATE THIS ROW"
            #         p update_table_row.to_hash["name"] = "New Name"
            #         p
            #     end
            # end
        end
    end
end
