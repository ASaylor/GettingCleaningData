# Read me - run_analysis.R
### Getting and Cleaning Data Course

## Overview/Project Summary
This project takes data obtained from individuals in the 19-48 age range performing six activities while wearing a Samsung Galaxy S II smartphone and transforms the data by assembling a complete data set and summarizing it by the average across each subject and each activity.

## Original Data Source Citation
[1] Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012

Location of download: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

## Description of Code Functionality

### Reads in all relevant files using read.table
* This assumes the dataset at the above URL listed under "Location of download" has been unzipped to your working directory, so that the folder entitled "UCI HAR Dataset" resides there.
* Each relevant file to the assignment is read into R using read.table and given a separate, descriptive file handle

### Assembles data frames for test and training sets
* The training and test sets are each assembled by using the column bind function to pull together subject data, activity data, and measurement value data for each set. They are each converted to data frames.

### Merges test and training sets into one table
* The fully assembled test and training sets are combined together using the row bind function. Each set contains the same columns in the same order, so row bind is the most appropriate function to use to pull the data together. The actual "merge" function would not produce appropriate results, as there are no common subjects between the training and test sets (since the purpose of training/test sets is to split the data in this manner.)

### Labels data with descriptive names that can be easily processed
* To prepare for extraction of only mean and standard deviation-related measurements, the data is descriptively labeled.
* The subject and activity columns (1 and 2) are labeled appropriately
* The activity type names are brought in to correspond with the numbers used to label them by using the sqldf package to join the activity labels file to the merged data, based on the common field of the numeric activity value (labeled "activity" in the merged data, and "V1" in the activity labels file)
* The feature names are extracted from the features file and applied to columns 3-563, where this data resides in its original order. (Columns 1 and 2 are subject and activity).
* Column 564 is a duplicated activity number column which will ultimately be de-duplicated, but to prevent confusion it has been labeled as "activity-1".
* Column 565 with the activity description is labeled as "actname"

### Extracts only measures of mean or standard deviation by labels
* The grep function is used to find column names containing mean or std in their names, in any combination of upper/lower case.
* The subject, activity, and columns identified above are combined using the column bind function and converted to a data frame.

### Processes column names to make them more readable
* Punctuation characters that appear in the column names that make them longer and less readable such as () and - are removed using the gsub function.
* The details on how to remove punctuation characters were sourced from the following page: https://stat.ethz.ch/R-manual/R-devel/library/base/html/regex.html

### Creates a summary table of averages for each subject and activity combination 
* Uses only those variables that are true mean or standard deviation measures (excludes angle and mean frequency measures)
* The sqldf package is used to select the subject, activity name, and average of the appropriate columns as mentioned above.
* The GROUP BY command in SQL is used to slice the data into the correct groupings of subject/activity combinations.

### Writes a table to a text file with the summarized data set
* The result of the commands above is converted into a data frame
* The write table command is used to produce a text file (with the row names not present as requested in the assignment), which is the averages.txt file.

