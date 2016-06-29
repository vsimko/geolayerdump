#!/usr/bin/Rscript

# lock file
# download random stuff
# on error delete partially download file
# unlock file
# exit

library(methods)
library(argparser)
library(httr)

p <- arg_parser("This script downloads a random layer from the list")

p <- add_argument(p, "URL",  help = "
                  Base URL of the Geoserver (e.g. 'http://map.mygeoserver.com/geoserver').")

p <- add_argument(p, "DIR", help = "
                  Output directory, where the downloaded layers will be stored")

p <- add_argument(p, "--layers", type = , default = "layers.log", help = "
                  File containing the names of layers.
                  Single layer name per line.")

argv <- parse_args(p)
#print(argv)
# argv <- list(
#   # URL = "http://map.mygeoserver.com/geoserver",
#   DIR = "testdir",
#   layers = "layers.log"
# )

if ( is.na(argv$layers) ) {
  argv$layers <- "/dev/stdin"
}

cat(sprintf("Geoserver URL: %s\n", argv$URL))
cat(sprintf("Directory:     %s\n", argv$DIR))
cat(sprintf("Layer names:   %s\n", argv$layers))

# list required layers
alllayers <- unlist(read.table(argv$layers, stringsAsFactors = FALSE))
print(alllayers)
# print(alllayers)

# list already downloaded layers
donelayers <- list.files(argv$DIR)
donelayers <- sub("\\.xml$", "", donelayers)
print(donelayers)
# print(donelayers)

# list layers remaining
setdiff(alllayers, donelayers)

