class OrderProcess
    def run(request)
        if request.order == nil
            DefaultOrder.new.run(request)
        else
            CliEntryOrder.new.run(request)
        end
    end
end

class DefaultOrder
    def run(request)
        request.order = ["First column (default)", "ASC"]
        request.query_result.sort_by! { |hash| hash.values.first }
    end
end

class CliEntryOrder
    def run(request)
        column_name = request.order[0]
        order = request.order[1].upcase
        OrderAsc.new.run(request, column_name) if order == "ASC"
        OrderDesc.new.run(request, column_name) if order == "DESC"
    end

end

class OrderAsc
    def run(request, column_name)
        if request.query_result.each.any? { |key, value| key[column_name] == nil }
            partition_nil_asc(request, column_name)
        else
            request.query_result = request.query_result.sort_by! { |key, value|  key[column_name]}
        end
    end
    def partition_nil_asc(request,column_name)
        partitioned_array = request.query_result.partition { |key, value| key[column_name] != nil }
        partitioned_array[0] = partitioned_array[0].sort_by! { |key, value|  key[column_name]}
        request.query_result = partitioned_array.flatten
    end
end

class OrderDesc
    def run(request, column_name)
        if request.query_result.each.any? { |key, value| key[column_name] == nil }
            partition_nil_desc(request, column_name)
        else
            request.query_result = request.query_result.sort_by! { |key, value|  key[column_name]}.reverse
        end
    end
    def partition_nil_desc(request, column_name)
        partitioned_array = request.query_result.partition { |key, value| key[column_name] != nil }
        partitioned_array[0] = partitioned_array[0].sort_by! { |key, value|  key[column_name]}.reverse
        request.query_result =partitioned_array.flatten
    end
end
