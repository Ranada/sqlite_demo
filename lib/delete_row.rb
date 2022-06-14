class DeleteRow
    def run(request)
        p "Hello from Delete Row Class"
        result = []
        p column_name = request.where.keys.first
        p criteria = request.where.values.first
        CSV.parse(File.read(request.current_table), headers: true) do |row|
            if row.to_hash[column_name] != criteria
                result << row.to_hash
            end
        end
        CSV.open(request.current_table.chomp, "w+", :row_sep => "\r\n", headers: true)

        CSV.open(request.current_table.chomp, "a+", :row_sep => "\r\n", headers: true) do |csv|
            result.each do |row|
                csv << row.values
            end
        end
    end
end
