require 'csv'

class ProcessCsv
    attr_accessor :current_table_data

    def initialize
        @current_table_data = nil
    end

    def run
        puts "Hello from CSV class!!!"
        @current_table_data = CSV.parse(File.read(@table_name), headers: true)
        PrintCsvQuery.new.run(self.current_table_data)
    end
end

class PrintCsvQuery
    def run(table_data)
        table_data.each do |row|
            p row.to_hash
        end
    end
end
