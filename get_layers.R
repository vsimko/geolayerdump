# R Script
# download layers xml and
library(XML)

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