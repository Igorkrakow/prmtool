#!/bin/bash

####  current directory #####

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
        FBS.IDDGFAVORITEBOARDSTACK
    FROM GIS.DGFAVORITEWAGER FW
    INNER JOIN GIS.DGFAVORITEBOARDSTACK FBS ON FBS.IDDGFAVORITEWAGER=FW.IDDGFAVORITEWAGER"

db2 "CREATE OR REPLACE VIEW GIS.VIEW_MIGRATED_FAV_BOARDS AS
    SELECT
        FB.IDDGFAVORITEBOARD,
        FB.IDDGFAVORITEBOARDSTACK,
        FB.BOARDSTAKE,
        FB.PICKSYSTEM,
        FB.NUMBEROFQUICKPICKMARKS,
        FB.NROFSECONDARYQUICKPICKMARKS,
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
java -jar ${script_full_path}/csv-exporter.jar favExport 1000 ${script_full_path} 001 > ${script_full_path}.log &
#####################
