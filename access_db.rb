require 'win32ole'
class AccessDB
    attr_accessor :mdb, :connection, :data, :fields

    def initialize(mdb=nil)
        @mdb = mdb
        @connection = nil
        @data = nil
        @fields = nil
    end

    def additional_properties
      ""
    end

    def open
        connection_string =  provider
        connection_string << @mdb
        connection_string << additional_properties
        @connection = WIN32OLE.new('ADODB.Connection')
        @connection.Open(connection_string)
    end

    def query(sql)
        recordset = WIN32OLE.new('ADODB.Recordset')
        recordset.Open(sql, @connection)
        @fields = []
        recordset.Fields.each do |field|
            @fields << field.Name
        end
        begin
            @data = recordset.GetRows.transpose
        rescue
            @data = []
        end
        recordset.Close
        @data
    end

    def execute(sql)
        @connection.Execute(sql)
    end

    def close
        @connection.Close
    end

end
