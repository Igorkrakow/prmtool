#!/bin/bash
# The following three lines have been added by UDB DB2.
# To run this file use command: sh TSO_PURCHASE_EXTRACTION.sh "2023-01-01 00:00:00.000000" "2023-02-01 00:00:00.000000"
#######   set variable ########
if [ $# -lt 2 ];
then
  echo "$0: Missing arguments"
  exit 1
elif [ $# -gt 2 ];
then
  echo "$0: Too many arguments: $@"
  exit 1
else
  start_date=$1
  end_date=$2
fi

####  current directory #####
script_full_path="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# Declare log file
logfile="TSOscriptlog.log"

log_with_timestamp() {
  local current_timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo "" | tee -a $logfile
  echo "$current_timestamp - $1" | tee -a $logfile
  echo $1
}

num_rows=100000
fileNameEndDate=$(date -d "$1" +%Y%m%d-%H%M%S)
db2 connect to pddb

log_with_timestamp "CREATE TSO_GAME_SESSION FILE"

db2 export to TSO_GAME_SESSION_HEADER.csv OF DEL MODIFIED BY NOCHARDEL  "
    SELECT
        'external_id',
        'gamesession_id',
        'platform_id',
        'game_code',
        'currency',
        'session_id',
        'external_start_time',
        'start_time',
        'device_id',
        'start_transaction_id',
        'ext_start_transaction_id',
        'token',
        'external_end_time',
        'end_time',
        'end_transaction_id',
        'ext_end_transaction_id',
        'ip_address',
        'multiplayer_gamesession_id',
        'tournament_instance_id',
        'game_name',
        'platform_name',
        'subscription_id',
        'tot_purchase_amount',
        'tot_purchase_loy_point',
        'tot_winning_amount',
        'tot_refund_amount',
        'tot_earned_loy_point',
        'last_wager_date',
        'last_winning_date',
        'tot_claim_prize_amount',
        'last_update_date',
        'ext_divisor_amount'
FROM sysibm.sysdummy1"

db2 export to TSO_GAME_SESSION_TMP.csv OF DEL MODIFIED BY NOCHARDEL  "
    SELECT
        PLAYER_ID EXTERNAL_ID,
        GLOBAL_TRANS_ID gamesession_id,
        70 platform_id,
        PRODUCT game_code,
        'USD' currency,
        '' session_id,
        VARCHAR_FORMAT(TRANSACTION_TIME_LOCAL,'YYYY-MM-DD HH24:MI:SS.FF3') external_start_time,
        VARCHAR_FORMAT(TRANSACTION_TIME_LOCAL,'YYYY-MM-DD HH24:MI:SS.FF3') start_time,
        15 device_id,
        '8::1::' || PLAYER_ID || '::' || UUID || '::70' start_transaction_id,
        '' token,
        CASE
            WHEN (DRAWCLOSETIME < '2022-10-30 03:30:00.000') THEN VARCHAR_FORMAT((DRAWCLOSETIME+ 2 HOURS),'YYYY-MM-DD HH24:MI:SS.FF3')
            ELSE VARCHAR_FORMAT((DRAWCLOSETIME+ 1 HOURS),'YYYY-MM-DD HH24:MI:SS.FF3') END external_end_time, -- The draw close time for end draw number for the wager
        CASE
            WHEN (DRAWCLOSETIME < '2022-10-30 03:30:00.000') THEN VARCHAR_FORMAT((DRAWCLOSETIME+ 2 HOURS),'YYYY-MM-DD HH24:MI:SS.FF3')
            ELSE VARCHAR_FORMAT((DRAWCLOSETIME+ 1 HOURS),'YYYY-MM-DD HH24:MI:SS.FF3') END end_time,
        '8::1::' || PLAYER_ID || '::' || UUID || '::70' end_transaction_id,
        UUID ext_end_transaction_id,
        '' ip_address,
        '' multiplayer_gamesession_id,
        '' tournament_instance_id,
        '' game_name,
        'LOTTERY' platform_name,
        '' subscription_id,
        nvl(TRANSACTION_AMOUNT,0) tot_purchase_amount,
        0 tot_purchase_loy_point,
        NVL(TRANSACTION_AMOUNT_VALIDATION, 0) tot_winning_amount,
        0 tot_refund_amount,
        0 tot_earned_loy_point,
        VARCHAR_FORMAT(TRANSACTION_TIME_LOCAL,'YYYY-MM-DD HH24:MI:SS.FF3') last_wager_date,
        VARCHAR_FORMAT(TRANSACTION_TIME_LOCAL_VALIDATION,'YYYY-MM-DD HH24:MI:SS.FF3') last_winning_date,
        0 tot_claim_prize_amount,
        VARCHAR_FORMAT(CURRENT_TIMESTAMP,'YYYY-MM-DD HH24:MI:SS.FF3') last_update_date,
        100 ext_divisor_amount
    FROM TXSTORE.TMP_TSO_ROUND_SESSION
    WHERE START_DATE_UPDATE >= '$start_date' AND END_DATE_UPDATE <= '$end_date'"

db2 terminate

csvFileName="TSO_GAME_SESSION"

split --numeric-suffixes --suffix-length=3  -l $num_rows $csvFileName'_TMP.csv' $csvFileName'_unix-'$fileNameEndDate'-'
for file in TSO_GAME_SESSION_unix-*
do
mv "$file" "$file.csv"
done
count=$(wc -l < $csvFileName'_TMP.csv')
if (($count==0)); then
  mv $csvFileName'_TMP.csv' $csvFileName'_unix-'$fileNameEndDate'_001.csv'
else
  rm $csvFileName'_TMP.csv'
fi
for f in $csvFileName'_unix-'*
      do
              head -n 1 $csvFileName'_HEADER.csv' > $csvFileName'_HEADER_TMP.csv'
              cat "$f" >>$csvFileName'_HEADER_TMP.csv'
              mv -f $csvFileName'_HEADER_TMP.csv' "$f"
              perl -p -e 's/\n/\r\n/' < $f > ${f//_unix/}
              rm $f
      done
rm $csvFileName'_HEADER.csv'


log_with_timestamp "CREATE TSO_GAME_ROUND FILE"

db2 connect to pddb
db2 export to TSO_GAME_ROUND_HEADER.csv OF DEL MODIFIED BY NOCHARDEL  "
    SELECT
        'external_id',
        'round_id',
        'gamesession_id',
        'start_date',
        'purchase_amount',
        'purchase_points',
        'win_amount',
        'earned_points',
        'refunded_amount',
        'refunded_points',
        'claiming_prize',
        'subscription_id',
        'currency',
        'platform_id',
        'platform_name',
        'game_code',
        'game_name',
        'last_wager_date',
        'last_win_date',
        'close_date',
        'ext_divisor_amount'
 FROM sysibm.sysdummy1"

 db2 export to TSO_GAME_ROUND_TMP.csv OF DEL MODIFIED BY NOCHARDEL  "
     SELECT
         PLAYER_ID EXTERNAL_ID,
         GLOBAL_TRANS_ID round_id,
         GLOBAL_TRANS_ID gamesession_id,
         VARCHAR_FORMAT(TRANSACTION_TIME_LOCAL,'YYYY-MM-DD HH24:MI:SS.FF3') start_date,
         TRANSACTION_AMOUNT purchase_amount,
         0 purchase_points,
         TRANSACTION_AMOUNT_VALIDATION win_amount,
         0 earned_points,
         0 refunded_amount,
         0 refunded_points,
         0 claiming_prize,
         '' SUBSCRIPTION_ID,
         'USD' currency,
         70 platform_id,
         'LOTTERY' platform_name,
         PRODUCT game_code,
         '' game_name,
         VARCHAR_FORMAT(TRANSACTION_TIME_LOCAL,'YYYY-MM-DD HH24:MI:SS.FF3') last_wager_date,
         VARCHAR_FORMAT(TRANSACTION_TIME_LOCAL_VALIDATION,'YYYY-MM-DD HH24:MI:SS.FF3') last_win_date,
         VARCHAR_FORMAT(TRANSACTION_TIME_LOCAL_VALIDATION,'YYYY-MM-DD HH24:MI:SS.FF3') close_date,
         100 ext_divisor_amount
         FROM TXSTORE.TMP_TSO_ROUND_SESSION
     WHERE START_DATE_RUN >= '$start_date' AND END_DATE_RUN <= '$end_date'"

db2 terminate

csvFileName="TSO_GAME_ROUND"

split --numeric-suffixes --suffix-length=3  -l $num_rows $csvFileName'_TMP.csv' $csvFileName'_unix-'$fileNameEndDate'-'
for file in TSO_GAME_ROUND_unix-*
do
mv "$file" "$file.csv"
done
count=$(wc -l < $csvFileName'_TMP.csv')
if (($count==0)); then
  mv $csvFileName'_TMP.csv' $csvFileName'_unix-'$fileNameEndDate'_001.csv'
else
  rm $csvFileName'_TMP.csv'
fi
for f in $csvFileName'_unix-'*
      do
              head -n 1 $csvFileName'_HEADER.csv' > $csvFileName'_HEADER_TMP.csv'
              cat "$f" >>$csvFileName'_HEADER_TMP.csv'
              mv -f $csvFileName'_HEADER_TMP.csv' "$f"
              perl -p -e 's/\n/\r\n/' < $f > ${f//_unix/}
              rm $f
      done
rm $csvFileName'_HEADER.csv'