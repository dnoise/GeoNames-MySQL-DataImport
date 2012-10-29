#!/bin/bash

# Default values for database variables.
dbhost="localhost"
dbport=3306
dbname="geonames"

logo() {
	echo "================================================================================================"
	echo "                           G E O N A M E S    D A T A    I M P O R T E R                        "
	echo "================================================================================================"
}

usage() {
	logo
	echo "Usage 1: " $0 "--download-data"
	echo "In this mode the current GeoNames.org's dumps are downloaded to the local machine."
	echo
	echo "Usage 2: " $0 "-a <action> -u <user> -p <password> -h <host> -r <port> -n <dbname>"
	echo " This is to operate with the geographic database"
    echo " Where <action> can be one of this: "
	echo "    download-data Downloads the last packages of data available in GeoNames."
    echo "    create-db Creates the mysl database structure with no data."
    echo "    import-dumps Imports geonames data into db. A database is previously needed for this to work."
	echo "    drop-db Removes the db completely."
    echo "    truncate-db Removes geonames data from db."
    echo
    echo " The rest of parameters indicates the following information:"
	echo "    -u <user>     User name to access database server."
	echo "    -p <password> User password to access database server."
	echo "    -h <host>     Data Base Server address (default: localhost)."
	echo "    -P <port>     Data Base Server Port (default: 3306)"
	echo "    -n <dbname>  Data Base Name for the geonames.org data (default: geonames)"
	echo "================================================================================================"
    exit -1
}

download_geonames_data() {
	echo "Downloading GeoNames.org data..." 
	wget http://download.geonames.org/export/dump/allCountries.zip
	wget http://download.geonames.org/export/dump/alternateNames.zip
	wget http://download.geonames.org/export/dump/admin1CodesASCII.txt
	wget http://download.geonames.org/export/dump/featureCodes_en.txt
	wget http://download.geonames.org/export/dump/timeZones.txt
	wget http://download.geonames.org/export/dump/countryInfo.txt
	unzip allCountries.zip
	unzip alternateNames.zip
	rm allCountries.zip
	rm alternateNames.zip
}

if [ $# -lt 1 ]; then
	usage
	exit 1
fi

logo

# Deals operation mode 1 (Download data bundles from geonames.org)
if { [ $# == 1 ] && [ "$1" == "--download-data" ]; } then
    download_geonames_data
	exit 0
fi

# Deals with operation mode 2 (Database issues...)
# Parses command line parameters.
while getopts "a:u:p:h:r:n:" opt; 
do
    case $opt in
        a) action=$OPTARG ;;
        u) dbusername=$OPTARG ;;
        p) dbpassword=$OPTARG ;;
        h) dbhost=$OPTARG ;;
        r) dbport=$OPTARG ;;
        n) dbname=$OPTARG ;;
    esac
done

#echo "Orden: " $action
#echo "UserName: " $dbusername
#echo "Password: " $dbpassword
#echo "DB Host: " $dbhost
#echo "DB Port: " $dbport
#echo "DB Name: " $dbname
#exit 0

case $action in
    download-data)
        download_geonames_data
        exit 0
    ;;
esac

while [ $# -gt 1 ]; do
    case "$1" in

        --create-db)
            
			echo "Creating \"geonames\" database"
			mysql -u $2 -p$3 < geonames_db_struct.sql
		;;

		"--import-dumps")
			echo "Importing \"geonames\" data into database"
			mysql -u $2 -p$3 < geonames_db_struct.sql
			mysql -u $2 -p$3 < geonames_import_data.sql
		;;	

		"--drop-db")
			echo "Dropping \"geonames\" database"
			mysql -u $2 -p$3 < geonames_drop_database.sql;
		;;

		"--truncate-db")
			echo "Truncating \"geonames\" database"
			mysql -u $2 -p$3 < geonames_trucate_db.sql;
		;;

	esac
done


if [ $? == 0 ]; then 
	echo "[OK]"
else
	echo "[FAILED]"
fi

exit 0
