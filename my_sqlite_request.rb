class MySqliteRequest
    def initialize
        @type_of_request    = :none
        @selected_columns   = []
        @table_name         = nil
        @order              = :asc
    end

    def from(table_name)
    end

    def select(selected_columns)
    end

    def where(column_name, criteria)
    end

    def join(column_on_db_a, filename_db_b, column_on_db_b)
    end

    def order(order, column_name)
    end

    def insert(table_name)
    end

    def values(data)
    end

    def update(table_name)
    end

    def set(data)
    end

    def delete
    end

    def print
        puts "Type of request: #{@type_of_request}"
    end

    def run
        print
    end
end

def _main()
    request = MySqliteRequest.new
    request = request.from('nba_player_data.csv')
    request = request.select('name', 'birth_date')
    request = request.where('name', 'Jerome Allen')
    request.run
    # => [{"name" => "Andre Brown"]
end

_main()
