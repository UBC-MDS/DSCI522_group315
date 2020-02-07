# Run the entire data analysis pipeline from downloading raw data, 
# preprocessing data, performing EDA, machine learning, and reporting.
# author: Sam Edwardes
# date: 2020-01-30

all : report/report.md \
			README.Rmd \
			README.md

# download data
data/01_raw/raw_total_fight_data.csv : src/01_download_data.R
	mkdir -p data/01_raw
	Rscript src/01_download_data.R --url=https://github.com/SamEdwardes/ufc-data/raw/master/raw_total_fight_data.csv \
								   --out_file=data/01_raw/raw_total_fight_data.csv

#pre-process data
data/02_preprocessed/X_test.csv \
data/02_preprocessed/X_train.csv \
data/02_preprocessed/y_test.csv \
data/02_preprocessed/y_train.csv : src/02_preprocess_data.R \
		data/01_raw/raw_total_fight_data.csv
	mkdir -p data/02_preprocessed
	Rscript src/02_preprocess_data.R --input_path=data/01_raw/raw_total_fight_data.csv \
									 --output_path=data/02_preprocessed/ \
									 --seed_num=1993
	
# run EDA and create EDA figures
analysis/figures/fig_eda_01_corplot.png \
analysis/figures/fig_eda_02_striking_features_relationship.png \
analysis/figures/fig_eda_03_ground_features_relationship.png \
analysis/figures/fig_eda_04_attacks_to_features_relationship.png \
analysis/figures/fig_eda_05_attacks_from_features_relationship.png \
analysis/figures/table_eda_01_summary_stats.csv : src/03_eda.R \
		data/02_preprocessed/X_train.csv \
		data/02_preprocessed/y_train.csv
	mkdir -p analysis/figures
	Rscript src/03_eda.R --X_train_path=data/02_preprocessed/X_train.csv \
						 --y_train_path=data/02_preprocessed/y_train.csv \
						 --out_dir=analysis/figures/

# Optimize model
analysis/results.csv \
analysis/weights.csv : src/04_ml_analysis.py \
		 data/02_preprocessed/X_train.csv \
		 data/02_preprocessed/y_train.csv
	python src/04_ml_analysis.py --input_path=data/02_preprocessed/ \
								 --out_path=analysis/figures/ \
								 --out_path_csv=analysis/

# Test model			 
analysis/figures/confusion_matrix.png \
analysis/figures/error.png : src/04_ml_analysis.py \
data/02_preprocessed/X_train.csv \
		 data/02_preprocessed/y_train.csv \
		 data/02_preprocessed/X_test.csv \
		 data/02_preprocessed/y_test.csv
	python src/04_ml_analysis.py --input_path=data/02_preprocessed/ \
								 --out_path=analysis/figures/ \
								 --out_path_csv=analysis/

# render final report
report/report.md : report/report.Rmd \
	   report/UFC_Judge_Scoring.bib \
	   analysis/figures/confusion_matrix.png \
		 analysis/figures/error.png \
		 analysis/results.csv \
		 analysis/weights.csv \
		 analysis/figures/fig_eda_01_corplot.png \
	   analysis/figures/fig_eda_02_striking_features_relationship.png \
		 analysis/figures/fig_eda_03_ground_features_relationship.png \
		 analysis/figures/fig_eda_04_attacks_to_features_relationship.png \
		 analysis/figures/fig_eda_05_attacks_from_features_relationship.png \
		 analysis/figures/table_eda_01_summary_stats.csv
	Rscript -e "rmarkdown::render('report/report.Rmd', output_format = 'github_document')"

# render README
README.md : README.Rmd \
			report/UFC_Judge_Scoring.bib \
			report/report.md
	Rscript -e "rmarkdown::render('README.Rmd', output_format = 'github_document')"
	rm -f README.html

clean :
	rm -f data/01_raw/raw_total_fight_data.csv
	rm -f data/02_preprocessed/*.csv
	rm -f analysis/figures/*.png
	rm -f analysis/figures/*.csv
	rm -f analysis/*.csv
	rm -f report/report.md
	rm -f report/report.html
	rm -f README.html