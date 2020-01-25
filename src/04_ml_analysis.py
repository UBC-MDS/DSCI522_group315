# author: Group 315 (Sarah Weber)
# date: 2020-01-22

"""Conducts feature selection and then data analysis for the UFC data.

Usage: src/04_ml_analysis.py --input_path_Xtrain=<input_path_Xtrain> --input_path_ytrain=<input_path_ytrainh> --input_path_Xtest=<input_path_Xtest> --input_path_ytest=<input_path_ytest> --out_path=<out_path> --out_path_csv=<out_path_csv>

Options:

--input_path_Xtrain=<input_path_Xtrain>          The path of X_train.csv
--input_path_ytrain=<input_path_ytrainh>         The path of y_train.csv
--input_path_Xtest=<input_path_Xtest>            The path of X_test.csv
--input_path_yttest=<input_path_ytest>           The path of y_test.csv
--out_type=<out_type>                            Type of file to write locally (script supports either feather or csv)
--out_path=<output_path>                         The path of the directory to save output of analysis
--out_path_csv=<output_path_csv>                 The path of the directory to save output to for csv files


Example: python src/04_ml_analysis.py --input_path_Xtrain=data/02_preprocessed/X_train.csv --input_path_ytrain=data/02_preprocessed/y_train.csv 
--input_path_Xtest=data/02_preprocessed/X_test.csv --input_path_ytest=data/02_preprocessed/y_test.csv --out_path=analysis/figures/ --out_path_csv=analysis/
"""

from docopt import docopt
import requests
import os
import pandas as pd
import numpy as np
from sklearn.model_selection import GridSearchCV
from sklearn.linear_model import LogisticRegression
from sklearn.feature_selection import RFE, RFECV
import warnings
warnings.simplefilter(action='ignore', category=Warning)
import altair as alt
from sklearn.metrics import classification_report
from sklearn.metrics import plot_confusion_matrix
import matplotlib.pyplot as plt

opt = docopt(__doc__)

def main(input_path_Xtrain, input_path_ytrain, input_path_Xtest, input_path_ytest, out_path, out_path_csv):
  """
  Takes in input paths to data and the output folders and conducts a RFE CV search
  to find the best features for a logisitic regression model.

  Parameters
  ----------
  input_path_Xtrain: str
      The directory path and file of X_train.csv
  input_path_ytrain: str
      The directory path and file of y_train.csv
  input_path_Xtest: str
      The directory path and file of X_test.csv
  input_path_yttest: str
      The directory path and file of y_test.csv
  out_type: str
      Type of file to write locally (script supports either feather or csv)
  out_path: str
      The path of the directory to save output of the analysis
  out_path_csv: str
        The path of the directory to save output to for csv files
            
  Returns
  -------
  none
        
  Examples
  -------
  >>> python src/04_ml_analysis.py --input_path_Xtrain=data/02_preprocessed/X_train.csv 
        --input_path_ytrain=data/02_preprocessed/y_train.csv --input_path_Xtest=data/02_preprocessed/X_test.csv 
        --input_path_ytest=data/02_preprocessed/y_test.csv --out_path=analysis/figures/ --out_path_csv=analysis/
  """
  #////////////////////////////////////
  # DATA IMPORTING
  #////////////////////////////////////
  # Import data from the data folder based on the output of 02_preprocess_data.R
  X_train = pd.read_csv(input_path_Xtrain)
  y_train = pd.read_csv(input_path_ytrain)
  X_test = pd.read_csv(input_path_Xtest)
  y_test = pd.read_csv(input_path_ytest)
  
  #////////////////////////////////////
  # FEATURE SELECTION
  # Conduct a grid search to find x number of important features
  #////////////////////////////////////
  lr = LogisticRegression(solver='liblinear')
  rfe_cv = RFECV(estimator = lr, cv=10)
  rfe_cv.fit(X_train, y_train)
  rfe_cv.support_

  #////////////////////////////////////
  # MODEL BUILDING
  #////////////////////////////////////
  # set up models for comparison on regular data and selected features
  lr_normal = LogisticRegression(solver='liblinear')
  lr_select = LogisticRegression(solver='liblinear')
  
  # Subset selected features for the train and test data
  X_train_sel = X_train.loc[:, rfe_cv.support_]
  X_test_sel = X_test.loc[:, rfe_cv.support_]

  # Fit to a Linear Regression model 
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
  
  #////////////////////////////////////
  # PLOTTING THE NUMBER OF FEATURES
  # Create a plot comparing the training error to test error for a given number of features.
  #////////////////////////////////////
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
  
  # Confusion Matrix on the X test values
  disp = plot_confusion_matrix(lr_select, X_test_sel, y_test,
                             display_labels=['Blue wins', 'Red Wins', 'Blue Wins', 'Red Wins'],
                             cmap=plt.cm.Blues, 
                             values_format = 'd')
  disp.ax_.set_title('Confusion Matrix for Predicted Winner')
  
  #////////////////////////////////////
  # PRINT FILES
  # Files Outputting from analysis
  #////////////////////////////////////
  plt.savefig(out_path + "confusion_matrix.png")
  plot.save(out_path + "error.png", scale_factor=20)
  weight_df.to_csv(out_path_csv + "weights.csv", index = False)
  results.to_csv(out_path_csv + "results.csv", index = False)

if __name__ == "__main__":
  main(opt["--input_path_Xtrain"], opt["--input_path_ytrain"], opt["--input_path_Xtest"], opt["--input_path_ytest"],  opt["--out_path"], opt["--out_path_csv"])
