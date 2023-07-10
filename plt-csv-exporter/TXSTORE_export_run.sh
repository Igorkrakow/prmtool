#!/bin/bash
# The following three lines have been added by UDB DB2.
# To run this file use command: sh export_.sh "KY(RI)" "2023-01-01 00:00:00.000000" "2023-06-23 00:00:00.000000" 1929238
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

####  create TMP tables for TXSTORE #####
echo "####### Start Creation of TMP TABLES ##########"

sh ${script_full_path}/TXSTORE_creation.sh

echo "####### Creation done ##########"
#####################
db2 connect to pddb
#####################

echo "####### Count min and max TX_HEADER_ID for current range#######"
countMIN=$(db2 -x "SELECT MIN(H.TX_HEADER_ID) FROM TXSTORE.TX_HEADER H WHERE H.INSERT_TIMESTAMP>='$startDate' $conditionId")
echo "min TX_HEADER_ID = $countMIN"
#####################
countMAX=$(db2 -x "SELECT MAX(H.TX_HEADER_ID) FROM TXSTORE.TX_HEADER H WHERE H.INSERT_TIMESTAMP<=(DATE('$endDate')+1 DAY) AND H.TX_HEADER_ID>$countMIN ")
echo "max TX_HEADER_ID = $countMAX"
##########################################################################################################################################################################################

echo "####### TRUNCATE TMP tables #######"

db2 "TRUNCATE TABLE TXSTORE.MIGRATED_TX_DRAW_ENTRY IMMEDIATE"
db2 "TRUNCATE TABLE TXSTORE.MIGRATED_RESULTS IMMEDIATE"
db2 "TRUNCATE TABLE TXSTORE.MIGR_TX_HEADER IMMEDIATE"

##########################################################################################################################################################################################
echo "####### Copy data to MIGR_TX_HEADER from TX_HEADER #######"
db2 "INSERT INTO TXSTORE.MIGR_TX_HEADER (TX_HEADER_ID,PLAYER_ID,UUID)
      SELECT T.TX_HEADER_ID,T.PLAYER_ID,T.UUID
        FROM TXSTORE.TX_HEADER T
        JOIN TXSTORE.LOTTERY_TX_HEADER L
        ON T.TX_HEADER_ID = L.LOTTERY_TX_HEADER_ID
      WHERE $project_condition T.TX_HEADER_ID BETWEEN $countMIN AND $countMAX"
#####################
echo "####### Copy data to MIGRATED_TX_DRAW_ENTRY from DGGAMEEVENT #######"
db2 "INSERT INTO TXSTORE.MIGRATED_TX_DRAW_ENTRY (ID,UUID,DRAWNUMBER,PRODUCT,WIN_STATUS)
	SELECT
      TXSTORE.MIGRATED_TX_DRAW_ENTRY_SEQ.NEXTVAL,H.UUID,E.DRAWNUMBER,L.PRODUCT,
      CASE
          WHEN V.COUNT_VALIDATION >= 1 THEN 'WINNING'
          ELSE 'NON_WINNING'
          END AS WIN_STATUS
  FROM
      TXSTORE.MIGR_TX_HEADER H
          INNER JOIN
      TXSTORE.LOTTERY_TX_HEADER L ON L.LOTTERY_TX_HEADER_ID=H.TX_HEADER_ID
          INNER JOIN
      GIS.DGGAMEEVENT E ON E.IDDGGAME=L.PRODUCT AND E.DRAWNUMBER BETWEEN L.START_DRAW_NUMBER AND L.END_DRAW_NUMBER
          LEFT JOIN
      (
          SELECT
              GLOBAL_TRANS_ID,
              START_DRAW_NUMBER,
              COUNT(*) AS COUNT_VALIDATION
          FROM
              TXSTORE.LOTTERY_TX_HEADER
          WHERE
                  LOTTERY_TRANSACTION_TYPE = 'VALIDATION'
          GROUP BY
              GLOBAL_TRANS_ID, START_DRAW_NUMBER
      ) V ON V.GLOBAL_TRANS_ID = L.GLOBAL_TRANS_ID AND V.START_DRAW_NUMBER = E.DRAWNUMBER
  WHERE
          L.LOTTERY_TRANSACTION_TYPE = 'WAGER'

"
#####################
echo "####### Copy data to MIGRATED_RESULTS from LOTTERY_TX_HEADER #######"
db2	"INSERT INTO TXSTORE.MIGRATED_RESULTS( ID, LOTTERY_TX_HEADER_ID,DRAWNUMBER,PRODUCT,TRANSACTION_AMOUNT,TRANSACTION_TIME_UTC,TX_DRAW_ENTRY_ID,UUID,DATA)
	SELECT TXSTORE.MIGRATED_RESULTS_SEQ.NEXTVAL,LV.LOTTERY_TX_HEADER_ID,DE.DRAWNUMBER,LV.PRODUCT,LV.TRANSACTION_AMOUNT,LV.TRANSACTION_TIME_UTC,DE.ID,HV.UUID,BV.DATA
  FROM TXSTORE.MIGRATED_TX_DRAW_ENTRY DE
      INNER JOIN TXSTORE.MIGR_TX_HEADER HW ON DE.UUID=HW.UUID
      INNER JOIN TXSTORE.LOTTERY_TX_HEADER LV ON LV.LOTTERY_TX_HEADER_ID=HW.TX_HEADER_ID AND LV.LOTTERY_TRANSACTION_TYPE='VALIDATION'
      INNER JOIN TXSTORE.TX_HEADER HV ON HV.TX_HEADER_ID=LV.LOTTERY_TX_HEADER_ID INNER JOIN TXSTORE.STRING_TX_BODY BV ON BV.UUID=HV.UUID"
#####################
echo "####### Starting -JAR csv-exporter for txExport #######"
if [ "$project" = "KY" ]; then
	/tmp/java8/jre1.8.0_202/bin/java -jar ${script_full_path}/csv-exporter.jar txExport 1000 ${script_full_path} 001 > ${script_full_path}.log &
elif [ "$project" = "RI" ]; then
  java -jar ${script_full_path}/csv-exporter.jar txExport 1000 ${script_full_path} 001 > ${script_full_path}.log &
fi
#####################