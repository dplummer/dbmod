
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
    exceldb.query("SELECT * FROM " + excelworkpage)

    for i in 1..exceldb.data.length

      status = exceldb.data[i-1][4]
      serial = exceldb.data[i-1][7]


      #Check if it is shipped or deployed
      #ignore entry if not shipped or deployed
      if (shippedOrDeployed(status)) 

        accessdb.query("SELECT * FROM tblMasterList WHERE serial = '" + serial + "'")

        #Check if the Serial is in the database
        #if entry not in db, hand inspect
        if (!accessdb.data.empty?) 

          if(!exceldb.data[i-1][1].nil?)
            deployDate = exceldb.data[i-1][1].strftime("%m/%d/%Y")
          end

          assetTag = exceldb.data[i-1][8]
          userFirstName = exceldb.data[i-1][10]
          userLastName = exceldb.data[i-1][11]
          userLogin = exceldb.data[i-1][12]
          requestNumber = exceldb.data[i-1][13]

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
  end

  private

  def shippedOrDeployed(word)
    if (!word.nil?)
      word.downcase == "deployed" || word.downcase == "shipped"
    end
  end

  def user_already_exists?(last_name, first_name, entry)
    5.times do |i|
      if (entry[0][14 + 9*i] == first_name && entry[0][13 + 9*i] == last_name)
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
