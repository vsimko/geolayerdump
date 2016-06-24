#!/bin/bash
# $1 url for getting capabilities of geoserver (e.g. http://mygeoserver.com/geoserver/wms?request=GetCapabilities&service=WMS)

# download xml list of layers
wget $1 --output-document='layers.xml'

# select layer names
xmllint --xpath '//Layer/Name' layers.xml

# update list of layers
# print report
