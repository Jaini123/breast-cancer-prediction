###############################################################
#                                                             #
#            AdaBoost for Classification                      #
#                                                             #
###############################################################
#                                                             #
# Credit: Dr. Prashant Singh Rana                             #
# Email : psrana@gmail.com                                    #
# Web   : www.psrana.com                                      #
#                                                             #
###############################################################
#                                                             #
# Train and Test AdaBoost model for Classification            #
#                                                             #
# This script do the following:                               #
# 1. Load the Data                                            #
# 2. Partition the data into Train/Test set                   #
# 3. Train the Decision Tree Model                            #
# 4. Test                                                     #
# 5. Evaluate on : Accuracy.                                  # 
# 6. Finally Saving the results.                              #
#                                                             #
###############################################################


#--------------------------------------------------------------
# Step 0: Start; Getting the starting time
#--------------------------------------------------------------
cat("\nAdaBoost")
startTime = proc.time()[3]


#--------------------------------------------------------------
# Step 1: Include Library
#--------------------------------------------------------------
library(ada)
library(hmeasure)

#--------------------------------------------------------------
# Step 2: Variable Declaration
#--------------------------------------------------------------
modelName <- "adaBoost"
InputDataFileName="brestCancer.csv"
training = 50      # Defining Training Percentage; Testing = 100 - Training


#--------------------------------------------------------------
# Step 3: Data Loading
#--------------------------------------------------------------
dataset <- read.csv(InputDataFileName)      # Read the datafile
dataset <- dataset[sample(nrow(dataset)),]  # Shuffle the data row wise.


#--------------------------------------------------------------
# Step 4: Count total number of observations/rows.
#--------------------------------------------------------------
totalDataset <- nrow(dataset)


#--------------------------------------------------------------
# Step 5: Choose Target variable
#--------------------------------------------------------------
target  <- names(dataset)[10]   # i.e. Cancer


#--------------------------------------------------------------
# Step 6: Choose inputs Variables
#--------------------------------------------------------------
inputs <- setdiff(names(dataset),target)

#Feature Selection
#n=4
#inputs <-sample(inputs, n)



#--------------------------------------------------------------
# Step 7: Select Training Data Set
#--------------------------------------------------------------
trainDataset <- dataset[1:(totalDataset * training/100),c(inputs, target)]


#--------------------------------------------------------------
# Step 8: Select Testing Data Set
#--------------------------------------------------------------
testDataset <- dataset[(totalDataset * training/100):totalDataset,c(inputs, target)]


#--------------------------------------------------------------
# Step 9: Model Building (Training)
#--------------------------------------------------------------
formula <- as.formula(paste(target, "~", paste(c(inputs), collapse = "+")))
model <- ada(formula, trainDataset)

#--------------------------------------------------------------
# Step 10: Prediction (Testing)
#--------------------------------------------------------------
Predicted <- predict(model, testDataset)
PredictedProb <- predict(model, testDataset,type="prob")[,2]


#--------------------------------------------------------------
# Step 11: Extracting Actual
#--------------------------------------------------------------
Actual <- as.double(unlist(testDataset[target]))


#--------------------------------------------------------------
# Step 12: Model Evaluation
#--------------------------------------------------------------

# Step 12.1: Confusion Matrix
ConfusionMatrix <- misclassCounts(Predicted,Actual)$conf.matrix


# Step 12.2: Evaluations Parameters
# AUC, ERR, Sen, Spec, Pre,Recall, TPR, FPR, etc 
EvaluationsParameters <- round(HMeasure(Actual,PredictedProb)$metrics,3)


# Step 12.3: Accuracy
accuracy <- round(mean(Actual==Predicted) *100,2)


# Step 12.4: Total Time
totalTime = proc.time()[3] - startTime



# Step 12.5: Plotting
# ROC and ROCH Curve
png(filename=paste(modelName,"-01-ROCPlot.png",sep=''))
plotROC(HMeasure(Actual,PredictedProb),which=1)
dev.off()

# H Measure Curve
png(filename=paste(modelName,"-02-HMeasure.png",sep=''))
plotROC(HMeasure(Actual,PredictedProb),which=2)
dev.off()

# AUC Curve
png(filename=paste(modelName,"-03-AUC.png",sep=''))
plotROC(HMeasure(Actual,PredictedProb),which=3)
dev.off()

# SmoothScoreDistribution Curve
png(filename=paste(modelName,"-04-SmoothScoreDistribution.png",sep=''))
plotROC(HMeasure(Actual,PredictedProb),which=4)
dev.off()


# Step 12.5: Save evaluation resut 
EvaluationsParameters$Accuracy <- accuracy
EvaluationsParameters$TotalTime <- totalTime
rownames(EvaluationsParameters)=modelName



#--------------------------------------------------------------
# Step 13: Writing to file
#--------------------------------------------------------------

# Step 13.1: Writing to file (evaluation result)
write.csv(EvaluationsParameters, file=paste(modelName,"-Evaluation-Result.csv",sep=''), row.names=TRUE)

# Step 13.2: Writing to file (Actual and Predicted)
write.csv(data.frame(Actual,Predicted), file=paste(modelName,"-ActualPredicted-Result.csv",sep=''), row.names=FALSE)



#--------------------------------------------------------------
# Step 14: Saving the Model
#--------------------------------------------------------------
save.image(file=paste(modelName,"-Model.RData",sep=''))


cat("\nDone")
cat("\nTotal Time Taken: ", totalTime," sec")


#--------------------------------------------------------------
#                           END 
#--------------------------------------------------------------



