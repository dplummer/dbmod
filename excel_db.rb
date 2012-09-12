require './AccessDB.rb'

class ExcelDB < AccessDB
  def additional_properties
    ';Extended Properties=Excel 8.0;'
  end
end
