###Read in all original files using read.table

features <- read.table("./UCI HAR Dataset/features.txt")
training <- read.table("./UCI HAR Dataset/train/X_train.txt")
test <- read.table("./UCI HAR Dataset/test/X_test.txt")
trainingsubject <- read.table("./UCI HAR Dataset/train/subject_train.txt")
testsubject <- read.table("./UCI HAR Dataset/test/subject_test.txt")
trainingactivity <- read.table("./UCI HAR Dataset/train/y_train.txt")
testactivity <- read.table("./UCI HAR Dataset/test/y_test.txt")
activitylabels <- read.table("./UCI HAR Dataset/activity_labels.txt")

###Assemble data from raw files

#Create full test set
testall <- cbind(testsubject, testactivity, test)
#Create full training set
trainingall <- cbind(trainingsubject, trainingactivity, training)

#Convert to data frame
testall <- as.data.frame(testall)
trainingall <- as.data.frame(trainingall)

#Merge training and test set
mergedData <- rbind(testall,trainingall)

##Begin assembling required naming conventions for successful subset to extract only mean
##and standard deviation measurements

#Label subject and activity columns
names(mergedData)[1] <- "subject"
names(mergedData)[2] <- "activity"

#Assure unique column names
names(mergedData) <- make.unique(names(mergedData), sep = "-")

#Label activity types
require(sqldf)
mergedData2 <- sqldf("SELECT * FROM mergedData JOIN activitylabels ON 
                     mergedData.activity = activitylabels.V1")

#Isolate column names from features file
featurenames <- features$V2
featurenames <- as.character(featurenames)

#Apply column names to merged data set
names(mergedData2)[3:563] <- featurenames
names(mergedData2)[564] <- "activity-1"
names(mergedData2)[565] <- "actname"

###Extract only mean and standard deviation measurements
#Find columns whose names contain mean or std
meanstd <- grep("mean|std", colnames(mergedData2), ignore.case = TRUE)
#Include only subject, activity, and mean or std measurements
subset <- cbind(mergedData2[1], mergedData2[565], mergedData2[meanstd])
#Convert to data frame
subset <- as.data.frame(subset)

###Set names in a way that they can be easily processed by removing punctuation characters
##Source: https://stat.ethz.ch/R-manual/R-devel/library/base/html/regex.html
names(subset) <- gsub("[[:punct:]]", "", names(subset))

##Create averages subject/activity combination, excluding meanFreq
##and angle measures as these are not true measures of st dev or mean
require(sqldf)
averages <- sqldf("SELECT subject, actname, 
                  AVG(tBodyAccmeanX),
                  AVG(tBodyAccmeanY),
                  AVG(tBodyAccmeanZ),
                  AVG(tBodyAccstdX),
                  AVG(tBodyAccstdY),
                  AVG(tBodyAccstdZ),
                  AVG(tGravityAccmeanX),
                  AVG(tGravityAccmeanY),
                  AVG(tGravityAccmeanZ),
                  AVG(tGravityAccstdX),
                  AVG(tGravityAccstdY),
                  AVG(tGravityAccstdZ),
                  AVG(tBodyAccJerkmeanX),
                  AVG(tBodyAccJerkmeanY),
                  AVG(tBodyAccJerkmeanZ),
                  AVG(tBodyAccJerkstdX),
                  AVG(tBodyAccJerkstdY),
                  AVG(tBodyAccJerkstdZ),
                  AVG(tBodyGyromeanX),
                  AVG(tBodyGyromeanY),
                  AVG(tBodyGyromeanZ),
                  AVG(tBodyGyrostdX),
                  AVG(tBodyGyrostdY),
                  AVG(tBodyGyrostdZ),
                  AVG(tBodyGyroJerkmeanX),
                  AVG(tBodyGyroJerkmeanY),
                  AVG(tBodyGyroJerkmeanZ),
                  AVG(tBodyGyroJerkstdX),
                  AVG(tBodyGyroJerkstdY),
                  AVG(tBodyGyroJerkstdZ),
                  AVG(tBodyAccMagmean),
                  AVG(tBodyAccMagstd),
                  AVG(tGravityAccMagmean),
                  AVG(tGravityAccMagstd),
                  AVG(tBodyAccJerkMagmean),
                  AVG(tBodyAccJerkMagstd),
                  AVG(tBodyGyroMagmean),
                  AVG(tBodyGyroMagstd),
                  AVG(tBodyGyroJerkMagmean),
                  AVG(tBodyGyroJerkMagstd),
                  AVG(fBodyAccmeanX),
                  AVG(fBodyAccmeanY),
                  AVG(fBodyAccmeanZ),
                  AVG(fBodyAccstdX),
                  AVG(fBodyAccstdY),
                  AVG(fBodyAccstdZ),
                  AVG(fBodyAccJerkmeanX),
                  AVG(fBodyAccJerkmeanY),
                  AVG(fBodyAccJerkmeanZ),
                  AVG(fBodyAccJerkstdX),
                  AVG(fBodyAccJerkstdY),
                  AVG(fBodyAccJerkstdZ),
                  AVG(fBodyGyromeanX),
                  AVG(fBodyGyromeanY),
                  AVG(fBodyGyromeanZ),
                  AVG(fBodyGyrostdX),
                  AVG(fBodyGyrostdY),
                  AVG(fBodyGyrostdZ),
                  AVG(fBodyAccMagmean),
                  AVG(fBodyAccMagstd),
                  AVG(fBodyBodyAccJerkMagmean),
                  AVG(fBodyBodyAccJerkMagstd),
                  AVG(fBodyBodyGyroMagmean),
                  AVG(fBodyBodyGyroMagstd),
                  AVG(fBodyBodyGyroJerkMagmean),
                  AVG(fBodyBodyGyroJerkMagstd)
FROM subset GROUP BY subject, actname")

##Create independent tidy data set using write.table
averages <- as.data.frame(averages)
write.table(averages, file="averages.txt", row.names=FALSE)
