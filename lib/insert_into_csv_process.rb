class InsertIntoCsvProcess
    def run(request)
        existing_headers_array = CSV.read(request.insert_table, headers: true).headers
        insert_headers_array = request.insert_hash.keys
        validated_values_array = []
        ValidateHashKeys.new.run(existing_headers_array, insert_headers_array)
        CollectValidValues.new.run(request, existing_headers_array, validated_values_array)
        AddValuesToCsv.new.run(request, validated_values_array)
    end
end

class ValidateHashKeys
    def run(existing_headers_array, insert_headers_array)
        existing_headers_array.each do |header_name|
            if insert_headers_array.none?(header_name)
                raise "Advisory: Your input does not include \"#{header_name}\" category"
                return
            end
        end
    end
end

class CollectValidValues
    def run(request, existing_headers_array, validated_values_array)
        existing_headers_array.each do |header_name|
            validated_values_array << request.insert_hash[header_name]
        end
    end
end

class AddValuesToCsv
    def run(request, validated_values_array)
        CSV.open(request.insert_table, "a+", :row_sep => "\r\n") do |csv| # `:row_sep => "\r\n"` needed to append a input values to a new line
            csv << validated_values_array
        end
    end
end
