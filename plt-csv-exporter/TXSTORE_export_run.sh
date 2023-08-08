#!/bin/bash
# The following three lines have been added by UDB DB2.
# To run this file use command: sh export_.sh "sql(java)" "KY(RI)" "2023-01-01 00:00:00.000000" "2023-06-23 00:00:00.000000" 1929238
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
  tool=$1
  project=$2
  startDate=$3
  endDate=$4
  minId=$5
fi
if [[ ($# -eq 4)&&(-z $minId) ]];
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
countMAX=$(db2 -x "SELECT MAX(H.TX_HEADER_ID) FROM TXSTORE.TX_HEADER H WHERE H.INSERT_TIMESTAMP<=(DATE('$endDate')+1 DAY) AND H.TX_HEADER_ID>$countMIN ")
log_with_timestamp "max TX_HEADER_ID = $countMAX"
##########################################################################################################################################################################################

log_with_timestamp "TRUNCATE TMP tables "

db2 "TRUNCATE TABLE TXSTORE.MIGRATED_TX_DRAW_ENTRY IMMEDIATE"| tee -a $logfile
db2 "TRUNCATE TABLE TXSTORE.MIGRATED_RESULTS IMMEDIATE"| tee -a $logfile
db2 "TRUNCATE TABLE TXSTORE.MIGR_TX_HEADER IMMEDIATE"| tee -a $logfile

##########################################################################################################################################################################################
log_with_timestamp "Copy data to MIGR_TX_HEADER from TX_HEADER "
db2 "INSERT INTO TXSTORE.MIGR_TX_HEADER (TX_HEADER_ID,PLAYER_ID,UUID)
      SELECT T.TX_HEADER_ID,T.PLAYER_ID,T.UUID
        FROM TXSTORE.TX_HEADER T
        JOIN TXSTORE.LOTTERY_TX_HEADER L
        ON T.TX_HEADER_ID = L.LOTTERY_TX_HEADER_ID
      WHERE $project_condition T.TX_HEADER_ID BETWEEN $countMIN AND $countMAX"| tee -a $logfile
#####################
log_with_timestamp "Copy data to MIGRATED_TX_DRAW_ENTRY from DGGAMEEVENT "
db2 "call TXSTORE.INSERT_INTO_MIGRATED_TX_DRAW_ENTRY()"| tee -a $logfile
#####################
log_with_timestamp "Copy data to MIGRATED_RESULTS from LOTTERY_TX_HEADER "
db2	"INSERT INTO TXSTORE.MIGRATED_RESULTS( ID, LOTTERY_TX_HEADER_ID,DRAWNUMBER,PRODUCT,TRANSACTION_AMOUNT,TRANSACTION_TIME_UTC,TX_DRAW_ENTRY_ID,UUID,DATA)
	SELECT TXSTORE.MIGRATED_RESULTS_SEQ.NEXTVAL,LTV.LOTTERY_TX_HEADER_ID,DE.DRAWNUMBER,LTV.PRODUCT,LTV.TRANSACTION_AMOUNT,LTV.TRANSACTION_TIME_UTC,DE.ID,VTH.UUID,BV.DATA
  FROM TXSTORE.LOTTERY_TX_HEADER LTV
           JOIN TXSTORE.LOTTERY_TX_HEADER LTW ON LTV.GLOBAL_TRANS_ID = LTW.GLOBAL_TRANS_ID
      AND LTW.LOTTERY_TRANSACTION_TYPE = 'WAGER'
      AND LTV.SERIAL = LTW.SERIAL
           JOIN TXSTORE.MIGR_TX_HEADER TH ON LTW.LOTTERY_TX_HEADER_ID = TH.TX_HEADER_ID
           JOIN TXSTORE.MIGR_TX_HEADER VTH ON LTV.LOTTERY_TX_HEADER_ID = VTH.TX_HEADER_ID
           JOIN TXSTORE.STRING_TX_BODY BV ON BV.UUID=VTH.UUID
           JOIN TXSTORE.MIGRATED_TX_DRAW_ENTRY DE ON TH.UUID = DE.UUID
      AND DE.DRAWNUMBER = LTV.START_DRAW_NUMBER
  WHERE LTV.LOTTERY_TRANSACTION_TYPE = 'VALIDATION'"| tee -a $logfile
#####################
if [ "$tool" = "java" ]; then
  log_with_timestamp "Starting -JAR csv-exporter for txExport "
  if [ "$project" = "KY" ]; then
    /tmp/java8/jre1.8.0_202/bin/java -jar ${script_full_path}/csv-exporter.jar txExport 1000 ${script_full_path} 001 > ${script_full_path}.log &
  elif [ "$project" = "RI" ]; then
    java -jar ${script_full_path}/csv-exporter.jar txExport 1000 ${script_full_path} 001 > ${script_full_path}.log &
  fi
elif [ "$tool" = "sql" ]; then
  db2 "call TXSTORE.TX_TRANSACTION_JSON_EXPORT(V_PROJECT => '$project');"| tee -a $logfile
  sh SQL/file_generation.sh "$endDate"
fi
#####################

echo "" | tee -a $logfile
echo "------------ END export ------------" | tee -a $logfile