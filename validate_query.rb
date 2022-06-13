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
         p "MADE IT HERE"
         p cli_array
        p temp_array = cli_array.map { |word| Format.new.run(word)}
        puts
        temp_array.each_with_index do |word, index|
            CheckInsertArgs.new.run(temp_array, word, index)
            CheckOnArgs.new.run(temp_array, word, index)

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
    end
end

class CheckInsertArgs
    def run(temp_array, word, index)
        if word.upcase == "INSERT" && temp_array[index + 1].upcase != "INTO"
            raise "Syntax error: keyword `INSERT` should be followed by `INTO`"
        end
    end
end

class CheckOnArgs
    def run(temp_array, word, index)
        if word.upcase == "ON" && temp_array[index + 1].each_char.none?(/\S*\s*=\s*\S*/)
            raise "Syntax error: keyword `ON` should be followed by arguments using a format with equal sign: `column_name=criteria` or `column_name = criteria`"
        end
    end
end

class Format
    def run(word)
        word = FormatFirstChar.new.run(word)
        word = FormatLastChar.new.run(word)
        return word
    end
end

class FormatFirstChar
    def run(word)
         while word
            first_char = word[0]
            puts word
            puts first_char
            puts
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
