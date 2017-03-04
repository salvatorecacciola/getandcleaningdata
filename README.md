# Get and cleaning data - Final assignment

This repository contains all relevant files for the final assignment of the course "Get and cleaning data", which
is part of the John Hopkins University Data Science Specialization on Coursera.

The goal of the assignment is reading in input a number of datasets coming from wearable devices measurements and produce a tidy dataset following a list of instructions.
As requested in the assignment instructions, this repository contains 3 files:
* The file README.md explaining in detail how the analysis has been performed
* The file Codebook giving detailed description of the variables in the tidy data set
* The file run_analysis.R including the R script that produces the tidy dataset

The original data comes from an experiment that has been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, 3-axial linear acceleration and 3-axial angular velocity were captured at a constant rate of 50Hz. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data. 

The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of features was obtained by calculating variables from the time and frequency domain.

For this assignment we read in input the following datasets coming from the experiment:

* 'activity_labels.txt': Links the class labels with their activity name.
* 'train/X_train.txt': Training set.
* 'train/y_train.txt': Training labels.
* 'test/X_test.txt': Test set.
* 'test/y_test.txt': Test labels.
* 'test/subject_test.txt': IDs of subjects 
* 'train/subject_train.txt': IDs of subjects
* 'features_info.txt': Shows information about the variables used on the feature vector.
* 'features.txt': List of all features.


## Step 1: Merge the training and the test sets to create one data set.
We start by downloading the zip file online with all necessary data and we unzip it.
Note that the parameter method=CURL below might be necessary, depending on your operating system.


```library(dplyr)
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/activity.zip"
              #,method=CURL 
              )
unzip("data/activity.zip", exdir="./data")
setwd("./data/UCI HAR Dataset")
```

Then we read all the txt files that we need

```Train<-read.table("./train/X_train.txt")
Test<-read.table("./test/X_test.txt")
SubjectTrain<-read.table("./train/subject_train.txt")
SubjectTest<-read.table("./test/subject_test.txt")
test_activity<-read.table("./test/y_test.txt")
train_activity<-read.table("./train/y_train.txt")
activity_labels<-read.table("activity_labels.txt")
names(SubjectTest)<-"Subject"
names(SubjectTrain)<-"Subject"
```



We add the columns "Subject", "Activity_id" and "DataUse" to the data frames "Test" and "Train"

```
Test<-cbind(Test, Subject=SubjectTest)
Train<-cbind(Train, Subject=SubjectTrain )
Test<-cbind(Test, DataUse="Test")
Train<-cbind(Train, DataUse="Train")
Train<-cbind(Train, train_activity)
Test<-cbind(Test, test_activity)
names(Test)[564]="Activity_id"
names(Train)[564]="Activity_id"
```

We can now merge the data frames test and train toi create the data frame "AllData", so we have completed step 1.

```
AllData<-rbind(Test, Train)
```

## Step 2: Extracts only the measurements on the mean and standard deviation for each measurement

We read the file features.txt that contains information on the nature of the measurements in our dataset.

We filter the arising vector "features" to only consider measures containing mean and standard deviation and assign this to the vector "myfeatures".
We are not including means and standard deviations along a single axis X, Y, Z.

The vector "myfeatures" is used to filter the entire dataset "AllData"

```
features<-read.table("features.txt")
names(features)<-c("feature_id", "feature")
myfeatures<-filter(features, grepl("mean\\(\\)$|std\\(\\)$", feature))
FilteredData<-AllData[,myfeatures$feature_id]
FilteredData<-AllData[,c(myfeatures$feature_id,562:564)]
```

## Step 3: Use descriptive activity names to name the activities in the data set
In order to have descriptive names of the activities we add merge our data frame with the data frame activity_labels 

```
FilteredData2<- merge(FilteredData, activity_labels, by.x="Activity_id",
                      by.y="V1")
```

## Step 4: Appropriately labels the data set with descriptive variable names.    

We do this manually by renaming all the variables of our dataset one by one

```
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
```

## Step 5: From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

We start by removing the columns "DataUse" and "Acvtivity_ID"form our databse which we don't need anymore

```
FilteredData2<-FilteredData2[,!(names(FilteredData2)=="DataUse")]
FilteredData2<-FilteredData2[,!(names(FilteredData2)=="Activity_ID")]
```

Now we create a second, independent tidy data setcalled "TidyData" with the average of each variable for each activity and each subject.
We do this by using the commands "group_by" and "summarise_each" in the dplyr package

```
TidyData<-FilteredData2%>%
    group_by(Activity, Subject)%>%
    summarise_each(funs(mean))%>%
    data.frame()
```

In order to make the dataset tidy, we give descriptive names to the variables.
We achieve this by concatenating the string "Average" and the names of all measurements.

```
names(TidyData)[3:20]<-lapply(names(TidyData)[3:20],
    function(x){paste0("Average",x)})
```

The dataset "TidyData" is now tidy!
We use the command write.table to export it ot a txt file

```
write.table(TidyData, file="Tidydata.txt", row.names = FALSE)
```
