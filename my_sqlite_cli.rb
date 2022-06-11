require_relative "my_sqlite_request.rb"
require "readline"

class MySqliteQueryCli
    def run!
        while cli_entry = Readline.readline("my_sqlite_query_cli> ", true)
            Readline::HISTORY
            cli_array = ParseCli.new.run(cli_entry)
            validated_cli_array = ValidateQuery.new.run(cli_array)
            request_hash = GetKeywordHash.new.run(validated_cli_array)
            request = MySqliteRequest.new(request_hash)
            RouteRequest.new.run(request)
            PrintCommand.new.run(request)
        end
    end
end

class ParseCli
    def run(cli_entry)
        cli_entry.split(" ")
    end
end

class ValidateQuery
    def run(cli_array)
        last_word_last_char = cli_array[-1][-1]
        if last_word_last_char != ';'
            raise "Syntax Error: Your query must end with a `;`"
        end

        temp_array = cli_array.map { |word| Format.new.run(word)}

        first_word = temp_array[0]
        if ["SELECT", "INSERT", "UPDATE", "DELETE"].none?(first_word.upcase)
            raise "Syntax Error: Your query should start with `SELECT`, `INSERT`, `UPDATE`, or `DELETE`"
        end

        temp_array.each_with_index do |word, index|
            if word.upcase == "INSERT" && temp_array[index + 1].upcase != "INTO"
                raise "Syntax error: keyword `INSERT` should be followed by `INTO`"
            end

            if word.upcase == "SET" && temp_array[index + 1].each_char.none?('=')
                raise "Syntax error: keyword `SET` should be followed by arguments using a format with equal sign and no spaces `column_name=criteria`"
            end

            if  word.upcase == "ORDER" && temp_array[index + 1] == nil
                raise "Syntax error: keyword `ORDER` should be followed by the word `BY`"
            end

            if  word.upcase == "ORDER" && temp_array[index + 1].upcase != "BY"
                raise "Syntax error: keyword `ORDER` should be followed by the word `BY`"
            end

            if  word.upcase == "ORDER" && (["ASC", "DESC"].none?(temp_array[index + 3].chomp(';').upcase))
                raise "Syntax error: keywords `ORDER BY` then either `ASC` or `DESC`"
            end
        end

        cli_array
    end
end

class Keywords
    attr_reader :keywords

    def initialize
        @keywords = ["SELECT",
                     "FROM",
                     "ORDER",
                     "INSERT",
                     "VALUES",
                     "UPDATE",
                     "SET",
                     "WHERE",
                     "JOIN",
                     "ON"]
    end
end

class GetKeywordHash
    attr_accessor :hash

    def initialize
        @hash = {}
    end

    def run(validated_cli_array)
        puts "VALIDATED"
        validated_cli_array.each_with_index do |word, index|
            @hash["QUERY_TYPE"] = QueryType.new.run(validated_cli_array, index)
            @hash["SELECT"] = Select.new.run(validated_cli_array, index) if word.upcase == "SELECT"
            @hash["FROM"] = From.new.run(validated_cli_array, index) if word.upcase == "FROM"
            @hash["ORDER"] = Order.new.run(validated_cli_array, index) if word.upcase == "ORDER"
            @hash["INSERT_TABLE"] = InsertTable.new.run(validated_cli_array, index) if word.upcase == "INSERT"
            @hash["INSERT_COLUMNS"] = InsertColumns.new.run(validated_cli_array, index) if word.upcase == "INSERT"
            @hash["INSERT_VALUES"] = InsertValues.new.run(validated_cli_array, index) if word.upcase == "VALUES"
            # @hash["INSERT_HASH"] = InsertHash.new.run(self.hash["INSERT_COLUMNS"], self.hash["INSERT_VALUES"]) if word.upcase == "VALUES"
            @hash["UPDATE"] = Update.new.run(validated_cli_array, index) if word.upcase == "UPDATE"
            @hash["SET"] = Set.new.run(validated_cli_array, index) if word.upcase == "SET"
            @hash["WHERE"] = Where.new.run(validated_cli_array, index) if word.upcase == "WHERE"
            @hash["JOIN"] = Join.new.run(validated_cli_array, index) if word.upcase == "JOIN"
            @hash["ON"] = On.new.run(validated_cli_array, index) if word.upcase == "ON"
            # Check delete
        end
        self.hash
    end
end

class QueryType
    def run(cli_array, index)
        cli_array[0].upcase
    end
end

class Select
    attr_reader :selected_columns

    def initialize
        @selected_columns = []
    end

    def run(cli_array, index)
        select_args_start = index + 1
        cli_array[select_args_start..-1].each do |word|
            if Keywords.new.keywords.include?(word.upcase)
                return @selected_columns
            else
                @selected_columns << word.chomp(',')
            end
        end
    end
end

class AppendCsvExtension
    def run(table_name)
        if table_name.end_with?(".csv")
            table_name
        else
            table_name += ".csv"
        end
    end
end

class From
    attr_accessor :current_table
    def initialize
        @current_table = ""
    end

    def run(cli_array, index)
        @current_table += cli_array[index + 1].chomp(';')
        self.current_table = AppendCsvExtension.new.run(self.current_table)
    end
end

class Order
    attr_reader :order

    def initialize
        @order = []
    end

    def run(cli_array, index)
        order_args_start = index + 2
        cli_array[order_args_start..-1].each_with_index do |word, index|
            if Keywords.new.keywords.include?(word.upcase)
                break
            end
            self.order << Format.new.run(word)
        end
        return self.order
    end
end

class InsertTable
    attr_accessor :insert_table

    def initialize
        @insert_table = ""
    end

    def run(cli_array, index)
        self.insert_table += cli_array[index + 2]
        self.insert_table = AppendCsvExtension.new.run(self.insert_table)
    end
end

class InsertColumns
    attr_accessor :insert_columns

    def initialize
        @insert_columns = []
    end

    def run(cli_array, index)
        column_args_start = index + 3
        cli_array[column_args_start..-1].each do |word|
            if word[-1] == ')'
                self.insert_columns << word
                break
            else
                self.insert_columns << word
            end
        end
        insert_columns_string = self.insert_columns.join(' ')
        transform_array = insert_columns_string.split(', ')
        self.insert_columns = transform_array.map { |word| Format.new.run(word) }
    end
end

class InsertValues
    attr_accessor :insert_values

    def initialize
        @insert_values = []
    end

    def run(cli_array, index)
        p "INSERT VALUES"
        value_args_start = index + 1
        cli_array[value_args_start..-1].each do |word|
            if word[-1] == ')'
                self.insert_values << word
                break
            else
                self.insert_values << word
            end
        end
        months = ["JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER"]
        insert_values_string = self.insert_values.join(' ')
        values_array = insert_values_string.split(', ')

        transform_array = []
        date_array = []

        index = 0
        while index < values_array.length
            word = values_array[index]

            if months.any? { |month| word.upcase.include?(month) }
                date_array << word
                date_array << values_array[index + 1]
                transform_array << date_array.join(', ')
                index += 1
            else
                transform_array << word
            end

            index += 1
        end

        self.insert_values = transform_array.map { |word| Format.new.run(word) }
    end
end

class InsertHash
    attr_accessor :insert_hash

    def intialize
        @insert_hash = {}
    end

    def run(insert_columns, insert_values)
        p "INSERT HASH"
        p insert_columns
        p insert_values
        p insert_columns.zip(insert_values) { |column, value| self.insert_hash[column] = value }
        p self.insert_hash
    end
end

class Update
    attr_reader :update_table

    def initialize
        @update_table = ""
    end

    def run(cli_array, index)
        @update_table += cli_array[index + 1]
    end
end

class Set
    attr_reader :set

    def initialize
        @set = []
    end

    def run(cli_array, index)
        @set += cli_array[index + 1].split(/=|\s=\s/)
        @set = @set.map { |word| Format.new.run(word)}
    end
end

class Where
    attr_reader :where

    def initialize
        @where = {}
    end

    def run(cli_array, index)
        args = []
        where_args_start = index + 1
        cli_array[where_args_start..-1].each do |word|
            if Keywords.new.keywords.include?(word.upcase)
                break
            else
                args << word
            end
        end
        args = args.join(' ')
        column_name = args.match(/([\S\s]+)\s*=\s*/).captures[0]
        criteria = args.match(/\s*=\s*([\S\s]+)/).captures[0]
        column_name = Format.new.run(column_name)
        criteria = Format.new.run(criteria)
        self.where[column_name] = criteria
        self.where
    end
end

class Join
    attr_reader :join_table

    def initialize
        @join_table = ""
    end

    def run(cli_array, index)
        @join_table += cli_array[index + 1]
        @join_table = Format.new.run(@join_table)
    end
end

class On
    attr_reader :on

    def initialize
        @on = []
    end

    def run(cli_array, index)
        cli_array[index + 1]
    end
end

class FormatFirstChar
    def run(word)
         while word
            first_char = word[0]
            if (first_char.match?(/[A-Za-z]/) || first_char.match?(/[0-9]/) || first_char == '*')
                break
            else
                word = word[1..-1]
            end
        end
        word
    end
end

class FormatLastChar
    def run(word)
        while word
            last_char = word[-1]
            if (last_char.match?(/[A-Za-z]/) || last_char.match?(/[0-9]/) || last_char == '.' || last_char == '*')
                break
            else
                word = word.chomp(last_char)
            end
        end
        word
    end
end

class Format
    def run(word)
        word = FormatFirstChar.new.run(word)
        word = FormatLastChar.new.run(word)
        return word
    end
end

MySqliteQueryCli.new.run!
