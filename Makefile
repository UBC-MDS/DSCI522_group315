all: data/01_raw/raw_total_fight_data.csv data/02_preprocessed/*.csv analysis/figures/fig_eda_01_corplot.png analysis/figures/*_relationship.png analysis/figures/table_eda_01_summary_stats.csv analysis/figures/confusion_matrix.png analysis/figures/error.png.png analysis/results.csv analysis/weights.csv report/report.md

# download data
data/01_raw/raw_total_fight_data.csv : Rscript src/01_download_data.R
	Rscript src/01_download_data.R --url=https://github.com/SamEdwardes/ufc-data/raw/master/raw_total_fight_data.csv --out_file=data/01_raw/raw_total_fight_data.csv

# pre-process data
data/02_preprocessed/*.csv : src/02_preprocess_data.R
	Rscript src/02_preprocess_data.R --input_path=data/01_raw/raw_total_fight_data.csv --output_path=data/02_preprocessed/ --seed_num=1993

# run EDA and create EDA figures
analysis/figures/fig_eda_01_corplot.png : Rscript src/03_eda.R
	Rscript src/03_eda.R --X_train_path=data/02_preprocessed/X_train.csv --y_train_path=data/02_preprocessed/y_train.csv --out_dir=analysis/figures/

analysis/figures/*_relationship.png : Rscript src/03_eda.R
	Rscript src/03_eda.R --X_train_path=data/02_preprocessed/X_train.csv --y_train_path=data/02_preprocessed/y_train.csv --out_dir=analysis/figures/

analysis/figures/table_eda_01_summary_stats.csv : Rscript src/03_eda.R
	Rscript src/03_eda.R --X_train_path=data/02_preprocessed/X_train.csv --y_train_path=data/02_preprocessed/y_train.csv --out_dir=analysis/figures/

# Optimize and test model
analysis/figures/confusion_matrix.png : src/04_ml_analysis.py
	python src/04_ml_analysis.py --input_path_Xtrain=data/02_preprocessed/X_train.csv --input_path_ytrain=data/02_preprocessed/y_train.csv --input_path_Xtest=data/02_preprocessed/X_test.csv --input_path_ytest=data/02_preprocessed/y_test.csv --out_path=analysis/figures/ --out_path_csv=analysis/

analysis/figures/error.png.png : src/04_ml_analysis.py
	python src/04_ml_analysis.py --input_path_Xtrain=data/02_preprocessed/X_train.csv --input_path_ytrain=data/02_preprocessed/y_train.csv --input_path_Xtest=data/02_preprocessed/X_test.csv --input_path_ytest=data/02_preprocessed/y_test.csv --out_path=analysis/figures/ --out_path_csv=analysis/

analysis/results.csv : src/04_ml_analysis.py
	python src/04_ml_analysis.py --input_path_Xtrain=data/02_preprocessed/X_train.csv --input_path_ytrain=data/02_preprocessed/y_train.csv --input_path_Xtest=data/02_preprocessed/X_test.csv --input_path_ytest=data/02_preprocessed/y_test.csv --out_path=analysis/figures/ --out_path_csv=analysis/

analysis/weights.csv : src/04_ml_analysis.py
	python src/04_ml_analysis.py --input_path_Xtrain=data/02_preprocessed/X_train.csv --input_path_ytrain=data/02_preprocessed/y_train.csv --input_path_Xtest=data/02_preprocessed/X_test.csv --input_path_ytest=data/02_preprocessed/y_test.csv --out_path=analysis/figures/ --out_path_csv=analysis/

# render final report
report/report.md : render('report/report.Rmd', output_format = 'github_document')
	Rscript -e "rmarkdown::render('report/report.Rmd', output_format = 'github_document')"

clean :
	rm -f data/01_raw/raw_total_fight_data.csv
	rm -f data/02_preprocessed/*.csv
	rm -f analysis/figures/*.png
	rm -f analysis/figures/*.csv
	rm -f analysis/*.csv
	rm -f report/report.Rmd
	rm -f report/report.md
	rm -f report/report.html
	rm -f UFC_Judge_Scoring.bib
	


	
	
	
	
	

