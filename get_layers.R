#!/usr/bin/Rscript

library(methods)
library(argparser)

p <- arg_parser("This script downloads a list of available layers from a geoserver")

p <- add_argument(p, "URL",  help = "
                  Base URL of the Geoserver.")

p <- add_argument(p, "--keep-xml", help = "
                  If specified, the orignal XML from Geoserver will also be
                  stored.")

p <- add_argument(p, "--output", help = "
                  By default, the output will be printed to standard output.
                  This parameter specifies an alternative location, where the
                  results should be stored.")

argv <- parse_args(p)
print(argv)
