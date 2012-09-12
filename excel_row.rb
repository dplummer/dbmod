class ExcelRow
  attr_reader :row, :accessdb, :accessdb_data, :status, :serial, :asset_tag,
    :user_first_name, :user_last_name, :user_login, :request_number,
    :accessdb_record

  def initialize(row, accessdb_data, accessdb)
    @row = row
    @accessdb_data = accessdb_data
    @accessdb = accessdb

    @status = row[4]
    @serial = row[7]

    @asset_tag = row[8]
    @user_first_name = row[10]
    @user_last_name = row[11]
    @user_login = row[12]
    @request_number = row[13]

    @deploy_date = row[1].strftime("%m/%d/%Y") if row[1]

    @serial_record = accessdb.
      query("SELECT * FROM tblMasterList WHERE serial = '#{serial}'")
  end

  def run
    return unless shippedOrDeployed(status)

    #Check if the Serial is in the database
    #if entry not in db, hand inspect
    if (!serial_record.empty?)
      #Check if the user has already separated from equipment
      unless user_already_exists?
        emptyBundle = last_empty_bundle(accessdb_data)

        #Find which User in access the first empty
        if emptyBundle
          update_accessdb

        #All users spots are full
        else
          puts "#{serial} Error: All Fields Full"
        end
      end
    else
      puts "#{serial} Error: DNE" 
    end
  end

  def update_accessdb
    if (user_last_name.nil? && user_first_name.nil?)
      @user_last_name = user_login
      @user_first_name = user_login
    end

    sql = <<-SQL
UPDATE tblMasterList SET RecordLastUpdate = '#{time.strftime("%m/%d/%Y")}',
User#{emptyBundle}_LastName = '#{escape_sql(userLastName)}',
User#{emptyBundle}_FirstName = '#{escape_sql(userFirstName)},
User#{emptyBundle}_DeploymentRefNum = #{requestNumber},
User#{emptyBundle}_DeploymentDate = '#{escape_sql(deployDate)}''
WHERE SERIAL = '#{escape_sql(serial)}';
SQL

    accessdb.execute(sql) 
  end

  private

  def escape_sql(sql)
    sql.gsub(/'/, "''")
  end

  def shippedOrDeployed(word)
    if (!word.nil?)
      word.downcase == "deployed" || word.downcase == "shipped"
    end
  end

  def user_already_exists?
    5.times do |i|
      if (@serial_record[0][14 + 9*i] == @first_name &&
          @serial_record[0][13 + 9*i] == @last_name)
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
