
# UFC Judge Scoring Analysis

Contributors: DSCI 522 Group 513

[Project repository](https://github.com/UBC-MDS/DSCI522_group315)

A data analysis project for DSCI 522 (Data Science workflows).

## Introduction

In this project, we are trying to identify the key predictors for win in
UFC events and examine whether these key predictors are in line with the
UFC official rules. This analysis is very significant because it may
serve as a quality control approach for the UFC judging system and also
help to improve the rules and training strategies for the judges in the
future.

The original data was obtained from Kaggle user [Rajeev
Warrier](https://www.kaggle.com/rajeevw) (Rajeev Warrier 2019). The data
has also been downloaded and uploaded to a [GitHub
repo](https://github.com/SamEdwardes/ufc-data) to avoid issues for users
who do not have Kaggle accounts. Each row in the dataset represents
statistics from an UFC event, including the performance features and
winners (Red or Blue). The data was pre-processed by only selecting the
features related to fight performance and for the each feature, the
ratio of Blue fighter versus the Red fighter was calculated. The target
was computed as whether the Blue fighter won or not.

We built a regression model using the logistic regression algorithm to
assign weights to features and used recursive feature elimination (RFE)
approach with cross validation to identify the strong predictors. Among
the selected 11 features by RFE, 7 features are related to
Striking/Grappling performance which should be considered as the top
criteria in judgment based on the UFC official rules (The ABC MMA Rules
Committee 2017). Our final logistic regression model using these
selected features performed well on validation data set with accuracy
score of 0.83. It correctly predicted 368 out of 446 test cases and
incorrectly predicted 78 cases with 40 being false positive and 38 false
negative. Our results showed that the judges generally complied to the
UFC rules and put weights on some additional factors.

## Report

The final report can be found
[here](https://github.com/UBC-MDS/DSCI522_group315/blob/master/report/report.Rmd).

## Usage

To replicate the analysis, you can clone this GitHub repository and
install the [dependencies](#dependencies). Then you can run the
following commands from the root directory of this project:

    # download data
    Rscript src/01_download_data.R --url=https://github.com/SamEdwardes/ufc-data/raw/master/raw_total_fight_data.csv --out_file=data/01_raw/raw_total_fight_data.csv
    
    # pre-process data 
    Rscript src/02_preprocess_data.R --input_path=data/01_raw/raw_total_fight_data.csv --output_path=data/02_preprocessed/ --seed_num=1993
    
    # run EDA and create EDA figures
    Rscript src/03_eda.R --X_train_path=data/02_preprocessed/X_train.csv --y_train_path=data/02_preprocessed/y_train.csv --out_dir=analysis/figures/
    
    # Optimize and test model
    python src/04_ml_analysis.py --input_path_Xtrain=data/02_preprocessed/X_train.csv --input_path_ytrain=data/02_preprocessed/y_train.csv --input_path_Xtest=data/02_preprocessed/X_test.csv --input_path_ytest=data/02_preprocessed/y_test.csv --out_path=analysis/figures/ --out_path_csv=analysis/
    
    # render final report
    Rscript -e "rmarkdown::render('report/report.Rmd', output_format = 'github_document')"

## Dependencies

  - Python 3.7.3 and Python packages:
    
      - docopt==0.6.2
      - requests==2.22.0
      - pandas==0.24.2
      - numpy==1.16.4
      - altair==3.2.0
      - matplotlib==3.1.0
      - selenium==3.141.0
      - scikit-learn=0.22.1

  - chromedriver-binary==80.0.3987.16.0
    
    Note: Users may have an issue producing altair plots. You may need
    to download the latest version of ChomeDriver. For further
    information see
    [here](https://github.com/UBC-MDS/DSCI522_group315/issues/17).

  - R version 3.6.1 and R packages:
    
      - docopt==0.6.1
      - tidyverse==1.2.1
      - janitor==1.2.0
      - GGally==1.4.0
      - kableExtra==1.1.0
      - knitr==1.27.2

## References

<div id="refs" class="references">

<div id="ref-UFC-dataset">

Rajeev Warrier. 2019. *"UFC-Fight Historical Data from 1993 to 2019"*.
<https://www.kaggle.com/rajeevw/ufcdata>.

</div>

<div id="ref-MMA-judging-criteria">

The ABC MMA Rules Committee. 2017. *"MMA Judging
Criteria/Scoring-Approved August 2, 2016"*.
<http://www.abcboxing.com/wp-content/uploads/2016/08/juding_criteriascoring_rev0816.pdf>.

</div>

</div>
