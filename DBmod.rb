require './AccessDB.rb'
require './ExcelDB.rb'
require 'win32ole'


database1 = 'C:\Ruby\DatabaseRuby\Test Documents\dbHW_Tracking.mdb'
database2 = 'C:\Ruby\DatabaseRuby\Test Documents\ITSM Deployment Tracking test 9-11.xls'

excelworkpage = "[Sheet1$]"
accessworkpage = "tblMasterList"

########
def shippedOrDeployed(word)
	if (!word.nil?)
		word.downcase == "deployed" || word.downcase == "shipped"
	end
end

def SerialExists(serial, db1)
	db1.query("SELECT * FROM tblMasterList WHERE serial = '" + serial + "'").inspect
end

def UserExistsAlready(lastName, firstName, entry)
	j = nil
	for i in 1..5
		if (entry[0][5 + 9*i] == firstName && entry[0][4 + 9*i] == lastName)
			j = i
		end
	end
	i = j
end

def lastEmptyBundle(entry)
	j = nil
	for i in 1..5
		if (entry[0][4 + 9*i].nil? && entry[0][5 + 9*i].nil? && entry[0][6 + 9*i].nil? && entry[0][7 + 9*i].nil? && entry[0][8 + 9*i].nil? && entry[0][9 + 9*i].nil? && entry[0][10 + 9*i].nil? && j.nil?)
			j = i
		end
	end
	i = j
end

########

time = Time.new

accessdb = AccessDB.new(database1)
accessdb.open

exceldb = ExcelDB.new(database2)
exceldb.open

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
			if(UserExistsAlready(userLastName, userFirstName, accessdb.data))
#				######################
			else 
				emptyBundle = lastEmptyBundle(accessdb.data)

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

