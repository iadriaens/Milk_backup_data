# Milk_backup_data
Matlab scripts to merge and preprocess daily milkings

>>>>>>>>>>>>>>>>>>>>>    SQL installation   <<<<<<<<<<<<<<<<<<<<<<
To access the .bak files, you should first download Microsoft SQL Management Studio, e.g. through this link: 
https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-2017

Then you need to install a local server on your PC. In principle, e.g. SQL Server 2017 Express which is free should do the job (datasets up till 10 GB data). You can download it here: https://www.microsoft.com/en-gb/sql-server/sql-server-downloads

Then, open the SSMS and see whether you can connect with your local server (just give me a sign then, and I come to have a look, I don’t know it by heart anymore...).

After you run the installation of both, we’ll need to see whether there are extra permissions needed for your SQL Express to access the folders where the data files are stored. 
If you cannot access folders or files on your PC, you might need to add your local server’s profile as a user in your folders following the steps in this link: https://docs.microsoft.com/en-us/sql/database-engine/configure-windows/configure-file-system-permissions-for-database-engine-access?view=sql-server-2017

After installation of SSMS, you first need to:
1)	Connect your object explorer with your local server:
a.	File > Connect to Object Explorer…
b.	Server Type = Database Engine // Server Name = your computer name (you find it in ‘Computer Management > Device Manager) // ‘Window Authentication’ 
c.	Press ‘connect’

Once connected with your local server, you can restore a .bak file as follows: 

>>>>>>>>>>>>>>>>>>>>>    Connect to database   <<<<<<<<<<<<<<<<<<<<<<
1)	Open the Object Explorer
2)	Right click ‘Databases’ > ‘Restore Database…’
3)	In the tab ‘General’ > click ‘Device’ and then the button with three dots (…)
4)	In the new window (Select backup devices) > click Add  > go to file location > select .bak file  > OK 
5)	In the tab ‘Options’, tick the box ‘Overwrite the existing database (WITH REPLACE)’  (or you can first detach the previous loaded database)


>>>>>>>>>>>>>>>>>>>>>     LELY .bak files   <<<<<<<<<<<<<<<<<<<<<<
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

>>>>>>>>>>>>>>>>>>>>>     DELAVAL.bak files   <<<<<<<<<<<<<<<<<<<<<<
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
i.	BasicAnimal                                      >> Animal Identification, birthdates, user and life numbers etc
ii.	AnimalHistoricalData                      >> Raw activity data
iii.	SessionMilkYield                              >> Milking data per milking
iv.	VoluntarySessionMilkYield            >> Details of per milking session (!!! Export in xlsx file & indicate ‘ignore’ upon error !!!)
v.	DailyMilk                                           >> Daily data
vi.	AnimalLactationSummary             >> Lactation information
vii.	HistoryAnimalTreatments             >> Diagnoses if recorded in the software (optional)
b.	VERSIONS v4.x and v5.x
i.	BasicAnimal                                      >> Animal Identification, birthdates, user and life numbers etc
ii.	SessionMilkYield                              >> Milking data per milking
iii.	VoluntarySessionMilkYield            >> Details of per milking session (!!! Export in xlsx file & indicate ‘ignore’ upon error !!!)
iv.	HistoryAnimalLactationInfo          >> Details of lactations
v.	HistoryAnimal                                   >> Animal details
vi.	HistoryAnimalDailyData                 >> Daily data



>>>>>>>>>>>>>>>>>>>>>    DELAVAL SOFTWARE   <<<<<<<<<<<<<<<<<<<<<<
tables to be extracted from the back-up files.


Delpro v3.7

-	BasicAnimal			contains animal information, including user and life numbers
-	AnimalHistoricalData		contains date and time, days in milk, lactation number, (previous) end 
				time
-	SessionMilkYield		contains the information of each milking session, incl. date and time
-	VoluntarySessionMilkYield	contains sensor data of each milking session
-	DailyMilk			contains daily yield, average 7D yield, duration
-	LactationHistorySummary	contains details of each lactation

	No AnimalDaily; daily data in AHD and DailyMilk
	Lactation number to be extracted from AnimalHistoricalData or from LactationHistorySummary

Delpro v4.5

-	BasicAnimal			contains animal information, including user and life numbers
-	AnimalDaily			contains daily yield, lactation, yield 7D average, days in milk
-	SessionMilkYield		contains the information of each milking session, incl. date and time
-	VoluntarySessionMilkYield	contains sensor data of each milking session
-	AnimalLactationHistory		contains animal, lactation numbers, start date of lactation (calving)
-	HistoryAnimal			contains historical animal information
-	HistoryAnimalTreatment	contains treatment data if registered in the AMS software
-	HistoryAnimalDailyData	contains all daily historical data!!
-	HistoryAnimalLactationInfo	contains lactation information

	AnimalDaily contains SOME historical yield data of the farm
	HistoryAnimalDailyData contains ALL historical daily (yield) data of a farm
	DailyMilk often does not exist in these back-up files


Delpro v5.1/5.2/5.3

-	BasicAnimal			contains animal information, including user and life numbers
-	AnimalDaily			contains daily yield, lactation, yield 7D average, days in milk
-	SessionMilkYield		contains the information of each milking session, incl. date and time
-	VoluntarySessionMilkYield	contains sensor data of each milking session
-	AnimalLactationHistory		contains animal, lactation numbers, start date of lactation (calving)
-	HistoryAnimal			contains historical animal information
-	HistoryAnimalTreatment	contains treatment data if registered in the AMS software
-	HistoryAnimalDailyData	contains all daily historical data!!
-	HistoryAnimalLactationInfo	contains lactation information

 
Detailed contents v3.7

BasicAnimal (v3.7)
OID / SystemEntryTimeStamp / Number / OfficialRegNo/ AnimalGuid / Name / Type / Sex / Breed / BirthDate / Comment /CommentDate / ExitDate / IsCulled /Modified / PedigreeInfo / CalfSize / CalfHealthStatus / CalfUsage / Group / TransponderID / TransponderType / EarTagLeft / EarTagRight / BirthWeight / IsTwin / BirthEvent / ToBeCulled / LatestHistoryIndex / OptimisticLockField / GCRecord / ObjectType / ManualRationControl / CurrentFeedTable / ConsumptionRate / ActivitySetting / BullID

AnimalHistoricalData (v3.7)
OID / SystemEntry / ObjectGuid / DateAndTime / BasicAnimal / AnimalGroup / DIM / LactationNumber / OptimiticLockField / GCRecord / ObjectType / EndTime / Device / PreviousEndTime / Action

DailyMilk (v3.7)
OID / TotalYield / Duration / SevenDayAverageYield

AnimalLactationSummary (v3.7)
OID / Animal / LactationNumber / StartDate / EndDate / PeakYield / DaysToPeak / OptimisticLockField / GCRecord

SessionMilkYield (v3.7)
OID / SessionNo / TotalYield / Destination / IsManual / AutomaticMilkRecordChanged / User / ExpectedYield  / AdditionalMilkInfo

VoluntarySessionMilkYield (v3.7)
OID / ExpectedRateLF / ExpectedRateRF / ExpectedRateLR / ExpectedRateRR/ 	CarryoverLF / CarryoverRF / CarryoverLR / CarryoverRR / QuarterLFYield / QuarterRFYield	QuarterLRYield / QuarterRRYield / MilkType / Kickoff / Incomplete / NotMilkedTeats / ConductivityLF / ConductivityRF / ConductivityLR / ConductivityRR / BloodLF / BloodRF / BloodLR / BloodRR / PeakFlowLF/ PeakFlowRF / PeakFlowLR / PeakFlowRR / MeanFlowLF / MeanFlowRF / MeanFlowLR / MeanFlowRR / Occ / Mdi / Performance / SampleTube / SampleTubeRack / SampleTubePosition / CurrentCombinedAmd / YieldExpectedLF / YieldExpectedRF / YieldExpectedLR / YieldExpectedRR / UdderCounter / UdderCounterFlags / TeatCounterLF / TeatCounterLR / TeatCounterRF / TeatCounterRR / TeatCounterFlagsLF / TeatCounterFlagsLR / TeatCounterFlagsRF / TeatCounterFlagsRR / CleaningProgramNumber / DiversionReason / AmsSerialData 


Detailed contents v4.5

BasicAnimal (v4.5)
OID / SystemEntryTimeStamp / Number / OfficialRegNo / AnimalGuid / Name / Type / Sex / Breed / BirthDate / Comment / CommentDate / ExitDate / Modified / PedigreeInfo / CalfSize / CalfHealthStatus / CalfUsage / Group / TransponderID / TransponderType / EarTagLeft / EarTagRight / BirthWeight / IsTwin / BirthEvent / ToBeCulled / LatestHistoryIndex / OptimisticLockField / GCRecord / ObjectType / ManualRationControl / CurrentFeedTable / ConsumptionRate / ActivitySetting / BullID / ExitType / DrinkData / MilkingTestAnimal

AnimalDaily (v4.5)
OID / Date / BasicAnimal / AnimalGroup / LactationNumber / TotalYield / IsYieldValid / Duration / AvgYieldPrev7d / ConcentratesConsumed / RoughageConsumed / GCRecord / DSLC

AnimalLactationSummary (v4.5)
OID / Animal / LactationNumber / StartDate / EndDate / PeakYield / DaysToPeak / OptimisticLockField / GCRecord 

HistoryAnimal (v4.5)
OID / Number / OffRegNumber / LastGroup / Gender / Breed / BirthDate / LactationNumber / FatherORN / MotherORN / TBCDate / ExitDate / ExitReason / EntryEventDate / ExitType / CullDecisionDate

HistoryAnimalLactationInfo (v4.5)
OID / HistoryTotalYield / Animal / LactationNumber / StartDate / FirstHeatDay / BullGroupEntryDay / BullGroupExitDay / HeatCount / InseCount / PregnantDays / OpenDays / DriedDay / BuildUpDay / IsLactationAborted / EndDay / TotalYield / MatureEquivalent / MilkIncome / DaysToPeak / ConcConsumed / RoughageConsumed / TotalConsumed / ConsumedDM / ConsumedTMR / FeedCost / AvgFat / AvgProtein / AvgCellCount  

HistoryAnimalDailyData (v4.5)
OID / DayDate / Animal / Group / LactationNumber / ReproStatus / DIM / DailyYield / Last7DayAvg / RelativeYield / MilkingDurationInSec / Milkings / MilkIncome / ConcConsumed / TotalConsumed / TMRConsumed / PercConsumed / DMConsumed / Feedings / Feedcost / Kickoffs / Incompletes / AvgConductivity / AvgBlood / AcgCellCount / AvgFat / AcgProtein / AcgBCS / AcgWeight / AvgRectaltemp / DSLC  

HistoryAnimalTreatment (v4.5)
OID / Animal / Group / LactationNumber / TreatStartDate / DurationInDays / TreatmentName / TreatmentCost / DivertedMilk / MilkCost / DrugInfo

SessionMilkYield (v4.5)
OID / ObjectGuid / BeginTime / BasicAnimal / AnimalDaily / EndTime / MilkingDevice / PreviousEndTime / SessionNo / TotalYield / Destination / AvgConductivity / MaxConductivity / AverageConductivity7Days / RelativeConductivity / AverageBlood / MaxBlood / ModifiedSource / User / ExpectedYield / SampleTube / SampleTubeRack / SampleTubePosition / ObjectType

VoluntarySessionMilkYield (v4.5)
OID / ExpectedRateLF / ExpectedRateRF / ExpectedRateLR / ExpectedRateRR/ 	CarryoverLF / CarryoverRF / CarryoverLR / CarryoverRR / QuarterLFYield / QuarterRFYield	/ QuarterLRYield / QuarterRRYield / MilkType / Kickoff / Incomplete / NotMilkedTeats / ConductivityLF / ConductivityRF / ConductivityLR / ConductivityRR / BloodLF / BloodRF / BloodLR / BloodRR / PeakFlowLF / PeakFlowRF / PeakFlowLR / PeakFlowRR / MeanFlowLF / MeanFlowRF / MeanFlowLR / MeanFlowRR / Occ / OccAverage / Mdi / Performance / CurrentCombinedAmd / YieldExpectedLF / YieldExpectedRF / YieldExpectedLR / YieldExpectedRR / UdderCounter / UdderCounterFlags / TeatCounterLF / TeatCounterLR / TeatCounterRF / TeatCounterRR / TeatCounterFlagsLF / TeatCounterFlagsLR / TeatCounterFlagsRF / TeatCounterFlagsRR / CleaningProgramNumber / DiversionReason / AmsSerialData / OccHealthClass / OccEmr / SelectiveTakeoffApplied / SelectiveAttach / SmartPulsationRatio

Detailed contents v5.1

BasicAnimal (v5.1)
OID / SystemEntryTimeStamp / Number / OfficialRegNo/ AnimalGuid / Name / Type / Sex / Breed / BirthDate / Comment / CommentDate / ExitDate / Modified / PedigreeInfo / CalfSize / CalfHealthStatus / CalfUsage / Group / TransponderID / TransponderType / EarTagLeft / EarTagRight / BirthWeight / IsTwin / BirthEvent / ToBeCulled / LatestHistoryIndex / OptimisticLockField / GCRecord / ObjectType / ManualRationControl / CurrentFeedTable / ConsumptionRate / ActivitySetting / BullID / HairColor / ExitType / MilkConfig / Imported / Exported / DrinkData / MilkingTestAnimal

DailyMilk (v5.1)
	OID / TotalYield / Duration / SevenDayAverageYield

HistoryAnimal (v5.1)
OID / Number / OffRegNumber / Name / LastGroup / Gender / Breed / HairColor / BirthDate / LactationNumber / FatherORN / MotherORN / TBCDate / ExitDate / ExitReason / EntryEventDate / ExitType / CullDecisionDate

HistoryAnimalLactationInfo (v5.1)
OID / HistoryTotalYield / Animal / LactationNumber / StartDate / FirstHeatDay / BullGroupEntryDay / BullGroupExitDay / HeatCount / InsemCount / PregnantDays / OpenDays / DriedDay / BuildUpDay / IsLactationAborted / EndDay / TotalYield / MatureEquivalent / MilkIncome / DaysToPeak / PeakYield / ConcConsumed / RoughageConsumed / TotalConsumed / ConsumedDM / ConsumedTMR / FeedCost / AvgFat / AvgProtein / AvgCellCount  / CalvingEase / Calf1 / Calf2 / Calf3 / Calf4 / Calf6

HistoryAnimalDailyData (v5.1)
OID / DayDate / Animal / Group / LactationNumber / ReproStatus / DIM / DSLC  / DailyYield / Last7DayAvg / RelativeYield / MilkingDurationInSec / Milkings / MilkIncome / ConcConsumed / RoughageConsumed / TotalConsumed / TMRConsumed / PercConsumed / DMConsumed / Feedings / Feedcost / Kickoffs / Incompletes / AvgConductivity / AvgBlood / AcgCellCount / AvgFat / AvgProtein / AvgBCS / AvgWeight / AvgRectaltemp 

HistoryAnimalTreatment (v5.1)
OID / Animal / Group / LactationNumber / TreatStartDate / DurationInDays / TreatmentName / TreatmentCost / DivertedMilk / MilkCost / DrugInfo

SessionMilkYield (v5.1)
SessionNo / TotalYield /  Destination /  User / ExpectedYield / ObjectGuid / BeginTime / BasicAnimal / AnimalDaily / EndTime / MilkingDevice / PreviousEndTime / AvgConductivity / MaxConductivity / AverageConductivity7Days / RelativeConductivity / AverageBlood / MaxBlood / ModifiedSource / SampleTube / SampleTubeRack / SampleTubePosition / ObjectType / OID

VoluntarySessionMilkYield (v5.1)
OID / ExpectedRateLF / ExpectedRateRF / ExpectedRateLR / ExpectedRateRR/ 	CarryoverLF / CarryoverRF / CarryoverLR / CarryoverRR / QuarterLFYield / QuarterRFYield / QuarterLRYield / QuarterRRYield / MilkType / Kickoff / Incomplete / NotMilkedTeats / ConductivityLF / ConductivityRF / ConductivityLR / ConductivityRR / BloodLF / BloodRF / BloodLR / BloodRR / PeakFlowLF/ PeakFlowRF / PeakFlowLR / PeakFlowRR / MeanFlowLF / MeanFlowRF / MeanFlowLR / MeanFlowRR / Occ / Mdi / Performance / CurrentCombinedAmd / YieldExpectedLF / YieldExpectedRF / YieldExpectedLR / YieldExpectedRR / UdderCounter / UdderCounterFlags / TeatCounterLF / TeatCounterLR / TeatCounterRF / TeatCounterRR / TeatCounterFlagsLF / TeatCounterFlagsLR / TeatCounterFlagsRF / TeatCounterFlagsRR / CleaningProgramNumber / DiversionReason / AmsSerialData / EnabledTeats / OccAverage / OccHealthClass / OccEmr / SelectiveTakeoffApplied / SelectiveAttach / SmartPulsationRatio

Detailed contents v5.2

BasicAnimal (v5.2)
OID / Number / OfficialRegNo/ AnimalGuid / Name / Type / Sex / Breed / BirthDate / Comment / CommentDate / ExitDate / ExitType / Modified / PedigreeInfo / CalfSize / CalfHealthStatus / CalfUsage / Group / TransponderID / TransponderType / EarTagLeft / EarTagRight / BirthWeight / IsTwin / BirthEvent / ToBeCulled / LatestHistoryIndex / OptimisticLockField / GCRecord / ObjectType / ConsumptionRate / DrinkData / ActivitySetting / ManualRationControl / CurrentFeedTable / BullID / MilkingTestAnimal / SystemEntryTimeStamp / HairColor / MilkConfig / Imported / Exported / WeightIncreaseDecreaseStatus

HistoryAnimal (v5.2)
OID / Number / OffRegNumber / LastGroup / Gender / Breed / BirthDate / LactationNumber / FatherORN / MotherORN / TBCDate / ExitDate / ExitReason / EntryEventDate / ExitType / CullDecisionDate / ReferenceId / Name / HairColor

HistoryAnimalLactationInfo (v5.2)
OID / HistoryTotalYield / Animal / LactationNumber / StartDate / FirstHeatDay / BullGroupEntryDay / BullGroupExitDay / HeatCount / InsemCount / PregnantDays / OpenDays / DriedDay / BuildUpDay / IsLactationAborted / EndDay / TotalYield / MatureEquivalent / MilkIncome / DaysToPeak / PeakYield / ConcConsumed / RoughageConsumed / TotalConsumed / ConsumedDM / ConsumedTMR / FeedCost / AvgFat / AvgProtein / AvgCellCount  / CalvingEase / Calf1 / Calf2 / Calf3 / Calf4 / Calf6

HistoryAnimalDailyData (v5.2)
OID / DayDate / Animal / Group / LactationNumber / ReproStatus / DIM /  DailyYield / Last7DayAvg / RelativeYield / MilkingDurationInSec / Milkings / MilkIncome / ConcConsumed / RoughageConsumed / TotalConsumed / TMRConsumed / PercConsumed / DMConsumed / Feedings / Feedcost / Kickoffs / Incompletes / AvgConductivity / AvgBlood / AcgCellCount / AvgFat / AvgProtein / AvgBCS / AvgWeight / AvgRectaltemp / DLSC

HistoryAnimalTreatment (v5.2)
OID / Animal / Group / LactationNumber / TreatStartDate / DurationInDays / DiagnosisName / TreatmentName / TreatmentCost / DivertedMilk / MilkCost / DrugInfo

SessionMilkYield (v5.2)
OID / ObjectGuid / BeginTime / BasicAnimal / AnimalDaily / EndTime / MilkingDevice / PreviousEndTime / SessionNo / TotalYield / Destination / AvgConductivity / MaxConductivity / AverageConductivity7Days / RelativeConductivity / AverageBlood / MaxBlood / ModifiedSource / User / ExpectedYield / SampleTube / SampleTubeRack / SampleTubePosition / ObjectType / SystemEntryTimeStamp

VoluntarySessionMilkYield (v5.2)
OID / ExpectedRateLF / ExpectedRateRF / ExpectedRateLR / ExpectedRateRR/ 	CarryoverLF / CarryoverRF / CarryoverLR / CarryoverRR / QuarterLFYield / QuarterRFYield	QuarterLRYield / QuarterRRYield / MilkType / Kickoff / Incomplete / NotMilkedTeats / ConductivityLF / ConductivityRF / ConductivityLR / ConductivityRR / BloodLF / BloodRF / BloodLR / BloodRR / PeakFlowLF/ PeakFlowRF / PeakFlowLR / PeakFlowRR / MeanFlowLF / MeanFlowRF / MeanFlowLR / MeanFlowRR / Occ / OccAverage / Mdi / Performance / CurrentCombinedAmd / YieldExpectedLF / YieldExpectedRF / YieldExpectedLR / YieldExpectedRR / UdderCounter / UdderCounterFlags / TeatCounterLF / TeatCounterLR / TeatCounterRF / TeatCounterRR / TeatCounterFlagsLF / TeatCounterFlagsLR / TeatCounterFlagsRF / TeatCounterFlagsRR / CleaningProgramNumber / DiversionReason / AmsSerialData / OccHealthClass / OccEmr / SelectiveTakeoffApplied / AlternativeAttach / SmartPulsationRatio / EnabledTeats


Detailed contents v5.3

BasicAnimal (v5.3)
OID / Number / OfficialRegNo/ AnimalGuid / Name / Type / Sex / Breed / BirthDate / Comment / CommentDate / ExitDate / ExitType / Modified / PedigreeInfo / CalfSize / CalfHealthStatus / CalfUsage / Group / TransponderID / TransponderType / EarTagLeft / EarTagRight / BirthWeight / IsTwin / BirthEvent / ToBeCulled / LatestHistoryIndex / OptimisticLockField / GCRecord / ObjectType / ConsumptionRate / DrinkData / ActivitySetting / ManualRationControl / CurrentFeedTable / BullID / MilkingTestAnimal / SystemEntryTimeStamp / HairColor / MilkConfig / Imported / Exported / WeightIncreaseDecreaseStatus

HistoryAnimal (v5.3)
OID / Number / OffRegNumber / LastGroup / Gender / Breed / BirthDate / LactationNumber / FatherORN / MotherORN / TBCDate / ExitDate / ExitReason / EntryEventDate / ExitType / CullDecisionDate / ReferenceId / Name / HairColor

HistoryAnimalDailyData (v5.3)
OID / DayDate / Animal / Group / LactationNumber / ReproStatus / DIM /  DailyYield / Last7DayAvg / RelativeYield / MilkingDurationInSec / Milkings / MilkIncome / ConcConsumed / RoughageConsumed / TotalConsumed / TMRConsumed / PercConsumed / DMConsumed / Feedings / Feedcost / Kickoffs / Incompletes / AvgConductivity / AvgBlood / AcgCellCount / AvgFat / AvgProtein / AvgBCS / AvgWeight / AvgRectaltemp / DLSC

HistoryAnimalLactationInfo (v5.3)
OID / HistoryTotalYield / Animal / LactationNumber / StartDate / FirstHeatDay / BullGroupEntryDay / BullGroupExitDay / HeatCount / InsemCount / PregnantDays / OpenDays / DriedDay / BuildUpDay / IsLactationAborted / EndDay / TotalYield / MatureEquivalent / MilkIncome / DaysToPeak / PeakYield / ConcConsumed / RoughageConsumed / TotalConsumed / ConsumedDM / ConsumedTMR / FeedCost / AvgFat / AvgProtein / AvgCellCount  / CalvingEase / Calf1 / Calf2 / Calf3 / Calf4 / Calf6

HistoryAnimalTreatment (v5.3)
OID / Animal / Group / LactationNumber / TreatStartDate / DurationInDays / DiagnosisName / TreatmentName / TreatmentCost / DivertedMilk / MilkCost / DrugInfo

SessionMilkYield (v5.3)
OID / ObjectGuid / BeginTime / BasicAnimal / AnimalDaily / EndTime / MilkingDevice / PreviousEndTime / SessionNo / TotalYield / Destination / AvgConductivity / MaxConductivity / AverageConductivity7Days / RelativeConductivity / AverageBlood / MaxBlood / ModifiedSource / User / ExpectedYield / SampleTube / SampleTubeRack / SampleTubePosition / ObjectType / SystemEntryTimeStamp

VoluntarySessionMilkYield (v5.3)
OID / ExpectedRateLF / ExpectedRateRF / ExpectedRateLR / ExpectedRateRR/ 	CarryoverLF / CarryoverRF / CarryoverLR / CarryoverRR / QuarterLFYield / QuarterRFYield	QuarterLRYield / QuarterRRYield / MilkType / Kickoff / Incomplete / NotMilkedTeats / ConductivityLF / ConductivityRF / ConductivityLR / ConductivityRR / BloodLF / BloodRF / BloodLR / BloodRR / PeakFlowLF/ PeakFlowRF / PeakFlowLR / PeakFlowRR / MeanFlowLF / MeanFlowRF / MeanFlowLR / MeanFlowRR / Occ / OccAverage / Mdi / Performance / CurrentCombinedAmd / YieldExpectedLF / YieldExpectedRF / YieldExpectedLR / YieldExpectedRR / UdderCounter / UdderCounterFlags / TeatCounterLF / TeatCounterLR / TeatCounterRF / TeatCounterRR / TeatCounterFlagsLF / TeatCounterFlagsLR / TeatCounterFlagsRF / TeatCounterFlagsRR / CleaningProgramNumber / DiversionReason / AmsSerialData / OccHealthClass / OccEmr / SelectiveTakeoffApplied / AlternativeAttach / SmartPulsationRatio / EnabledTeats / TeatsFailedCleaning
 
Data tables to be constructed

1)	‘Per milking’ data table
-	v3.7	BasicAnimal, AnimalHistoricalData, SessionMilkYield, 
		VoluntarySessionMilkYield, AnimalLactationSummary
-	v4.x, v5.x  	BasicAnimal, SessionMilkYield, VoluntarySessionMilkYield, 
HistoryAnimalLactationInfo
2)	Daily data table
-	v3.7	BasicAnimal, AnimalHistoricalData, DailyMilk, AnimalLactationSummary
-	v4.x, v5.x  	HistoryAnimal, HistoryAnimalDailyData, HistoryAnimalLactationInfo

DLV_milkdata_v37,   DLV_milkdata_v4x
OUTPUT = OUT
•	BA 		= Basic Animal ID
•	Number 	= Farmer cow number
•	OfficialRegNo 	= Official registration number of the cow (UK…)
•	Name 		= Farmer cow number
•	BDate 		= Birth date
•	Calving 	= Calving date
•	Lac 		= Lactation number 
•	BeginTime	= Start time of the milking
•	EndTime	= End Time of the milking
•	PEndTime 	= Previous End Time of the milking
•	DIM 		= Days in milk
•	SesNo		= Session number of the day
•	TMY 		= Total daily milk yield
•	Dest		= Destination
•	NotMilkedTeats= Coded for the teats not milked
•	Incomplete	= Coded for the teats milked incompletely
•	Kickoff		= Coded for the teats kicked off during the milking
•	MYXX	(4)	= Milk yield per quarter
•	ECXX	(4)	= Electrical conductivity per quarter
•	BloodXX (4)	= Blood detected in each quarter (RGB sensor)
•	PFXX (4) 	= Peak flow per quarter
•	MFXX (4) 	= Mean flow per quarter
•	MDI		= Mastitis detection index



Variable	Origin_v3.7	Origin_v4.x/5.1	Comments
OID	BA	BA	
Number	BA	BA	
OfficialRegNo	BA	BA	
Name	BA	BA	
BirthDate	BA	BA	
OID	AHD	HALI	
DateAndTime	AHD		BeginTime of milking / daily
BeginTime		SMY	
BasicAnimal	AHD	SMY	
DIM	AHD		V4.x and v5.x: to be calculated using ALS/HALI
LactationNumber	AHD	ALS/HALI	
StartDate		ALS/HALI	This the LACTATION Start = Calving
EndTime	AHD	SMY	
PreviousEndTime	AHD	SMY	To calculate MI
OID	SMY	SMY	
SessionNo	SMY	SMY	
TotalYield	SMY	SMY	
Destination	SMY	SMY	
OID	VSMY	VSMY	
QuarterLFYield	VSMY	VSMY	
QuarterRFYield	VSMY	VSMY	
QuarterLRYield	VSMY	VSMY	
QuarterRRYield	VSMY	VSMY	
Kickoff	VSMY	VSMY	
Incomplete	VSMY	VSMY	
ConductivityLF	VSMY	VSMY	
ConductivityRF	VSMY	VSMY	
ConductivityLR	VSMY	VSMY	
ConductivityRR	VSMY	VSMY	
BloodLF	VSMY	VSMY	
BloodRF	VSMY	VSMY	
BloodLR	VSMY	VSMY	
BloodRR	VSMY	VSMY	
PeakFlowLF	VSMY	VSMY	
PeakFlowRF	VSMY	VSMY	
PeakFlowLR	VSMY	VSMY	
PeakFlowRR	VSMY	VSMY	
MeanFlowLF	VSMY	VSMY	
MeanFlowRF	VSMY	VSMY	
MeanFlowLR	VSMY	VSMY	
MeanFlowRR	VSMY	VSMY	
Occ	VSMY	VSMY	
Mdi	VSMY	VSMY	



DLV_dailydata_v37 
OUTPUT = OUT
•	BA 		= Basic Animal ID
•	Number 	= Farmer cow number
•	OfficialRegNo 	= Official registration number of the cow (UK…)
•	Name 		= Farmer cow number
•	Lac 		= Lactation number 
•	BDate 		= Birth date
•	Calving 	= Calving date
•	Date		= Date
•	DIM 		= Days in milk
•	TDMY 		= Total daily milk yield
•	Dur 		= Duration of the milkings (in seconds)
•	A7DY 		= Average 7 day daily yield

DLV_dailydata_v4x  and DLV_dailydata_v5x
OUTPUT = OUT
•	BA 		= Basic Animal ID
•	Number 	= Farmer cow number
•	OfficialRegNo 	= Official registration number of the cow (UK…)
•	BDate 		= Birth date
•	Lac 		= Lactation number 
•	Calving 	= Calving date
•	Date		= Date
•	DIM 		= Days in milk
•	TDMY 		= Total daily milk yield
•	A7DY 		= Average 7 day daily yield
•	Dur 		= Duration of the milkings (in seconds)
•	Milkings	= Number of milkings
•	Kickoffs	= Number of Kickoffs
•	Incompletes 	= Number of incompletes



Variable	Origin_v3.7	Origin_v4.x	Comments
OID	BA	BA	
Number	BA	BA	
OfficialRegNo	BA	BA	
Name	BA	BA	
BirthDate	BA	BA	
OID	ALS	HALI	
Animal	ALS	HALI	
LactationNumber	ALS	HALI	
StartDate	ALS	HALI	This is the calving date
OID	AHD		
Animal		HADD	
LactationNumber	AHD	HADD	
DIM	AHD	HADD	
OID	DM	HADD	
DailyYield	DM	HADD	
Last7DayAvg	DM	HADD	
Duration	DM		
MilkingDurationInSec		HADD	
Milkings		HADD	
Kickoffs		HADD	
Incompletes		HADD	


