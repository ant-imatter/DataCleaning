library(dplyr)

activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("id", "activities"))
## find desired features (mean and std) and their indices
features <- read.table("UCI HAR Dataset/features.txt", colClasses = "character")[[2]]
mean_and_std <- grep("mean\\(|std\\(", features)
features_desired <- features[mean_and_std]



## below is for training data:

## find values for mean and std features
data_train <- read.table("UCI HAR Dataset/train/X_train.txt", colClasses = "numeric")
data_train <- data_train[, mean_and_std]

## combines the labels and values
colnames(data_train) <- features_desired

## adds subjects and named activities to the left of the data frame
subjects_train <- read.table("UCI HAR Dataset/train/subject_train.txt", colClasses = "numeric", col.names = "subjects")
activities_train <- read.table("UCI HAR Dataset/train/y_train.txt", colClasses = "numeric", col.names = "id")
activities_train <- inner_join(activities_train, activity_labels)[, 2, drop = FALSE]
data_train <- cbind(subjects_train, activities_train, data_train)



## do the same for test data:

## find values for mean and std features
data_test <- read.table("UCI HAR Dataset/test/X_test.txt", colClasses = "numeric")
data_test <- data_test[, mean_and_std]

## combines the labels and values
colnames(data_test) <- features_desired

## adds subjects and named activities to the left of the data frame
subjects_test <- read.table("UCI HAR Dataset/test/subject_test.txt", colClasses = "numeric", col.names = "subjects")
activities_test <- read.table("UCI HAR Dataset/test/y_test.txt", colClasses = "numeric", col.names = "id")
activities_test <- inner_join(activities_test, activity_labels)[, 2, drop = FALSE]
data_test <- cbind(subjects_test, activities_test, data_test)

## merge train and test data
data <- rbind(data_train, data_test)

## calculate variable average for each combination of subject and activity
split_data <- split(data[, c(-1,-2)], list(data$activities, data$subjects))
tidy_data <- sapply(split_data, colMeans)
tidy_data <- as.data.frame(t(tidy_data))
a <- strsplit(rownames(tidy_data), "\\.")
b <- t(as.data.frame(a))
rownames(b) <- c()
rownames(tidy_data) <- c()
colnames(b) <- c("activity", "subject")
tidy_data <- cbind(b, tidy_data)

## write to file
write.table(tidy_data, "tidy_data.txt", quote = FALSE, row.names = FALSE)

