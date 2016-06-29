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
# print(alllayers)

# list already downloaded layers
donelayers <- list.files(argv$DIR)
donelayers <- sub("\\.xml$", "", donelayers)
# print(donelayers)

# list layers remaining
layers_to_download <- setdiff(alllayers, donelayers)

# dump for remaining layers (kml and gml)
i <- 0

invisible(lapply(layers_to_download, FUN = function(x) {
  cat(paste0(Sys.time(), "\n"))
  date <- Sys.Date()

  ### kml
  result = tryCatch({
    # download kml layer
    file_name <- paste0('./', argv$DIR, '/', date, '-', x, '.kml')
    cat(paste0("download and store: ", file_name), "\n")
    dir.create(dirname(file_name), showWarnings = FALSE)
    get_request <- paste0(argv$URL, "/brw_001/wms/kml?layers=", x)
    layers_dump <- GET(get_request)
    
    # store gml layer
    invisible(write(content(layers_dump, "text", encoding = "UTF-8"), file = file_name))
  }, warning = print, error = print)
  
  # ### gml
  # result = tryCatch({
  #   # download gml layer
  #   file_name <- paste0('./', argv$DIR, '/', date, '-', x, '.gml')
  #   cat(paste0("download and store: ", file_name), "\n")
  #   dir.create(dirname(file_name), showWarnings = FALSE)
  #   get_request <- paste0(argv$URL, "/brw_001/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=", x, "&maxFeatures=1")
  #   layers_dump <- GET(get_request)
  #   
  #   # store gml layer
  #   invisible(write(content(layers_dump, "text", encoding = "UTF-8"), file = file_name))
  # }, warning = print, error = print)
}))
