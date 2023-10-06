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
db2 "insert into TXSTORE.TMP_TSO_PAYMENT(TRANSACTION_ID, PLAYER_ID, STATUS, DRAW, TRANSACTION_DATE, UUID,
                                         PRODUCT, AMOUNT, GLOBAL_TRANS_ID,
                                         START_DATE_RUN, END_DATE_RUN,
                                         START_DATE_UPDATE, END_DATE_UPDATE, DELTA)
     SELECT
         LTHW.LOTTERY_TX_HEADER_ID,
         THW.PLAYER_ID,
         CASE WHEN NVL(VAL.TRANSACTION_AMOUNT,0)   > 0
                  THEN 'WINNING'
              ELSE 'LOSER' END as status,
         e.DRAWNUMBER,
         CASE WHEN VAL.TRANSACTION_TIME_LOCAL IS NULL THEN LTHW.TRANSACTION_TIME_LOCAL
              ELSE VAL.TRANSACTION_TIME_LOCAL END as date,
         CASE WHEN LTV.UUID IS NULL THEN THW.UUID
              ELSE LTV.UUID END as uuid,
         lthw.PRODUCT,
         NVL(VAL.TRANSACTION_AMOUNT,0),
         LTHW.GLOBAL_TRANS_ID,
         '$startDate',
         '$endDate',
         '$startDate',
         '$endDate',
         'i'
     FROM TXSTORE.LOTTERY_TX_HEADER LTHW
              JOIN TXSTORE.TX_HEADER THW ON THW.TX_HEADER_ID = LTHW.LOTTERY_TX_HEADER_ID
         AND LTHW.LOTTERY_TRANSACTION_TYPE = 'WAGER'
         AND LTHW.TRANSACTION_TIME_LOCAL >= '$startDate' AND LTHW.TRANSACTION_TIME_LOCAL < '$endDate'
     -- Closed wagers only
              JOIN TXSTORE.LAST_CLOSED ON lthw.PRODUCT = TXSTORE.LAST_CLOSED.IDDGGAME
         AND END_DRAW_NUMBER <= TXSTORE.LAST_CLOSED.DRAWNUMBER
              join  gis.DGGAMEEVENT e on e.DRAWNUMBER between lthw.START_DRAW_NUMBER and lthw.END_DRAW_NUMBER and e.IDDGGAME = lthw.PRODUCT
              LEFT JOIN TXSTORE.LOTTERY_TX_HEADER  VAL ON val.LOTTERY_TRANSACTION_TYPE = 'VALIDATION' AND (
             (lthw.GLOBAL_TRANS_ID = VAL.GLOBAL_TRANS_ID AND lthw.SERIAL = VAL.SERIAL and lthw.START_DRAW_NUMBER = e.DRAWNUMBER) OR
             (lthw.CDC = VAL.CDC AND lthw.SERIAL = VAL.SERIAL  and lthw.START_DRAW_NUMBER = e.DRAWNUMBER AND lthw.GLOBAL_TRANS_ID != VAL.GLOBAL_TRANS_ID))
              left join TXSTORE.TX_HEADER LTV on VAL.LOTTERY_TX_HEADER_ID = LTV.TX_HEADER_ID
               WHERE LTHW.START_DRAW_NUMBER != LTHW.END_DRAW_NUMBER"| tee -a $logfile

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
     WHERE LHW.TRANSACTION_TIME_LOCAL >= '$startDate' AND LHW.TRANSACTION_TIME_LOCAL < '$endDate'
     group by THW.PLAYER_ID, LHW.GLOBAL_TRANS_ID,LHW.PRODUCT,LHW.TRANSACTION_TIME_LOCAL,
     THW.UUID,GIS.DGGAME.NAME,LHW.TRANSACTION_AMOUNT,
     GE.DRAWCLOSETIME,LHW.LOTTERY_TX_HEADER_ID"

log_with_timestamp "ROUND_SESSION OPEN STARTING"
db2 "call TXSTORE.TSO_ROUND_SESSION_OPEN(START_TIME => '$startDate',END_TIME => '$endDate');"| tee -a $logfile

log_with_timestamp "Starting TSO PURCHASE file_generation"
sh TSO/SH/TSO_PURCHASE_EXTRACTION.sh "$startDate" "$endDate"

log_with_timestamp "Starting TSO PAYMENT file_generation"
sh TSO/SH/TSO_PAYMENT_EXTRACTION.sh "$startDate" "$endDate"

log_with_timestamp "Starting TSO ROUND_SESSION file_generation"
sh TSO/SH/TSO_ROUND_SESSION_EXTRACTION.sh "$startDate" "$endDate"



