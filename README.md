# Milk_backup_data
Matlab scripts to merge and preprocess daily milkings

>>>>>    SQL installation  
To access the .bak files, you should first download Microsoft SQL Management Studio, e.g. through this link: 
https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-2017

Then you need to install a local server on your PC. In principle, e.g. SQL Server 2017 Express which is free should do the job (datasets up till 10 GB data). You can download it here: https://www.microsoft.com/en-gb/sql-server/sql-server-downloads

Then, open the SSMS and see whether you can connect with your local server.

After you run the installation of both, we’ll need to see whether there are extra permissions needed for your SQL Express to access the folders where the data files are stored. 
If you cannot access folders or files on your PC, you might need to add your local server’s profile as a user in your folders following the steps in this link: https://docs.microsoft.com/en-us/sql/database-engine/configure-windows/configure-file-system-permissions-for-database-engine-access?view=sql-server-2017

After installation of SSMS, you first need to:
1)	Connect your object explorer with your local server:
a.	File > Connect to Object Explorer…
b.	Server Type = Database Engine // Server Name = your computer name (you find it in ‘Computer Management > Device Manager) // ‘Window Authentication’ 
c.	Press ‘connect’

Once connected with your local server, you can restore a .bak file as follows: 

>>>>>    Connect to database  
1)	Open the Object Explorer
2)	Right click ‘Databases’ > ‘Restore Database…’
3)	In the tab ‘General’ > click ‘Device’ and then the button with three dots (…)
4)	In the new window (Select backup devices) > click Add  > go to file location > select .bak file  > OK 
5)	In the tab ‘Options’, tick the box ‘Overwrite the existing database (WITH REPLACE)’  (or you can first detach the previous loaded database)


>>>>>     LELY .bak files 
Extract tables and save them as flat files from LELY .bak files
You can first check the tables and the content if you want to, by opening the different contents and selecting ‘Select top 1000 rows’ or ‘Edit top 200 rows’
1)	Roll out ‘Databases’ in the Object Explorer
2)	Right click the ‘Lely’ database > Tasks > Export data
3)	In ‘Choose a Data Source’ you pick ‘SQL Server Native Client 11.0’ from the dropdown menu and make sure ‘Lely’ is the selected database, then click ‘next’
4)	In ‘Choose a Destination’ you pick ‘Flat file Destination’ from the dropdown menu; Browse to your preferred location and create a File Name in there, then click ‘next’
5)	In ‘Specify a table or Query’, you tick ‘Copy data from one or more tables or views’, then click ‘next’ --  in the future, I’ll write the query so we don’t have to repeat these steps manually, but for now it’s this I guess, sorry for that…
6)	In ‘Configure Flat File Destination’, you select the appropriate table, the ones you need from the LELY back-ups are:
a.	HemAnimal         >> Animal Identification, birthdates, user and life numbers etc.
b.	HemDia gnoses  >> Diagnoses if recorded in the software
c.	PrmActivityScr    >> Raw activity data
d.	PrmDeviceVisit   >> Identifiers for the device visits, besides milkings also other visits
e.	PrmMilkDayProduction >> Per day production data
f.	RemLactation     >> Detailed Lactation and calving data
7)	Row delimiter = {CR}{LF}
8)	Column delimiter = Semicolon    {;}, then click ‘next’
9)	‘Save and Run Package’ > just click next
10)	Click ‘Finish’ (after this, you can read how many lines were transferred; which always interesting to keep track of)

>>>>>     DELAVAL.bak files
Extract tables and save them as flat files from  DELAVAL.bak files
For Delaval files, this is very similar, two main differences: the tables contents vary with software version, and you might need more tables to have the same information.
•	Idem as above
•	Right click the ‘DDM’ or ‘DDMVMS’ database > Tasks > Export data. Which DB you need depends on the software version, make sure you keep track of how it’s called when you restore!
•	Idem as above
•	Idem as above
•	Idem as above
•	Idem as above
•	In ‘Configure Flat File Destination’, you select the appropriate table, the ones you need from the DELAVAL back-ups are:
a.	VERSION v3.7
i.	BasicAnimal                        >> Animal Identification, birthdates, user and life numbers etc --> save as xlsx
ii.	AnimalHistoricalData               >> 
iii.	SessionMilkYield                   >> Milking data per milking
iv.	VoluntarySessionMilkYield          >> Details of per milking session (!!! Export in xlsx file & indicate ‘ignore’ upon error !!!)
v.	DailyMilk                          >> Daily data
vi.	AnimalLactationSummary             >> Lactation information
vii.	HistoryAnimalTreatments            >> Diagnoses if recorded in the software (optional)
b.	VERSIONS v4.x and v5.x
i.	BasicAnimal                        >> Animal Identification, birthdates, user and life numbers etc
ii.	SessionMilkYield                   >> Milking data per milking
iii.	VoluntarySessionMilkYield          >> Details of per milking session (!!! Export in xlsx file & indicate ‘ignore’ upon error !!!)
iv.	HistoryAnimalLactationInfo         >> Details of lactations
v.	HistoryAnimal                      >> Animal details
vi.	HistoryAnimalDailyData             >> Daily data



>>>>    DELAVAL SOFTWARE
tables to be extracted from the back-up files.


>>>>> Delpro v3.7

-	BasicAnimal			
      contains animal information, including user and life numbers
-	AnimalHistoricalData
      contains date and time, days in milk, lactation number, (previous) end time
-	SessionMilkYield	c
      contains the information of each milking session, incl. date and time
-	VoluntarySessionMilkYield	
      contains sensor data of each milking session
-	DailyMilk			
      contains daily yield, average 7D yield, duration
-	LactationHistorySummary
      contains details of each lactation

	No AnimalDaily; daily data in AHD and DailyMilk
	Lactation number to be extracted from AnimalHistoricalData or from LactationHistorySummary

>>>>> Delpro v4.5

-	BasicAnimal			
      contains animal information, including user and life numbers
-	AnimalDaily			
      contains daily yield, lactation, yield 7D average, days in milk
-	SessionMilkYield		
      contains the information of each milking session, incl. date and time
-	VoluntarySessionMilkYield	
      contains sensor data of each milking session
-	AnimalLactationHistory		
      contains animal, lactation numbers, start date of lactation (calving)
-	HistoryAnimal			
      contains historical animal information
-	HistoryAnimalTreatment	
      contains treatment data if registered in the AMS software
-	HistoryAnimalDailyData	
      contains all daily historical data!!
-	HistoryAnimalLactationInfo	
      contains lactation information

	AnimalDaily contains SOME historical yield data of the farm
	HistoryAnimalDailyData contains ALL historical daily (yield) data of a farm
	DailyMilk often does not exist in these back-up files


>>>>> Delpro v5.1/5.2/5.3

-	BasicAnimal			
      contains animal information, including user and life numbers
-	AnimalDaily			
      contains daily yield, lactation, yield 7D average, days in milk
-	SessionMilkYield		
      contains the information of each milking session, incl. date and time
-	VoluntarySessionMilkYield	
      contains sensor data of each milking session
-	AnimalLactationHistory		
      contains animal, lactation numbers, start date of lactation (calving)
-	HistoryAnimal			
      contains historical animal information
-	HistoryAnimalTreatment	        
      contains treatment data if registered in the AMS software
-	HistoryAnimalDailyData	        
      contains all daily historical data!!
-	HistoryAnimalLactationInfo	
      contains lactation information

 
