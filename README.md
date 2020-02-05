
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

The final report can be found:

  - Rendered markdown version of the report [here](report/report.md).
  - Rendered html version of the report
    [here](https://ubc-mds.github.io/DSCI522_group315/report/report.html).

## Usage

**1. Using Docker**

*note - the instructions in this section also depends on running this in
a unix shell (e.g., terminal or Git Bash), if you are using Windows
Command Prompt, replace /$(pwd) with PATH\_ON\_YOUR\_COMPUTER.*

1.  Install [Docker](https://www.docker.com/get-started)
2.  Download/clone this repository
3.  Use the command line to navigate to the root of this
    downloaded/cloned repo
4.  Type the
    following:

<!-- end list -->

    docker build --tag dsci-522-ufc . 

    docker run -it --rm -v $(pwd):/root/ufc dsci-522-ufc cd root/ufc make all

**2. After installing all dependencies (does not depend on Docker)**

To replicate the analysis, you can clone this GitHub repository and
install the [dependencies](#dependencies). Then you can run the
following command in the terminal from the root directory of this
project:

    make all

To remove all the anlaysis and retore the repo to a clean state, you can
run the following command in the terminal from the root directory of
this project:

    make clean

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

Note: Users may have an issue producing altair plots. You may need to
download the latest version of ChromeDriver.Instructions for installing
chromeDriver:

    conda install selenium
    conda install -c conda-forge python-chromedriver-binary

You need to include the ChromeDriver location in your system PATH.
Please follow the instructions
[here](https://www.kenst.com/2015/03/including-the-chromedriver-location-in-macos-system-path/)
for mac users and
[here](https://www.google.com/search?q=Including+the+ChromeDriver+location+in+PC&oq=Including+the+ChromeDriver+location+in+PC&aqs=chrome..69i57j69i60l2.2395j0j7&sourceid=chrome&ie=UTF-8)
for PC users.

  - R version 3.6.1 and R packages:
      - caret==6.0-85
      - docopt==0.6.1
      - tidyverse==1.3.0
      - janitor==1.2.0
      - GGally==1.4.0
      - kableExtra==1.1.0
      - knitr==1.27.2
      - testthat == 2.2.1
      - tidyselect == 1.1.0

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
