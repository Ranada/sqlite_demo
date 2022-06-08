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
        cli_array
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

class GetKeywordHash
    attr_reader :hash

    def initialize
        @hash = {}
    end

    def run(validated_cli_array)
        validated_cli_array.each_with_index do |word, index|
            # Check select
            p @hash["SELECT"] = Select.new.run(validated_cli_array, index) if word.upcase == "SELECT"
            # Check from
            p @hash["FROM"] = From.new.run(validated_cli_array, index) if word.upcase == "FROM"
            # Check insert
            # Check update
            # Check where
            # Check join on
            # Check delete
        end
        p @hash
    end
end

class FormatWord
    def run(word)
        last_char = word[-1]
        if !(last_char.match?(/[A-Za-z]/))
            word.chomp(last_char)
        else
            word
        end
    end
end

MySqliteQueryCli.new.run!
