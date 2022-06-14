class UpdateCsvProcess
    def run(request)
        # CSV.open(request.update_table , "r+", headers: true) do |csv|
        CSV.open(request.update_table , "r+", :row_sep => "\r\n", headers: true) do |csv|
            csv.each do |update_table_row|
                column_name = request.where.keys.first
                criteria = request.where.values.first
                if (update_table_row[column_name] != nil) && (update_table_row[column_name].downcase == criteria.downcase)
                    update_table_row = update_table_row.to_hash.update(update_table_row.to_hash) do |key, value|
                        if key == "name"
                            value = "New Person"
                        else
                            value
                        end
                    end
                    csv << update_table_row.to_hash.values.to_a
                    # p update_table_row.to_hash.values.to_a.each { | element | csv << [element] }

                    # csv << update_table_row.to
                end
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
