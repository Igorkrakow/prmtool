#!/bin/bash
# The following three lines have been added by UDB DB2.
# To run this file use command: sh TXSTORE_export_run.sh "KY(RI)" "2023-01-01 00:00:00.000000" "2023-06-23 00:00:00.000000" 1929238
#######   set variable ########
if [ $# -lt 3 ];
then
  echo "$0: Missing arguments"
  exit 1
elif [ $# -gt 4 ];
then
  echo "$0: Too many arguments: $@"
  exit 1
else
  project=$1
  startDate=$2
  endDate=$3
  minId=$4
fi
if [[ ($# -eq 3)&&(-z $minId) ]];
then
	conditionId=""
else
	conditionId="AND H.TX_HEADER_ID> $minId"
fi

if [ "$project" = "KY" ]; then
	project_condition="L.PRODUCT NOT IN (30,35) AND "
elif [ "$project" = "RI" ]; then
  project_condition="L.PRODUCT IN (15) AND "
else
  echo "Project with name $project - not exist"
  exit 1
fi

####  current directory #####

script_full_path="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

##########################################################################################################################################################################################
# Declare log file
logfile="scriptlog.log"
echo "" | tee -a $logfile
echo "------------ Start TXSTORE export ------------" | tee -a $logfile
log_with_timestamp() {
  local current_timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo "" | tee -a $logfile
  echo "$current_timestamp - $1" | tee -a $logfile
}

#####################
db2 connect to pddb
#####################

log_with_timestamp "Count min and max TX_HEADER_ID for current range"
countMIN=$(db2 -x "SELECT MIN(H.TX_HEADER_ID) FROM TXSTORE.TX_HEADER H WHERE H.INSERT_TIMESTAMP>='$startDate' $conditionId")
log_with_timestamp "min TX_HEADER_ID = $countMIN"
#####################
countMAX=$(db2 -x "SELECT max(H.TX_HEADER_ID)
                   FROM TXSTORE.TX_HEADER H where h.TX_HEADER_ID<(SELECT MIN(H.TX_HEADER_ID)
                                                                  FROM TXSTORE.TX_HEADER H
                  WHERE H.TX_HEADER_ID>'$countMIN'and H.INSERT_TIMESTAMP>(DATE('$endDate')+1 DAY)) ")
log_with_timestamp "max TX_HEADER_ID = $countMAX"
##########################################################################################################################################################################################

log_with_timestamp "TRUNCATE TMP tables "

db2 "TRUNCATE TABLE TXSTORE.MIGRATED_RESULTS IMMEDIATE"| tee -a $logfile
db2 "TRUNCATE TABLE TXSTORE.MIGR_TX_HEADER IMMEDIATE"| tee -a $logfile
db2 "TRUNCATE TABLE TXSTORE.MIGRATED_TX_JSON IMMEDIATE"| tee -a $logfile
db2 "TRUNCATE TABLE TXSTORE.MIGRATED_TX_TRANSACTION IMMEDIATE"| tee -a $logfile

##########################################################################################################################################################################################
log_with_timestamp "Copy data to MIGR_TX_HEADER from TX_HEADER "
echo "Count of transaction for MIGR_TX_HEADER:"
db2 "SELECT COUNT(*) FROM TXSTORE.TX_HEADER T JOIN TXSTORE.LOTTERY_TX_HEADER L ON T.TX_HEADER_ID = L.LOTTERY_TX_HEADER_ID
           WHERE $project_condition T.TX_HEADER_ID BETWEEN $countMIN AND $countMAX"| tee -a $logfile
db2 "INSERT INTO TXSTORE.MIGR_TX_HEADER (TX_HEADER_ID,PLAYER_ID,UUID)
      SELECT T.TX_HEADER_ID,T.PLAYER_ID,T.UUID
        FROM TXSTORE.TX_HEADER T
        JOIN TXSTORE.LOTTERY_TX_HEADER L
        ON T.TX_HEADER_ID = L.LOTTERY_TX_HEADER_ID
      WHERE $project_condition T.TX_HEADER_ID BETWEEN $countMIN AND $countMAX"| tee -a $logfile
#####################
log_with_timestamp "Starting Create Json and tx-transaction files"
db2 "call TXSTORE.TX_TRANSACTION_JSON_EXPORT(V_PROJECT => '$project');"| tee -a $logfile
#####################
log_with_timestamp "Copy data to MIGRATED_TX_DRAW_ENTRY from DGGAMEEVENT "
echo "Count of transaction for MIGRATED_TX_DRAW_ENTRY: "
db2 "SELECT sum(L.END_DRAW_NUMBER - L.START_DRAW_NUMBER +1) FROM TXSTORE.LOTTERY_TX_HEADER L
     INNER JOIN TXSTORE.MIGR_TX_HEADER H ON L.LOTTERY_TX_HEADER_ID = H.TX_HEADER_ID
     WHERE $project_condition L.LOTTERY_TRANSACTION_TYPE = 'WAGER'" | tee -a $logfile
db2 "call TXSTORE.INSERT_INTO_MIGRATED_TX_DRAW_ENTRY()"| tee -a $logfile
####################
log_with_timestamp "Copy data to MIGRATED_RESULTS from LOTTERY_TX_HEADER"
db2 -td@ -f SQL/INSERT/insert_migrated_results.sql | tee -a $logfile

log_with_timestamp "UPDATE WIN_STATUS for MIGRATED_TX_DRAW_ENTRY"
db2 "UPDATE TXSTORE.MIGRATED_TX_DRAW_ENTRY SET WIN_STATUS = 'WINNING' where ID in(select TX_DRAW_ENTRY_ID from TXSTORE.MIGRATED_RESULTS)"

sh SQL/file_generation.sh "$endDate"
sh SQL/kpi.sh "$project" "$countMIN" "$countMAX"
#####################

echo "" | tee -a $logfile
echo "------------ END export ------------" | tee -a $logfile