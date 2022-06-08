require "readline"

class MySqliteQueryCli
    attr_reader :hash

    def initialize
        @hash = {}
    end
    def run!
        while cli_entry = Readline.readline("my_sqlite_query_cli> ", true)
            Readline::HISTORY
            cli_array = Parse.new.run(cli_entry)
            validated_array = ValidateQuery.new.run(cli_array)
        end
    end
end

class Parse
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
    end
end

class GetQueryHash
    def run(cli_array)
        cli_array.each_with_index do |word, index|
            # Check select
            # Check from
            # Check insert
            # Check update
            # Check where
            # Check join on
            # Check delete
        end
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
