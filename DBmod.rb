class ExcelRow
  attr_reader :row, :accessdb

  def initialize(row, accessdb)
    @row = row
    @accessdb = accessdb

    @status = row[4]
    @serial = row[7]

    @asset_tag = row[8]
    @user_first_name = row[10]
    @user_last_name = row[11]
    @user_login = row[12]
    @request_number = row[13]

    @accessdb_record = accessdb.
      query("SELECT * FROM tblMasterList WHERE serial = '#{serial}'")[0]
  end

  def run
    #Check if it is shipped or deployed
    #ignore entry if not shipped or deployed
    if (shippedOrDeployed(status))

      #Check if the Serial is in the database
      #if entry not in db, hand inspect
      if (!accessdb.data.empty?) 

        if(!exceldb.data[row_number][1].nil?)
          deployDate = exceldb.data[row_number][1].strftime("%m/%d/%Y")
        end

        #Check if the user has already separated from equipment
        if(user_already_exists?(userLastName, userFirstName, accessdb.data))
  #				######################
        else 
          emptyBundle = last_empty_bundle(accessdb.data)

          #Find which User in access the first empty
          if(emptyBundle != nil)

            if (userLastName.nil? && userFirstName.nil?)
              userLastName = userLogin
              userFirstName = userLogin
            end

            update = "UPDATE tblMasterList SET RecordLastUpdate = '" + time.strftime("%m/%d/%Y")
            update << "', User" + emptyBundle.to_s + "_LastName = '" + userLastName.to_s
            update << "', User" + emptyBundle.to_s + "_FirstName = '" + userFirstName.to_s	
            update << "', User" + emptyBundle.to_s + "_DeploymentRefNum = " + requestNumber.to_s
            update << ", User" + emptyBundle.to_s + "_DeploymentDate = '" + deployDate.to_s	



            update << "' WHERE SERIAL = '" + serial.to_s + "';"
            puts update
            puts ""
            sql = update

            accessdb.execute(sql) 

          #All users spots are full
          else
            puts serial + " Error: All Fields Full"
          end
        end
      elsif
        puts serial + " Error: DNE" 
      end
    end
  end

  private

  def shippedOrDeployed(word)
    if (!word.nil?)
      word.downcase == "deployed" || word.downcase == "shipped"
    end
  end

  def user_already_exists?
    5.times do |i|
      if (@accessdb_record[14 + 9*i] == @first_name &&
          @accessdb_record[13 + 9*i] == @last_name)
        return true
      end
    end
    false
  end

  def last_empty_bundle(entry)
    5.times do |i|
      if entry[0][13 + 9*i].nil? &&
         entry[0][14 + 9*i].nil? &&
         entry[0][15 + 9*i].nil? &&
         entry[0][16 + 9*i].nil? &&
         entry[0][17 + 9*i].nil? &&
         entry[0][18 + 9*i].nil? &&
         entry[0][19 + 9*i].nil?
        return i
      end
    end
    nil
  end
end

class DBmod
  attr_reader :accessdb, :exceldb, :accessworkpage, :excelworkpage

  def initialize(accessdb, exceldb, accessworkpage, excelworkpage)
    @accessdb = accessdb
    @exceldb = exceldb
    @accessworkpage = accessworkpage
    @excelworkpage = excelworkpage
  end

  def run
    accessdb.query("SELECT * FROM " + accessworkpage)
    excel_data = exceldb.query("SELECT * FROM " + excelworkpage)

    (exceldb_data.length).times do |row_number|
      ExcelRow.new(excel_data[row_number], accessdb)
    end
  end
end
