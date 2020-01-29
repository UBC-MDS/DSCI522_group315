clean : 
	rm -f data/02_preprocessed/*.csv
	rm -f data/01_raw/*.csv
	rm -f analysis/results.csv
	rm -f analysis/weights.csv
	rm -f analysis/figures/*.csv
	rm -f analysis/figures/*.png
	rm -f report/report.md
	rm -f report/report.html