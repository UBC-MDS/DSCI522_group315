# run all analysis

Rscript src/01_download_data.R --url=https://github.com/SamEdwardes/ufc-data/raw/master/raw_total_fight_data.csv --out_file=data/01_raw/raw_total_fight_data.csv
Rscript src/02_preprocess_data.R --input_path=data/01_raw/raw_total_fight_data.csv --output_path=data/02_preprocessed/ --seed_num=1993