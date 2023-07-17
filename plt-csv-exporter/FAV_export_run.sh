#!/bin/bash

####  current directory #####
if [ $# -lt 1 ];
then
  echo "$0: Missing arguments"
  exit 1
else
  project=$1
fi
script_full_path="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

#####################
db2 connect to pddb
#####################

#-:::::::::::::::::::::::::::::::FAV:::::::::::::::::::::::::::::::
echo "####### Start Creation of TMP VIEWS ##########"

db2 "CREATE OR REPLACE VIEW GIS.VIEW_MIGRATED_FAV AS
    SELECT
        FW.IDDGFAVORITEWAGER,
        ROW_NUMBER() OVER (PARTITION BY FW.PLAYERID ORDER BY FW.IDDGFAVORITEWAGER ) AS IDDGFAVORITEWAGERNUMBER,
        FW.NUMBEROFDRAWS,
        FW.IDDGGAME,
        FW.PLAYERID,
        FW.TOTALPRICE,
        FW.STAKE,
        FW.TSCREATED,
        FW.TSLASTMODIFIED,
        FBS.IDDGFAVORITEBOARDSTACK,
        FWG.IDDGFAVORITEWAGERGROUP
    FROM GIS.DGFAVORITEWAGER FW
             INNER JOIN GIS.DGFAVORITEBOARDSTACK FBS ON FBS.IDDGFAVORITEWAGER=FW.IDDGFAVORITEWAGER
             INNER JOIN GIS.DGFAVORITEWAGERGROUP FWG ON FW.IDDGFAVORITEWAGERGROUP = FWG.IDDGFAVORITEWAGERGROUP"


if [ "$project" = "RI" ]; then
	NROFSECONDARYQUICKPICKMARKS="FB.NROFSECONDARYQUICKPICKMARKS"
else
  NROFSECONDARYQUICKPICKMARKS="null NROFSECONDARYQUICKPICKMARKS"
fi
db2 "CREATE OR REPLACE VIEW GIS.VIEW_MIGRATED_FAV_BOARDS AS
    SELECT
        FB.IDDGFAVORITEBOARD,
        FB.IDDGFAVORITEBOARDSTACK,
        FB.BOARDSTAKE,
        FB.PICKSYSTEM,
        FB.NUMBEROFQUICKPICKMARKS,
        $NROFSECONDARYQUICKPICKMARKS ,
        FB.PICKVALUES,
        FB.BOARDINDEX,
        FB.MODIFIER,
        FW.TSCREATED
    FROM GIS.DGFAVORITEWAGER FW
    INNER JOIN GIS.DGFAVORITEBOARDSTACK FBS ON FBS.IDDGFAVORITEWAGER=FW.IDDGFAVORITEWAGER
    INNER JOIN GIS.DGFAVORITEBOARD FB ON FB.IDDGFAVORITEBOARDSTACK=FBS.IDDGFAVORITEBOARDSTACK"
echo "####### Creation done ##########"

#####################
echo "####### Starting -JAR csv-exporter for txExport #######"
if [ "$project" = "KY" ]; then
/tmp/java8/jre1.8.0_202/bin/java -jar ${script_full_path}/csv-exporter.jar favExport 1000 ${script_full_path} 001 > ${script_full_path}.log &
else
java -jar ${script_full_path}/csv-exporter.jar txExport 1000 ${script_full_path} 001 > ${script_full_path}.log &
fi
#####################
