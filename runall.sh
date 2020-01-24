# run all analysis

Rscript src/01_download_data.R --url=https://github.com/SamEdwardes/ufc-data/raw/master/raw_total_fight_data.csv --out_file=data/01_raw/raw_total_fight_data.csv
Rscript src/02_preprocess_data.R --input_path=data/01_raw/raw_total_fight_data.csv --output_path=data/02_preprocessed/ --seed_num=1993
Rscript src/03_eda.R --X_train_path=data/02_preprocessed/X_train.csv --y_train_path=data/02_preprocessed/y_train.csv --out_dir=analysis/figures/