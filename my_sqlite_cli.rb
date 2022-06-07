require "readline"

class MySqliteQueryCli
    def run!
        while line = Readline.readline("my_sqlite_query_cli> ", true)
            print Readline::HISTORY
            print Parse.new.run(line)
        end
    end
end

class Parse
    def run(cli_entry)
        print "Cli entry: #{cli_entry.split(" ")}\n"
    end
end

cli_entry = MySqliteQueryCli.new.run!
