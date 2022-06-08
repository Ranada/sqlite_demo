require "readline"

class MySqliteQueryCli
    def run!
        while cli_entry = Readline.readline("my_sqlite_query_cli> ", true)
            Readline::HISTORY
            cli_array = ParseCli.new.run(cli_entry)
            validated_cli_array = ValidateQuery.new.run(cli_array)
            GetKeywordHash.new.run(validated_cli_array)
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
        cli_array.each_with_index do |word, index|
            if word.upcase == "INSERT" && cli_array[index + 1].upcase != "INTO"
                raise "Syntax error: keyword `INSERT` should be followed by `INTO`"
            end
        end
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

class From
    attr_reader :current_table

    def initialize
        @current_table = ""
    end

    def run(cli_array, index)
        @current_table += cli_array[index + 1].chomp(';')
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

class Values
    attr_reader :values

    def initialize
        @values = []
    end

    def run(cli_array, index)
        values_args_start = index + 1
        cli_array[values_args_start..-1].each do |word|
            @values << Format.new.run(word)
        end
        @values
    end
end

class GetKeywordHash
    attr_reader :hash

    def initialize
        @hash = {}
    end

    def run(validated_cli_array)
        validated_cli_array.each_with_index do |word, index|
            # Check select
            @hash["SELECT"] = Select.new.run(validated_cli_array, index) if word.upcase == "SELECT"
            # Check from
            @hash["FROM"] = From.new.run(validated_cli_array, index) if word.upcase == "FROM"
            # Check insert
            @hash["INSERT"] = Insert.new.run(validated_cli_array, index) if word.upcase == "INSERT"
            # Check Values
            p @hash["VALUES"] = Values.new.run(validated_cli_array, index) if word.upcase == "VALUES"
            # Check update
            # Check where
            # Check join on
            # Check delete
        end
        print @hash
        puts
    end
end

class Format
    def run(word)
        word = word.chomp(',')
        word = word.chomp(';')
        first_char = word[0]
        last_char = word[-1]
        if !(last_char.match?(/[A-Za-z]/))
            word.chomp(last_char)
        elsif !(first_char.match?(/[A-Za-z]/))
            word = word[1..-1]
        else
            word
        end
    end
end

MySqliteQueryCli.new.run!
