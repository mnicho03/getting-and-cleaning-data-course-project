# # 1) Merges the training and the test sets to create one data set.
# # 2) Extracts only the measurements on the mean and standard deviation for each measurement.
# # 3) Uses descriptive activity names to name the activities in the data set
# # 4) Appropriately labels the data set with descriptive variable names.
# # 5) From the data set in step 4, creates a second, independent tidy data set with the average
# #    of each variable for each activity and each subject.

#--------------------------------------------------------------------


# 1) Merges the training and the test sets to create one data set. 
# # Download the data
workingdirectory <- "S:/Documents/R/UCI HAR Dataset"
setwd(workingdirectory)
if(!file.exists("./data")){dir.create("./data")}
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
dstFile <- "./data/UCIHARDataset.zip"
download.file(fileURL, dstFile, method = "libcurl")
unzip(zipfile=dstFile,exdir="./data")
setwd("data")
# 
# # Load in tidy data packages
library(dplyr)
library(data.table)
library(tidyr)
# 
# # Read train and test data & create variables
# # Train
setwd("train")
subject_train <- read.table("subject_train.txt")
values_train <- read.table("x_train.txt")
activity_train <- read.table("y_train.txt")
# 
# # Test
setwd("../test")
subject_test <- read.table("subject_test.txt")
values_test <- read.table("x_test.txt")
activity_test <- read.table("y_test.txt")

# # import  feature variables
setwd("../")
featureData <- read.table("features.txt")


# # import and name activity label variables
activityLabels <- read.table("activity_labels.txt")
colnames(activityLabels) <- c("activity_number", "activity_name")

# 
# # Merges the training and the test sets to create one data set.

DataTable <- rbind(
  cbind(subject_train, values_train, activity_train),
  cbind(subject_test, values_test, activity_test)
)

# assign column names
# create colname variable based on feature activity names
colVar <- featureData[,2]
# set as character 
featureColNames <- as.character(colVar)
#concat subject - feature activity names - activity
colnames(DataTable) <- c("subject", featureColNames, "activity")
#--------------------------------------------------------------------

# # 2) Extracts only the measurements on the mean and standard deviation for each measurement.

# determine which columns contain mean / std information
MeanSTDColumns <- grepl("subject|activity|mean|std", colnames(DataTable))

# filter based on those columns
DataTable <- DataTable[, MeanSTDColumns]

#--------------------------------------------------------------------

# # 3) Uses descriptive activity names to name the activities in the data set

# replace activity values with named factor levels
DataTable$activity <- factor(DataTable$activity, 
                             levels = activityLabels[, 1], labels = activityLabels[, 2])

#--------------------------------------------------------------------

# # 4) Appropriately labels the data set with descriptive variable names.

DataTableColNames <- colnames(DataTable)

# remove special characters
DataTableColNames <- gsub("[\\(\\)-]", "", DataTableColNames)

DataTableColNames<-gsub("std()", "SD", names(DataTable))
DataTableColNames<-gsub("mean()", "MEAN", names(DataTable))
DataTableColNames<-gsub("^t", "time", names(DataTable))
DataTableColNames<-gsub("^f", "frequency", names(DataTable))
DataTableColNames<-gsub("Acc", "Accelerometer", names(DataTable))
DataTableColNames<-gsub("Gyro", "Gyroscope", names(DataTable))
DataTableColNames<-gsub("Mag", "Magnitude", names(DataTable))
DataTableColNames<-gsub("BodyBody", "Body", names(DataTable))

#reset column names
colnames(DataTable) <- DataTableColNames

#--------------------------------------------------------------------

# # 5) From the data set in step 4, creates a second, independent tidy data set with the average
write.table(DataTable, "Tidy_Secondary.txt", row.name = FALSE)
