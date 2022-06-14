class ValidateQuery
    def run(cli_array)
        CheckSemiColon.new.run(cli_array)
        CheckKeyword.new.run(cli_array)
        ScanEntireQuery.new.run(cli_array)
        cli_array
    end
end

class CheckSemiColon
    def run(cli_array)
        last_word_last_char = cli_array[-1][-1]
        if last_word_last_char != ';'
            raise "Syntax Error: Your query must end with a `;`"
        end
    end
end

class CheckKeyword
    def run(cli_array)
        first_word = cli_array[0]
        if ["SELECT", "INSERT", "UPDATE", "JOIN", "DELETE"].none?(first_word.upcase)
            raise "Syntax Error: Your query should start with `SELECT`, `INSERT`, `UPDATE`, `JOIN`, or `DELETE`"
        end
    end
end

class ScanEntireQuery
    def run(cli_array)
        temp_array = cli_array.map { |word| Format.new.run(word)}
        temp_array.each_with_index do |word, index|
            CheckWhereArgs.new.run(temp_array, word, index) if word.upcase == "WHERE"
            CheckOnArgs.new.run(temp_array, word, index) if word.upcase == "ON"
            CheckInsertArgs.new.run(temp_array, word, index) if word.upcase == "INSERT"
            CheckOrderArgs.new.run(temp_array, word, index) if word.upcase == "ORDER"
            CheckDeleteArgs.new.run(temp_array, word, index) if word.upcase == "DELETE"
        end
    end
end

class CheckWhereArgs
    def run(temp_array, word, index)
        if !(temp_array[index + 1].include?('=') || temp_array[index + 2].include?('='))
            raise "Syntax error: keyword `WHERE` should be followed by arguments using a format with equal sign: `column_name=criteria` or `column_name = criteria`"
        end
    end
end

class CheckOnArgs
    def run(temp_array, word, index)
        if !(temp_array[index + 1].include?('=') || temp_array[index + 2].include?('='))
            raise "Syntax error: keyword `ON` should be followed by arguments using a format with equal sign: `column_name=criteria` or `column_name = criteria`"
        end
    end
end

class CheckOrderArgs
    def run(temp_array, word, index)
        if temp_array[index + 1] == nil || temp_array[index + 1].upcase != "BY"
            raise "Syntax error: keyword `ORDER` should be followed by the word `BY <column name>`"
        end

        if temp_array[index + 3] != nil && (["ASC", "DESC"].none?(temp_array[index + 3].upcase))
            raise "Syntax error: keywords `ORDER BY <column name>` should be followed by `ASC` or `DESC`"
        end
    end
end

class CheckInsertArgs
    def run(temp_array, word, index)
        if temp_array[index + 1].upcase != "INTO"
            raise "Syntax error: keyword `INSERT` should be followed by `INTO`"
        end
    end
end

class CheckDeleteArgs
    def run(temp_array, word, index)
        if temp_array[index + 1] == nil || temp_array[index + 1].upcase != "FROM"
            raise "Syntax error: keyword `DELETE` should be followed by the words `FROM <table name>`"
        end

        if temp_array[index + 3] != nil && (["WHERE"].none?(temp_array[index + 3].upcase))
            puts
            puts "*Caution: The words `DELETE FROM <table name>` should be followed by `WHERE <columnname> = <criteria>`. Omitting `WHERE` will delete all table records!"
        end
    end
end

class Format
    def run(word)
        word = FormatFirstChar.new.run(word)
        word = FormatLastChar.new.run(word)
    end
end

class FormatFirstChar
    def run(word)
         while word
            first_char = word[0]
            if first_char != nil && (first_char.match?(/[A-Za-z]/) || first_char.match?(/[0-9]/) || ['*', '='].include?(first_char))
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
            if (last_char.match?(/[A-Za-z]/) || last_char.match?(/[0-9]/) || last_char == '.' || ['*', '='].include?(last_char))
                break
            else
                word = word.chomp(last_char)
            end
        end
        word
    end
end
