library(tidyverse)
library(dplyr)
library(reshape2)

#download data file
filename<- "UCI HAR Dataset"
if (!file.exists( filename )){
  download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", "datafile.zip")
  unzip("datafile.zip")
}

#Load activity and features
activity_labels<- read.table("UCI HAR Dataset/activity_labels.txt")
features<- read.table("UCI HAR Dataset/features.txt")

#extract only means and std
featuresWanted <- grep(".*mean.*|.*std.*", features[,2])
featuresWanted.names <- features[featuresWanted,2]
featuresWanted.names = gsub('-mean', 'Mean', featuresWanted.names)
featuresWanted.names = gsub('-std', 'Std', featuresWanted.names)
featuresWanted.names <- gsub('[-()]', '', featuresWanted.names)

#load training subject
train_sudject<- read.table("UCI HAR Dataset/train/subject_train.txt") %>%
  dplyr::rename(subject=V1)

#load training activities & convert the numbers to labels from activity label
train_activities<- read.table("UCI HAR Dataset/train/Y_train.txt") %>%
  dplyr::left_join(activity_labels, by="V1") %>%
  dplyr::select(V2) %>%
  dplyr::rename(activity = V2)

#load training data, extracting only the desired variables
train<- read.table("UCI HAR Dataset/train/X_train.txt") [featuresWanted]
names(train) <- featuresWanted.names
train<- cbind(train_sudject, train_activities, train)
#head(train)

#load test subject
test_sudject<- read.table("UCI HAR Dataset/test/subject_test.txt") %>%
  dplyr::rename(subject=V1)

#load test activities & convert the numbers to labels from activity label
test_activities<- read.table("UCI HAR Dataset/test/Y_test.txt") %>%
  dplyr::left_join(activity_labels, by="V1") %>%
  dplyr::select(V2) %>%
  dplyr::rename(activity = V2)

#load training data, extracting only the desired variables
test<- read.table("UCI HAR Dataset/test/X_test.txt") [featuresWanted]
names(test) <- featuresWanted.names
test<- cbind(test_sudject, test_activities, test)

#merge the two datasets
allData <- rbind(train, test)
head(allData)


#Create a tidy dataset that consists of the average (mean) value of each
#variable for each subject and activity pair.
allData.melted <- melt(allData, id = c("subject", "activity"))
head(allData.melted)

allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)
head(allData.mean)
write.table(allData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
