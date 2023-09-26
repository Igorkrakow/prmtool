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

log_with_timestamp "CREATE TSO_PURCHASE_TRANSACTION FILE"

db2 export to TSO_PURCHASE_TRANSACTION_HEADER.csv OF DEL MODIFIED BY NOCHARDEL  "
    SELECT
        'external_id',
        'id_transaction',
        'async_retry_counter',
        'device_id',
        'exchange_rate',
        'exchange_rate_sys_currency',
        'external_transaction_date',
        'external_transaction_id',
        'game_code',
        'game_currency',
        'input_data',
        'ip_address ',
        'last_executed_step',
        'last_result',
        'last_result_code',
        'last_result_description',
        'last_update_date',
        'output_dataholder',
        'platform_id',
        'process_id',
        'process_status',
        'proxy_address',
        'retry_counter',
        'tot_amount',
        'tot_amount_player_currency',
        'tot_amount_system_currency',
        'tot_loy_point',
        'validation_core_result_code',
        'validation_core_result_desc',
        'validation_result_code',
        'free_ticket_enabled',
        'free_ticket_id',
        'last_executed_rollback_step',
        'ast_rollback_result',
        'last_rollback_result_code',
        'last_rollback_result_desc',
        'player_token',
        'rollback_retry_counter',
        'status',
        'game_name',
        'platform_name',
        'round_id',
        'gamesession_id',
        'id_transaction_basket',
        'ext_basket_transaction_id',
        'subscription_id',
        'external_system_id',
        'channel_id',
        'ext_divisor_amount'
 FROM sysibm.sysdummy1"

db2 export to TSO_PURCHASE_TRANSACTION_TMP.csv OF DEL MODIFIED BY NOCHARDEL  "
    SELECT
        PLAYER_ID EXTERNAL_ID,
        '8::1::' || PLAYER_ID || '::' || UUID || '::70' ID_TRANSACTION,
        0 ASYNC_RETRY_COUNTER,
        15 DEVICE_ID,
        '1.0000000000' EXCHANGE_RATE,
        '1.0000000000' EXCHANGE_RATE_SYS_CURRENCY,
        VARCHAR_FORMAT(TRANSACTION_DATE,'YYYY-MM-DD HH24:MI:SS.FF3') EXTERNAL_TRANSACTION_DATE,
        UUID EXTERNAL_TRANSACTION_ID,
        PRODUCT GAME_CODE,
        'USD' GAME_CURRENCY,
        '' INPUT_DATA,
        '' IP_ADDRESS,
        'PURCHASE_CREATE_GAME_ROUND' LAST_EXECUTED_STEP,
        'OK' LAST_RESULT,
         0 LAST_RESULT_CODE,
        'OK' LAST_RESULT_DESCRIPTION,
        VARCHAR_FORMAT(CURRENT_TIMESTAMP,'YYYY-MM-DD HH24:MI:SS.FF3') LAST_UPDATE_DATE,
        '' OUTPUT_DATAHOLDER,
        70 platform_id,
        'GAME_PLAY_STAKE' process_id,
        'COMPLETED' process_status,
        '' PROXY_ADDRESS,
         0 RETRY_COUNTER,
        NVL(AMOUNT, 0) TOT_AMOUNT,
        NVL(AMOUNT, 0) TOT_AMOUNT_PLAYER_CURRENCY,
        NVL(AMOUNT, 0) TOT_AMOUNT_SYSTEM_CURRENCY,
        0 TOT_LOY_POINT,
        0 VALIDATION_CORE_RESULT_CODE,
        'OK' VALIDATION_CORE_RESULT_DESC,
        'OK_SAVE_AND_PROCESS' VALIDATION_RESULT_CODE,
        'false' FREE_TICKET_ENABLED,
        '' FREE_TICKET_ID,
        '' LAST_EXECUTED_ROLLBACK_STEP,
        '' LAST_ROLLBACK_RESULT,
        '' LAST_ROLLBACK_RESULT_CODE,
        '' LAST_ROLLBACK_RESULT_DESC,
        '' PLAYER_TOKEN,
        0 ROLLBACK_RETRY_COUNTER,
        STATUS,
        NULL GAME_NAME,
        NULL PLATFORM_NAME,
        GLOBAL_TRANS_ID ROUND_ID,
        GLOBAL_TRANS_ID GAMESESSION_ID,
        '' ID_TRANSACTION_BASKET,
        '' EXT_BASKET_TRANSACTION_ID,
        '' SUBSCRIPTION_ID,
        5008 EXTERNAL_SYSTEM_ID,
        1 CHANNEL_ID,
        100 EXT_DIVISOR_AMOUNT
    FROM TXSTORE.TMP_TSO_PURCHASE
    WHERE START_DATE_UPDATE >= '$start_date' AND END_DATE_UPDATE <= '$end_date'"

db2 terminate

csvFileName="TSO_PURCHASE_TRANSACTION"

split --numeric-suffixes --suffix-length=3  -l $num_rows $csvFileName'_TMP.csv' $csvFileName'_unix-'$fileNameEndDate'-'
for file in TSO_PURCHASE_TRANSACTION_unix-*
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


log_with_timestamp "CREATE TSO_PURCHASE_AMOUNT FILE"

db2 connect to pddb
db2 export to TSO_PURCHASE_AMOUNT_HEADER.csv OF DEL MODIFIED BY NOCHARDEL  "
    SELECT
        'external_id',
        'purchase_transaction_id',
        'purchase_type',
        'amount',
        'amount_pl_currency',
        'amount_sys_currency',
        'bonus_amount',
        'bonus_amount_pl_currency',
        'bonus_amount_sys_currency',
        'external_purchase_tx_id',
        'game_code',
        'purchase_confirm_date',
        'purchase_reserve_date',
        'purchase_rollback_date',
        'purchase_rollback_id',
        'id_transaction',
        'ext_divisor_amount',
        'reserve_id',
        'confirm_id',
        'Txt_trans_ext_id'
 FROM sysibm.sysdummy1"

 db2 export to TSO_PURCHASE_AMOUNT_TMP.csv OF DEL MODIFIED BY NOCHARDEL  "
     SELECT
         PLAYER_ID EXTERNAL_ID,
         '8::1::' || PLAYER_ID || '::' || UUID || '::70' purchase_transaction_id,
         'REAL_MONEY_DEBIT' purchase_type,
          NVL(AMOUNT, 0) AMOUNT,
          NVL(AMOUNT, 0) amount_pl_currency,
          NVL(AMOUNT, 0) amount_sys_currency,
          0 bonus_amount,
          0 bonus_amount_pl_currency,
          0 bonus_amount_sys_currency,
          UUID external_purchase_tx_id,
          PRODUCT game_code,
          VARCHAR_FORMAT(TRANSACTION_DATE,'YYYY-MM-DD HH24:MI:SS.FF3') purchase_confirm_date,
          VARCHAR_FORMAT(TRANSACTION_DATE,'YYYY-MM-DD HH24:MI:SS.FF3') purchase_reserve_date,
          '' purchase_rollback_date,
          '' purchase_rollback_id,
          '8::1::' || PLAYER_ID || '::' || UUID || '::70' ID_TRANSACTION,
          100 ext_divisor_amount,
          '' reserve_id,
          '' confirm_id,
           GLOBAL_TRANS_ID  txt_trans_ext_id
     FROM TXSTORE.TMP_TSO_PURCHASE
     WHERE START_DATE_RUN >= '$start_date' AND END_DATE_RUN <= '$end_date'"

db2 terminate

csvFileName="TSO_PURCHASE_AMOUNT"

split --numeric-suffixes --suffix-length=3  -l $num_rows $csvFileName'_TMP.csv' $csvFileName'_unix-'$fileNameEndDate'-'
for file in TSO_PURCHASE_AMOUNT_unix-*
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