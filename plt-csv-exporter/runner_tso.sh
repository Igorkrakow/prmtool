#!/bin/bash
logfile="scriptlog.log"

if [ $# -lt 2 ];
then
  echo "$0: Missing arguments"
  exit 1
elif [ $# -gt 2 ];
then
  echo "$0: Too many arguments: $@"
  exit 1
else
  startDate=$1
  endDate=$2
fi

echo "" | tee -a $logfile
echo "------------ Start run ------------" | tee -a $logfile
log_with_timestamp() {
  local current_timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo "" | tee -a $logfile
  echo "$current_timestamp - $1" | tee -a $logfile
}

#####################
db2 connect to pddb
#####################

##PURCHASE
log_with_timestamp "PURCHASE STARTING"

log_with_timestamp "PURCHASE_OPEN_TO_CLOSED_DELTA STARTING"
db2 "call TXSTORE.TSO_PURCHASE_OPEN_TO_CLOSED_DELTA(START_TIME => '$startDate',END_TIME => '$endDate');"| tee -a $logfile

log_with_timestamp "TSO_PURCHASE_CLOSED STARTING"
db2 "call TXSTORE.TSO_PURCHASE_CLOSED(START_TIME => '$startDate',END_TIME => '$endDate');"| tee -a $logfile

log_with_timestamp "TSO_PURCHASE_OPEN STARTING"
db2 "call TXSTORE.TSO_PURCHASE_OPEN(START_TIME => '$startDate',END_TIME => '$endDate');"| tee -a $logfile

##PAYMENT
log_with_timestamp "PAYMENT STARTING"

log_with_timestamp "TSO_PAYMENT_OPEN_SD_TO_CLOSED_DELTA STARTING"
db2 "call TXSTORE.TSO_PAYMENT_OPEN_SD_TO_CLOSED_DELTA(START_TIME => '$startDate',END_TIME => '$endDate');"| tee -a $logfile

log_with_timestamp "TSO_PAYMENT_OPEN_MD_TO_CLOSED_DELTA STARTING"
db2 "call TXSTORE.TSO_PAYMENT_OPEN_MD_TO_CLOSED_DELTA(START_TIME => '$startDate',END_TIME => '$endDate');"| tee -a $logfile

log_with_timestamp "TSO_PAYMENT_SD_CLOSED STARTING"
db2 "call TXSTORE.TSO_PAYMENT_SD_CLOSED(START_TIME => '$startDate',END_TIME => '$endDate');"| tee -a $logfile

log_with_timestamp "TSO_PAYMENT_MD_CLOSED STARTING"
db2 "call TXSTORE.TSO_PAYMENT_MD_CLOSED(START_TIME => '$startDate',END_TIME => '$endDate');"| tee -a $logfile

log_with_timestamp "TSO_PAYMENT_SD_OPEN STARTING"
db2 "call TXSTORE.TSO_PAYMENT_SD_OPEN(START_TIME => '$startDate',END_TIME => '$endDate');"| tee -a $logfile

log_with_timestamp "TSO_PAYMENT_MD_OPEN STARTING"
db2 "call TXSTORE.TSO_PAYMENT_MD_OPEN(START_TIME => '$startDate',END_TIME => '$endDate');"| tee -a $logfile

##Round_session
log_with_timestamp "RAUND_SESSION STARTING"

log_with_timestamp "TSO_ROUND_SESSION_OPEN_TO_CLOSED_DELTA STARTING"
db2 "call TXSTORE.TSO_ROUND_SESSION_OPEN_TO_CLOSED_DELTA(START_TIME => '$startDate',END_TIME => '$endDate');"| tee -a $logfile

log_with_timestamp "ROUND_SESSION CLOSED STARTING"
db2 "INSERT INTO TXSTORE.TMP_TSO_ROUND_SESSION(LOTTERY_TX_HEADER_ID, PLAYER_ID,
                                               GLOBAL_TRANS_ID, PRODUCT,
                                               TRANSACTION_TIME_LOCAL, UUID,
                                               DRAWCLOSETIME, NAME, TRANSACTION_AMOUNT,
                                               TRANSACTION_AMOUNT_VALIDATION,
                                               TRANSACTION_TIME_LOCAL_VALIDATION,
                                               START_DATE_RUN, END_DATE_RUN,
                                               START_DATE_UPDATE, END_DATE_UPDATE,
                                               DELTA)
     SELECT
         LHW.LOTTERY_TX_HEADER_ID,
         THW.PLAYER_ID EXTERNAL_ID,
         LHW.GLOBAL_TRANS_ID gamesession_id,
         LHW.PRODUCT game_code,
         VARCHAR_FORMAT(LHW.TRANSACTION_TIME_LOCAL,'YYYY-MM-DD HH24:MI:SS.FF3') start_time,
         THW.UUID ext_start_transaction_id,
         GE.DRAWCLOSETIME end_time, -- The draw close time for end draw number for the wager
         GIS.DGGAME.NAME GAME_NAME,
         NVL(LHW.TRANSACTION_AMOUNT,0) tot_purchase_amount,
         SUM(NVL(LHV.TRANSACTION_AMOUNT,0)) tot_winning_amount,
         CASE WHEN SUM(NVL(LHV.TRANSACTION_AMOUNT,0)) = 0 THEN null ELSE VARCHAR_FORMAT(max(LHV.TRANSACTION_TIME_LOCAL),'YYYY-MM-DD HH24:MI:SS.FF3')
         end as  last_winning_date,
         '$startDate',
         '$endDate',
         '$startDate',
         '$endDate',
         'i'
     FROM TXSTORE.LOTTERY_TX_HEADER LHW
              JOIN TXSTORE.TX_HEADER THW ON LHW.LOTTERY_TX_HEADER_ID = THW.TX_HEADER_ID
              JOIN GIS.DGGAME ON LHW.PRODUCT = GIS.DGGAME.HOSTPRODUCTNUMBER
              JOIN GIS.DGGAMEEVENT GE ON LHW.END_DRAW_NUMBER = GE.DRAWNUMBER
         AND LHW.PRODUCT = GE.IDDGGAME
         AND LOTTERY_TRANSACTION_TYPE = 'WAGER'
         --     JOIN PAM_CMD.SMS_CONTRACT_MIGRATION cm ON cm.CONTRACT_IDENTITY = THW.PLAYER_ID
     --     Closed wagers only
              JOIN TXSTORE.LAST_CLOSED ON GIS.DGGAME.IDDGGAME = TXSTORE.LAST_CLOSED.IDDGGAME
         AND END_DRAW_NUMBER <= TXSTORE.LAST_CLOSED.DRAWNUMBER
              left JOIN (SELECT * FROM TXSTORE.LOTTERY_TX_HEADER LTHV JOIN TXSTORE.TX_HEADER THV ON LOTTERY_TX_HEADER_ID = TX_HEADER_ID
                    WHERE LOTTERY_TRANSACTION_TYPE  = 'VALIDATION') LHV on
             (LHW.GLOBAL_TRANS_ID=LHV.GLOBAL_TRANS_ID
                 and LHW.SERIAL=LHV.SERIAL)
             or (LHW.CDC=LHV.CDC
             and LHW.SERIAL=LHV.SERIAL
             AND THW.PLAYER_ID = LHV.PLAYER_ID
             and LHW.GLOBAL_TRANS_ID!=LHV.GLOBAL_TRANS_ID)
     WHERE LHW.TRANSACTION_TIME_LOCAL >= '$startDate', AND LHW.TRANSACTION_TIME_LOCAL < '$endDate',
     group by THW.PLAYER_ID, LHW.GLOBAL_TRANS_ID,LHW.PRODUCT,LHW.TRANSACTION_TIME_LOCAL,
     THW.UUID,GIS.DGGAME.NAME,LHW.TRANSACTION_AMOUNT,
     GE.DRAWCLOSETIME,LHW.LOTTERY_TX_HEADER_ID"

log_with_timestamp "ROUND_SESSION OPEN STARTING"
db2 "call TXSTORE.TSO_ROUND_SESSION_OPEN(START_TIME => '$startDate',END_TIME => '$endDate');"| tee -a $logfile



