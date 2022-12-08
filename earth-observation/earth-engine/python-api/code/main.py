#!/usr/bin/env python

import os, sys, shutil, getpass
import pprint, logging, datetime
import stat

dir_data   = os.path.realpath(sys.argv[1])
dir_code   = os.path.realpath(sys.argv[2])
dir_output = os.path.realpath(sys.argv[3])

if not os.path.exists(dir_output):
    os.makedirs(dir_output)

os.chdir(dir_output)

myTime = "system time: " + datetime.datetime.now().strftime("%c")
print( "\n" + myTime + "\n" )
print("####################")

print( "\ndir_data: "   + dir_data   )
print( "\ndir_code: "   + dir_code   )
print( "\ndir_output: " + dir_output )

logging.basicConfig(filename='log.debug',level=logging.DEBUG)

##################################################
##################################################
# import seaborn (for improved graphics) if available
# import seaborn as sns

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
# import numpy   as np
# import pandas  as pd
#
# from examineData       import examineData
# from splitTrainTest    import splitTrainTest
# from trainEvaluate     import trainEvaluate
# from trainEvaluateGrid import trainEvaluateGrid
# from visualizeData     import visualizeData
#
# from PipelinePreprocessHousingData import PipelinePreprocessHousingData
#
# from sklearn.tree            import DecisionTreeRegressor
# from sklearn.linear_model    import LinearRegression
# from sklearn.model_selection import GridSearchCV
# from sklearn.ensemble        import RandomForestRegressor

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
print(              "\nHOME:" )
print( os.environ.get('HOME') )

print("\nos.path.join(os.environ.get('HOME'),'.pythonrc')")
print(   os.path.join(os.environ.get('HOME'),'.pythonrc') )

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
print(              "\nGOOGLE_APPLICATION_CREDENTIALS:" )
print( os.environ.get('GOOGLE_APPLICATION_CREDENTIALS') )

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
print( "\n### python module search paths:" )
for path in sys.path:
    print(path)

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
import ee
ee.Authenticate(auth_mode = "appdefault")
ee.Initialize()

# ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
# # load data
# housingFILE = os.path.join(dir_data,'housing.csv')
# housingDF   = pd.read_csv(housingFILE);
#
# # examine full data set
# examineData(inputDF = housingDF);
#
# ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
# # split into training and testing data sets in a stratified manner
# trainSet, testSet = splitTrainTest(inputDF = housingDF, random_state = 19)
#
# # visualize stratified training data set
# visualizeData(inputDF = trainSet);
#
# print("\ntrainSet.info()")
# print(   trainSet.info() )
#
# print("\ntrainSet.describe()")
# print(   trainSet.describe() )
#
# print("\ntype(trainSet)")
# print(   type(trainSet) )
#
# ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
# # preprocess stratified training data set
# preprocessedTrainSet = PipelinePreprocessHousingData.fit_transform(
#     X = trainSet.drop(["median_house_value"],axis=1)
#     )
#
# ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
# # linear model (this underfits the data)
# myLinearModel = LinearRegression()
# trainEvaluate(
#     trainData           = trainSet,
#     testData            = testSet,
#     trainedPreprocessor = PipelinePreprocessHousingData,
#     myModel             = myLinearModel,
#     modelName           = "Linear Model"
#     )
#
# # regression tree (this overfits the data: zero MSE)
# myRegressionTreeModel = DecisionTreeRegressor()
# trainEvaluate(
#     trainData           = trainSet,
#     testData            = testSet,
#     trainedPreprocessor = PipelinePreprocessHousingData,
#     myModel             = myRegressionTreeModel,
#     modelName           = "Regression Tree"
#     )
#
# # random forest
# myRandomForestModel = RandomForestRegressor()
# trainEvaluate(
#     trainData           = trainSet,
#     testData            = testSet,
#     trainedPreprocessor = PipelinePreprocessHousingData,
#     myModel             = myRandomForestModel,
#     modelName           = "Random Forest"
#     )
#
# ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
# # random forest with hyperparameter tuning via grid search
# newRandomForestModel = RandomForestRegressor()
#
# parameterGrid = [
#     { 'n_estimators':[3,10,30], 'max_features':[2,4,6,8]                     },
#     { 'n_estimators':[3,10],    'max_features':[2,3,4],  'bootstrap':[False] }
#     ]
#
# gridSearch = GridSearchCV(
#     estimator  = newRandomForestModel,
#     param_grid = parameterGrid,
#     scoring    = "neg_mean_squared_error",
#     cv         = 5
#     )
#
# trainEvaluateGrid(
#     trainData           = trainSet,
#     testData            = testSet,
#     trainedPreprocessor = PipelinePreprocessHousingData,
#     myModel             = gridSearch,
#     modelName           = "Random Forest, Cross Validation, Grid Search"
#     )

##################################################
##################################################
print("\n####################\n")
myTime = "system time: " + datetime.datetime.now().strftime("%c")
print( myTime + "\n" )
