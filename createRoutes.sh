#!/bin/bash

clear
echo "OpenIG createRoutes.sh utility starting..."

# --------------------------------------------------------------------------------------------------------------------------------------------------------
# Simon Moffatt July 2015																     	
# A utility script to automatically create route files for OpenIG API protection									     
# --------------------------------------------------------------------------------------------------------------------------------------------------------


# Globals -------------------------------------------------------------------------------------------------------------------------------------------------

ROUTE_FILE="routes.dat" #File where raw route data is placed. Each line should be METHOD, URI. Eg GET, http://app.example.com:8080/widgets/
ROUTE_TEMPLATE=$(<templateRoute.json) #File which contains the template JSON route file
COUNTER=0 #Used to manage line numbering

# Globals -------------------------------------------------------------------------------------------------------------------------------------------------

#Read in the provided routes data that has been exported from the API and assign variables for pushing to the new route output
while read line; do    

	IFS=', ' read -a lineArray <<< "$line"; #Take each line in the routes file and split method and uri out based on , delimiter
	METHOD=${lineArray[0]} #Eg GET, POST, PUT, DELETE
	FULLPATH=${lineArray[1]} #Eg protocol://server:port/endpoint
	ENDPOINT=$(echo $FULLPATH | cut -d '/' -f4-)
	ROUTENAME=$METHOD"_"$ENDPOINT #Made up name for the route Eg GET_http://app.example.com:8080/widgets
	BASE=$(echo $FULLPATH | cut -d'/' -f1-3) #Pull out base Eg protocol://server:port/
	FILENAME=$(echo $ROUTENAME | sed -e 's/\//_/g')

	#Do some replacements on the template 
	ROUTE_TEMPLATE_TMP=${ROUTE_TEMPLATE/<NAME>/$ROUTENAME}
	ROUTE_TEMPLATE_TMP=${ROUTE_TEMPLATE_TMP/<METHOD>/$METHOD}
	ROUTE_TEMPLATE_TMP=${ROUTE_TEMPLATE_TMP/<BASE>/$BASE}	
	ROUTE_TEMPLATE_TMP=${ROUTE_TEMPLATE_TMP/<ENDPOINT>/"^/$ENDPOINT"}		
	
	echo $ROUTE_TEMPLATE_TMP > "$FILENAME.json"
	echo "Route file created: $FILENAME.json"
	COUNTER=$(($COUNTER + 1)) #Increment line counter

done < $ROUTE_FILE

echo "Finished"



