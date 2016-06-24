#!/usr/bin/Rscript

library(methods)
library(utils)
library(argparser)
library(XML)

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

# download layers information
get_request <- 'http://map.bumprecorder.com/geoserver/wms?request=GetCapabilities&service=WMS'
layers_xml <- xmlParse(get_request)

# store raw xml file
if (TRUE) {
  date <- Sys.Date()
  saveXML(layers_xml, file = paste0(date, '-layers.xml'))
}

# print layer names
list_of_layers <- xpathApply(layers_xml, path = '//ns:Layer/ns:Name/text()',
                             namespaces = c(ns=getDefaultNamespace(layers_xml, simplify = TRUE)),
                             fun = function(x) {
                               print(toString.XMLNode(x))
                             })





print(argv)