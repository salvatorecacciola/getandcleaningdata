

#Load library "dplyr" that will be used for data frame manipulation

library(dplyr)

#Download the zip file from the internet and unzip it.
#Note that the parameter method=CURL below might be necessary, 
#depending on your operating system 

if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/activity.zip"
              #,method=CURL 
              )
unzip("data/activity.zip", exdir="./data")
setwd("./data/UCI HAR Dataset")


#Read all relevant txt files

Train<-read.table("./train/X_train.txt")
Test<-read.table("./test/X_test.txt")
SubjectTrain<-read.table("./train/subject_train.txt")
SubjectTest<-read.table("./test/subject_test.txt")
test_activity<-read.table("./test/y_test.txt")
train_activity<-read.table("./train/y_train.txt")
activity_labels<-read.table("activity_labels.txt")
names(SubjectTest)<-"Subject"
names(SubjectTrain)<-"Subject"


#Ad columns "Subject" and "Activity_id" and "DataUse" to
#the data frames "Test" and "Train"

Test<-cbind(Test, Subject=SubjectTest)
Train<-cbind(Train, Subject=SubjectTrain )
Test<-cbind(Test, DataUse="Test")
Train<-cbind(Train, DataUse="Train")
Train<-cbind(Train, train_activity)
Test<-cbind(Test, test_activity)
names(Test)[564]="Activity_id"
names(Train)[564]="Activity_id"


#Merge the data frames test and train
AllData<-rbind(Test, Train)

#Filter the data frame created in previous step to only
#extract measurements on mean and standard deviation
features<-read.table("features.txt")
names(features)<-c("feature_id", "feature")
myfeatures<-filter(features, grepl("mean\\(\\)$|std\\(\\)$", feature))
FilteredData<-AllData[,myfeatures$feature_id]
FilteredData<-AllData[,c(myfeatures$feature_id,562:564)]

#Add column activity_labels to the data frame, to have
#descriptive names of activities
FilteredData2<- merge(FilteredData, activity_labels, by.x="Activity_id",
                      by.y="V1")


#Give descriptive names to all measures in the database
names(FilteredData2)<-c("Activity_ID",as.character(myfeatures$feature), 
                        "Subject","DataUse","Activity")
names(FilteredData2)[2:19]<-c(
    "MeanMagnitudeBodyAccelertion",
    "StandardDeviationMagnitudeBodyAcceleration",
    "MeanMagnitudeGravityAcceleration",
    "StandardDeviationMagnitudeGravityAcceleration",
    "MeanMagnitudeBodyAccelerationJerk",
    "StandardDeviationMagnitudeBodyAccelerationJerk",
    "MeanMagnitudeBodyGyro",
    "StandardDeviationMagnitudeBodyGiro",
    "MeanMagnitudeBodyGyroJerk",
    "StandardDeviationMagnitudeBodyGiroJerk",
    "MeanFFTMagnitudeBodyAccelertion",
    "StandardDeviationFFTMagnitudeBodyAcceleration",
    "MeanFFTMagnitudeBodyAccelertionJerk",
    "StandardDeviationFFTMagnitudeBodyAccelerationJerk",
    "MeanFFTMagnitudeBodyGyro",
    "StandardDeviationFFTMagnitudeBodyGyro",
    "MeanFFTMagnitudeBodyGyroJerk",
    "StandardDeviationFFTMagnitudeBodyGyroJerk"
    )

#Remove columns "DataUse" and "Acvtivity_ID", which we don't need
FilteredData2<-FilteredData2[,!(names(FilteredData2)=="DataUse")]
FilteredData2<-FilteredData2[,!(names(FilteredData2)=="Activity_ID")]

#Create a second, independent tidy data set 
#with the average of each variable for each activity and each subject.
TidyData<-FilteredData2%>%
    group_by(Activity, Subject)%>%
    summarise_each(funs(mean))%>%
    data.frame()


#Give descriptive names to the variables
#Tidy Data is now a tidy dataset
names(TidyData)[3:20]<-lapply(names(TidyData)[3:20],
    function(x){paste0("Average",x)})

#Create a txt file on your machine containing the tidy dataset
write.table(TidyData, file="Tidydata.txt", row.names = FALSE)
