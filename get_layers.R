#!/usr/bin/Rscript

library(methods)
library(argparser)
library(XML)

p <- arg_parser("This script downloads a list of available layers from a geoserver")

p <- add_argument(p, "URL",  help = "
                  Base URL of the Geoserver (e.g. 'http://map.mygeoserver.com/geoserver').")

p <- add_argument(p, "--keep-xml", help = "
                  If specified, the orignal XML from Geoserver will also be
                  stored.",
                  default=TRUE)

p <- add_argument(p, "--output", help = "
                  By default, the output will be printed to standard output.
                  This parameter specifies an alternative location, where the
                  results should be stored.")

argv <- parse_args(p)
# argv <- list(
#   URL = "http://map.mygeoserver.com/geoserver",
#   keep_xml = TRUE,
#   output = ""
# )

# download layers information
get_request <- paste0(argv$URL, "/wms?request=GetCapabilities&service=WMS")
layers_xml <- xmlParse(get_request)

# store raw xml file
if (argv$keep_xml) {
  date <- Sys.Date()
  invisible(saveXML(layers_xml, file = paste0(date, '-layers.xml')))
}

# print layer names (as return)
list_of_layers <- xpathApply(layers_xml, path = '//ns:Layer/ns:Name/text()',
                             namespaces = c(ns=getDefaultNamespace(layers_xml, simplify = TRUE)),
                             fun = function(x) {
                               cat(paste0(trimws(toString.XMLNode(x)), "\n"))
                             })