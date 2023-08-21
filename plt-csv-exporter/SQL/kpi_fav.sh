#!/bin/bash
# The following three lines have been added by UDB DB2.
#to run this file use command: sh run.sh "KY(RI)"
# for bulk export use: sh file_generation.sh "" "2023-01-01 00:00:00.000000"
# for go-life run: sh file_generation.sh.sh "2023-01-01 00:00:00.000000" ""
# !!! Use current date to export !!!
#set variable
logfile="scriptlog.log"
log_with_timestamp() {
  local current_timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo "" | tee -a $logfile
  echo "$current_timestamp - $1" | tee -a $logfile
}

db2 connect to PDDB
db2 export to kpi_HEADER.csv OF DEL MODIFIED BY NOCHARDEL  "
    SELECT
        'name',
        'value'
    FROM sysibm.sysdummy1"

echo "---------------------------"
echo "FAVORITES KPIS"
echo "---------------------------"

db2 export to kpis_favorites_1_group_.csv OF DEL MODIFIED BY NOCHARDEL  "
    SELECT
        'FAVORITES. all groups' as name,
         count(*)
        FROM GIS.DGFAVORITEWAGERGROUP"

db2 export to kpis_favorites_2_wager_.csv OF DEL MODIFIED BY NOCHARDEL  "
    SELECT
        'FAVORITES. all wagers' as name,
         count(*)
        FROM GIS.DGFAVORITEWAGER"

db2 export to kpis_favorites_3_stack_.csv OF DEL MODIFIED BY NOCHARDEL  "
    SELECT
        'FAVORITES. all stacks' as name,
         count(*)
        FROM GIS.DGFAVORITEBOARDSTACK"

db2 export to kpis_favorites_4_boards_.csv OF DEL MODIFIED BY NOCHARDEL  "
    SELECT
        'FAVORITES. all boards' as name,
         count(*)
        FROM GIS.GIS.DGFAVORITEBOARD"
###########################
db2 terminate
###########################
cat "kpi_HEADER.csv" kpis_favorites_*> "kpi_fav.csv"
rm -f "kpi_HEADER.csv"
rm -f kpis_*.csv