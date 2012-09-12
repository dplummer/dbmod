class DBmod
  attr_reader :accessdb, :exceldb, :accessworkpage, :excelworkpage

  def initialize(accessdb, exceldb, accessworkpage, excelworkpage)
    @accessdb = accessdb
    @exceldb = exceldb
    @accessworkpage = accessworkpage
    @excelworkpage = excelworkpage
  end

  def run
    accessdb_data = accessdb.query("SELECT * FROM " + accessworkpage)
    excel_data = exceldb.query("SELECT * FROM " + excelworkpage)

    (exceldb_data.length).times do |row_number|
      ExcelRow.new(excel_data[row_number], accessdb_data, accessdb)
    end
  end
end
