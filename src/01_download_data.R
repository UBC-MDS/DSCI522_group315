# author: DSCI_522_group_315
# date: 2020-01-18

"This script downloads data csv data from the web and save the file to a local filepath in csv format.

Usage: download_data.R --url=<url> --out_file=<out_file>

Options:
--url=<url>              URL of the data (in csv format)
--out_file=<out_file>    Path (including filename) to locally save the file

Example: Rscript 01_download_data.R --url=https://github.com/SamEdwardes/ufc-data/raw/master/raw_total_fight_data.csv --out_file=data/01_raw/raw_total_fight_data.csv

" -> doc

library(docopt)

opt <- docopt(doc)

main <- function(url, out_file){
    download.file(url = url, destfile = out_file)
}

main(opt$url, opt$out_file)
