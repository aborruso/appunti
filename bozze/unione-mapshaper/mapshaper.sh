#!/bin/bash

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

set -x

mapshaper ./inputLayer.geojson -mosaic calc='output=collect(id).toString()' -o ./output.shp