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
            request.run
            RouteRequest.new.run(request)
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

        first_word = cli_array[0]
        if ["SELECT", "INSERT", "UPDATE", "DELETE"].none?(first_word.upcase)
            raise "Syntax Error: Your query should start with `SELECT`, `INSERT`, `UPDATE`, or `DELETE`"
        end

        cli_array.each_with_index do |word, index|
            if word.upcase == "INSERT" && cli_array[index + 1].upcase != "INTO"
                raise "Syntax error: keyword `INSERT` should be followed by `INTO`"
            end

            if word.upcase == "SET" && cli_array[index + 1].each_char.none?('=')
                raise "Syntax error: keyword `SET` should be followed by arguments using a format with equal sign and no spaces `column_name=criteria`"
            end
        end
    end
end

class GetKeywordHash
    attr_accessor :hash

    def initialize
        @hash = {}
    end

    def run(validated_cli_array)
        validated_cli_array.each_with_index do |word, index|
            @hash["QUERY_TYPE"] = QueryType.new.run(validated_cli_array, index)
            @hash["SELECT"] = Select.new.run(validated_cli_array, index) if word.upcase == "SELECT"
            @hash["FROM"] = From.new.run(validated_cli_array, index) if word.upcase == "FROM"
            @hash["INSERT"] = Insert.new.run(validated_cli_array, index) if word.upcase == "INSERT"
            @hash["KEYS"] = Keys.new.run(validated_cli_array, index) if word.upcase == "INSERT"
            @hash["VALUES"] = Values.new.run(validated_cli_array, index) if word.upcase == "VALUES"
            @hash["UPDATE"] = Update.new.run(validated_cli_array, index) if word.upcase == "UPDATE"
            @hash["SET"] = Set.new.run(validated_cli_array, index) if word.upcase == "SET"
            @hash["WHERE"] = Where.new.run(validated_cli_array, index) if word.upcase == "WHERE"
            @hash["JOIN"] = Join.new.run(validated_cli_array, index) if word.upcase == "JOIN"
            @hash["ON"] = On.new.run(validated_cli_array, index) if word.upcase == "ON"
            # Check delete
        end
        @hash
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
            if word[-1] != ','
                @selected_columns << word
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

class Insert
    attr_reader :insert_table

    def initialize
        @insert_table = ""
    end

    def run(cli_array, index)
        @insert_table += cli_array[index + 2]
    end
end

class Keywords
    attr_reader :keywords

    def initialize
        @keywords = ["SELECT",
                     "FROM",
                     "INSERT",
                     "VALUES",
                     "UPDATE",
                     "WHERE",
                     "JOIN",
                     "ON"]
    end
end

class Keys
    attr_reader :keys

    def initialize
        @keys = []
    end

    def run(cli_array, index)
        input_keys_start = index + 3
        if cli_array[input_keys_start][0] == '('
            cli_array[input_keys_start..-1].each_with_index do |word, index|
                if Keywords.new.keywords.include?(word)
                    return @keys
                end
                @keys << Format.new.run(word)
            end
        end
    end
end

class Values
    attr_reader :values

    def initialize
        @values = []
    end

    def run(cli_array, index)
        values_args_start = index + 1
        if cli_array[values_args_start][0] == '('
            cli_array[values_args_start..-1].each_with_index do |word, index|
                if Keywords.new.keywords.include?(word)
                    return @values
                end
                @values << Format.new.run(word)
            end
            return @values
        end
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
        where_args_start = index + 1
        arg = cli_array[where_args_start..-1].join(' ')
        column_name = arg.match(/([\S\s]+)\s*=\s*/).captures[0]
        criteria = arg.match(/\s*=\s*([\S\s]+)/).captures[0]
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
            if (first_char.match?(/[A-Za-z]/) || first_char.match?(/[0-9]/))
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
            if (last_char.match?(/[A-Za-z]/) || last_char.match?(/[0-9]/) || last_char == '.')
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
