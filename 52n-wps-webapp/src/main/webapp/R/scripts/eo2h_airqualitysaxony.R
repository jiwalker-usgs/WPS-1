# Copyright (C) 2013 by 52°North Initiative for Geospatial Open Source Software GmbH, Contact: info@52north.org
# Author: Daniel Nuest (d.nuest@52north.org)

#wps.des: eo2hAirQuality, creates a coverage with interpolated air quality parameters from a SOS;

##################### dependencies #############################################
library(maptools)
library(rgdal)
library(raster)
library(fields)
library(sos4R)
library(stringr)

##################### helper functions #########################################
myLog <- function(...) {
	cat(paste0("[eo2h aqsax] ", ..., "\n"))
}

###################### resources ###############################################
# this resource has the required functions and data
#wps.resource: EO2H/AirQualityMapping.RData;

###################### manual testing ##########################################
# load("D:/Dokumente/52N-Geoprocessing-Community/R-in-EO2HEAVEN/AirQualityMapping.RData")
# in_sos_url <- "http://141.30.100.135:8080/eo2heavenSOS/sos"
# in_time <- "2012-02-02"
# in_offering_id <- "o3"
# in_observed_prop <- "http://www.eo2heaven.org/classifier/parameter/daily_average/O3"
# in_stations <- "DESN019,DESN004,DESN014,DESN017,DESN001,DESN059,DESN053,DESN011,DESN052,DESN045,DESN051,DESN050,DESN049,DESN012,DESN024,DESN082,DESN080,DESN081,DESN085,DESN074,DESN079,DESN061,DESN076"

###################### input definition ########################################

# wps.in: in_sos_url, string, title = SOS service URL,
# abstract = SOS URL endpoint,
# value = http://141.30.100.135:8080/eo2heavenSOS/sos,
# minOccurs = 0, maxOccurs = 1;

# wps.in: in_offering_id, type = string, title = identifier for the used offering,
# value = O3,
# minOccurs = 0, maxOccurs = 1;

# wps.in: in_observed_prop, type = string, title = identifier for the observed property to request,
# value = http://www.eo2heaven.org/classifier/parameter/daily_average/O3,
# minOccurs = 0, maxOccurs = 1;

# wps.in: in_stations, type = string, title = a comma seperated list of stations,
# minOccurs = 1, maxOccurs = 1;

# wps.in: in_time, type = string, title = time for TM_Equals filter,
# minOccurs = 1, maxOccurs = 1;

#################### make sos request (based on wmsConfig.xml) #################
sos <- SOS(url = in_sos_url)
eventTime <- sosCreateTime(sos = sos, time = in_time, operator = "TM_Equals")
myLog(" time:		 ", in_time)

responseFormat <- "text/xml;subtype=&quot;om/1.0.0&quot;"

chr.pollutant <- in_offering_id
myLog("pollutant:		", chr.pollutant)

stations <- str_split(string = in_stations, pattern = ",", )[[1]]
vector.stations <- trim(stations)
myLog("stations: (", length(vector.stations), "):		",
		toString(vector.stations))

################### parse the sos request ######################################
in_measurements <- "10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32"
measurements <- str_split(string = in_measurements, pattern = ",", )[[1]]
vector.measurements <- str_trim(measurements) 
myLog("measurements (", length(vector.measurements), "):		",
		toString(vector.measurements))

################### calculate concentrations ###################################
#
# change function to return the output object from writeRaster
#
chr.file <- "saxony_output.tif";
getPollutantConentrationAsGeoTiff <- function(vector.stations,
		vector.measurements, chr.pollutant, chr.file) {
	#calculate raster
	.raster.result <- function.getPollutantConcentration(vector.stations,
			vector.measurements, chr.pollutant)
	
	#write result raster
	.x <- writeRaster(raster.result, filename=chr.file, format="GTiff",
			overwrite=TRUE)
	return(.x)
}

##################### calculate the coverage > output ##########################
#function.getPollutantConentrationAsGeoTiff(vector.stations, vector.measurements,
#		chr.pollutant, chr.file);
output <- getPollutantConentrationAsGeoTiff(vector.stations, vector.measurements,
		chr.pollutant, chr.file);
#wps.out: output, geotiff;

# Fehler in dataframe.observations[dataframe.observations[, 1] == names(raster.station),  : 
# nicht-numerisches Argument für binären Operator