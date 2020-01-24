# author: Sarah Weber
# date: 2020-01-22

"""Conducts feature selection and then data analysis for the UFC data.

Usage: src/03_ml_analysis.py --input_path_Xtrain=<input_path_Xtrain> --input_path_ytrain=<input_path_ytrainh> --input_path_Xtest=<input_path_Xtest> --input_path_ytest=<input_path_ytest> --out_type=<out_type> --out_path=<out_path>

Options:

--input_path_Xtrain=<input_path_Xtrain>           The path of X_train.csv
--input_path_ytrain=<input_path_ytrainh>           The path of y_train.csv
--input_path_Xtest=<input_path_Xtest>           The path of X_test.csv
--input_path_yttest=<input_path_ytest>           The path of y_test.csv
--out_type=<out_type>               Type of file to write locally (script supports either feather or csv)
--out_path=<output_path>         The path of the directory to save output to


Example: python src/03_ml_analysis.py --input_path_Xtrain=data/02_preprocessed/X_train.csv --input_path_ytrain=data/02_preprocessed/y_train.csv --input_path_Xtest=data/02_preprocessed/X_test.csv --input_path_ytest=data/02_preprocessed/y_test.csv --out_type=csv --out_path=data/analysis.png
"""

from docopt import docopt
import requests
import os
import pandas as pd
import numpy as np
from sklearn.model_selection import GridSearchCV
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.svm import SVR
from sklearn.datasets import make_classification
from sklearn.feature_selection import RFE, RFECV
import warnings
warnings.simplefilter(action='ignore', category=Warning)
import altair as alt
from selenium import webdriver
from sklearn.metrics import confusion_matrix
from sklearn.metrics import classification_report

#import feather

opt = docopt(__doc__)

def main(input_path_Xtrain, input_path_ytrain, input_path_Xtest, input_path_ytest, out_type, out_path):
  
  # DATA Importing
  # Import data from the data folder based on the output of 02_preprocess_data.R
  X_train = pd.read_csv(input_path_Xtrain)
  y_train = pd.read_csv(input_path_ytrain)
  X_test = pd.read_csv(input_path_Xtest)
  y_test = pd.read_csv(input_path_ytest)
  
  # run a grid search to find x number of important features
  lr = LogisticRegression(solver='liblinear')
  rfe_cv = RFECV(estimator = lr, cv=10)
  rfe_cv.fit(X_train, y_train)
  print('Number of selected features %d'%rfe_cv.n_features_)
  print('Feature mask: ', rfe_cv.support_)
  rfe_cv.support_

  # set up models for comparison on regular data and selected features
  lr_normal = LogisticRegression(solver='liblinear')
  lr_select = LogisticRegression(solver='liblinear')
  
  # subset selected features for the train and test data
  X_train_sel = X_train.loc[:, rfe_cv.support_]
  X_test_sel = X_test.loc[:, rfe_cv.support_]

  # fit to a Linear Regression model 
  lr_normal.fit(X_train, y_train)
  lr_select.fit(X_train_sel, y_train)
  
  # Create a dataframe of the selected features and weights
  feature_names = X_train_sel.columns
  weights = lr_select.coef_.flatten()
  inds = np.argsort(weights)
  weight_df = pd.DataFrame({'Features': feature_names, 'Weights': weights})
  weight_df = weight_df.reindex(weight_df.Weights.abs().sort_values(ascending=False).index)
  
  # Final results of the model on training and test data with and without the feature selection
  lr_normal.score(X_train, y_train)
  lr_normal.score(X_test, y_test)
  lr_select.score(X_train_sel, y_train)
  lr_select.score(X_test_sel, y_test)
  
  models = ["Training Error - No Feature Selection", "Training Model - Selected Features", "Testing Error - No Feature Selection", "Testing Error - Selected Features"]
  scores = [lr_normal.score(X_train, y_train), lr_select.score(X_train_sel, y_train), 
    lr_normal.score(X_test, y_test), lr_select.score(X_test_sel, y_test)]
  results = pd.DataFrame({'Model' : models, 'Score' : scores})
  
  # Create a plot comparing the training error to test error for a given number of features. 
  max_dict = {'n_features_to_select':[], 'train_error':[],'validation_error':[]}
  
  for i in range(1, len(X_train.columns)):
    
      # Prepare data for model fitting
      rfe = RFE(estimator = LogisticRegression(solver='liblinear'), n_features_to_select = i)
      rfe.fit(X_train, y_train)
      train_error = 1- rfe.score(X_train, y_train)
      valid_error = 1- rfe.score(X_test, y_test)
      max_dict['n_features_to_select'].append(i)    
      max_dict['train_error'].append(train_error) 
      max_dict['validation_error'].append(valid_error)

  # plot using altair   
  n_features_to_select_df = pd.DataFrame(max_dict)
  n_features_to_select_df = n_features_to_select_df.melt(id_vars='n_features_to_select',
                                   value_name='error') 
  plot = alt.Chart(n_features_to_select_df).mark_line().encode(
      x="n_features_to_select",
      y="error",
      color='variable'
  ).properties(
      title='Error vs Number of Features')
  
  # Classification report on the X test values
  X_pred = lr_select.predict(X_test_sel)

  print(classification_report(X_pred, y_test))
  
  print(weight_df)
  print(results)
  data = pd.DataFrame(max_dict)

  plot.save(out_path, scale_factor=20)
  
  #if out_type == "csv":
  #  try:
  #    data.to_csv(out_path, index = False)
  #  except:
  #    os.makedirs(os.path.dirname(out_path))
  #    data.to_csv(out_path, index = False)

if __name__ == "__main__":
  main(opt["--input_path_Xtrain"], opt["--input_path_ytrain"], opt["--input_path_Xtest"], opt["--input_path_ytest"], opt["--out_type"], opt["--out_path"])
