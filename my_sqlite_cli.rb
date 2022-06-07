require "readline"

class MySqliteQueryCli
    def run!
        while line = Readline.readline("my_sqlite_query_cli> ", true)
            Readline::HISTORY
            Parse.new.run(line)
            line
        end
    end
end

class Parse
    def initialize
        @cli_hash = {}
    end
    def run(cli_entry)
        p cli_array = cli_entry.split(" ")
        p ValidateQuery.new.run(cli_array)
        # p cli_array.map { |word| FormatWord.new.run(word)}
        puts
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
