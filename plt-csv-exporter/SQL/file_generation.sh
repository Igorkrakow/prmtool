#!/bin/bash
# The following three lines have been added by UDB DB2.
#to run this file use command: sh run.sh "KY(RI)"
# for bulk export use: sh file_generation.sh "" "2023-01-01 00:00:00.000000"
# for go-life run: sh file_generation.sh.sh "2023-01-01 00:00:00.000000" ""
# !!! Use current date to export !!!
#set variable
log_with_timestamp() {
  local current_timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo "" | tee -a $logfile
  echo "$current_timestamp - $1" | tee -a $logfile
}
num_rows=100000
fileNameEndDate=$(date -d "$1" +%Y%m%d)
db2 connect to pddb
log_with_timestamp "CREATE json-transaction_ files"
#####################
echo "---------------------------"
echo "XML"
echo "---------------------------"
db2 export to json-transaction_HEADER.csv OF DEL MODIFIED BY NOCHARDEL  "
    SELECT
        'uuid',
        'json'
    FROM sysibm.sysdummy1"
db2 export to json-transaction_TMP.csv OF DEL MODIFIED BY NOCHARDEL  "
    SELECT
        uuid,
        json
    FROM TXSTORE.MIGRATED_TX_JSON"
###########################
db2 terminate
###########################
###########################
csvFileName="json-transaction"
###########################
split --numeric-suffixes --suffix-length=3  -l $num_rows $csvFileName'_TMP.csv' $csvFileName'_unix-'$fileNameEndDate'_'
for file in json-transaction_unix-*
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

echo "---------------------------"
echo "Transactions"
echo "---------------------------"
db2 connect to pddb
log_with_timestamp "CREATE tx-transaction_ files"
db2 export to tx-transaction_HEADER.csv OF DEL MODIFIED BY NOCHARDEL  "
            SELECT
                'tx_transaction_id',
                'global_trans_id',
                'correlation_id',
                'uuid',
                'player_id',
                'transaction_time',
                'transaction_type',
                'channel_id',
                'system_id',
                'transaction_amount',
                'transaction_discount_amount',
                'currency',
                'serial',
                'cdc',
                'game_engine_transaction_time',
                'product_id',
                'start_draw_number',
                'end_draw_number',
                'site_json_data',
                'serial_number'
            FROM sysibm.sysdummy1"
db2 export to tx-transaction_TMP.csv OF DEL MODIFIED BY NOCHARDEL  "
            SELECT
                TX_TRANSACTION_ID,
                GLOBAL_TRANS_ID,
                CORRELATION_ID,
                UUID,
                PLAYER_ID,
                TRANSACTION_TIME,
                TRANSACTION_TYPE,
                CHANNEL_ID,
                SYSTEM_ID,
                TRANSACTION_AMOUNT,
                TRANSACTION_DISCOUNT_AMOUNT,
                CURRENCY,
                SERIAL,
                CDC,
                GAME_ENGINE_TRANSACTION_TIME,
                PRODUCT_ID,
                START_DRAW_NUMBER,
                END_DRAW_NUMBER,
                SITE_JSON_DATA,
                SERIAL_NUMBER
            FROM TXSTORE.MIGRATED_TX_TRANSACTION"
###########################
db2 terminate
###########################
###########################
csvFileName="tx-transaction"
###########################
split --numeric-suffixes --suffix-length=3  -l $num_rows $csvFileName'_TMP.csv' $csvFileName'_unix-'$fileNameEndDate'_'
for file in tx-transaction_unix-*
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

echo "---------------------------"
echo "TX-DRAW"
echo "---------------------------"
db2 connect to pddb
log_with_timestamp "CREATE tx-draws_ files"
db2 export to tx-draws_HEADER.csv OF DEL MODIFIED BY NOCHARDEL  "
            SELECT
                'product_id',
                'draw_id',
                'draw_name',
                'draw_time',
                'draw_status'
            FROM sysibm.sysdummy1"
db2 export to tx-draws_TMP.csv OF DEL MODIFIED BY NOCHARDEL  "
            SELECT
                E.IDDGGAME as product_id,
                E.DRAWNUMBER as draw_id,
                null as draw_name,
                varchar_format(E.DRAWDATE,'YYYY-MM-DD HH24:MI:SS.FF3') as draw_time,
                case when g.NAME is not null then
                    'ACTIVE'
                else 'CLOSED' end as draw_status
            FROM GIS.DGGAMEEVENT E
            left join GIS.DGGAME G ON G.IDDGGAME=E.IDDGGAME
            AND G.IDDGGAMEEVENT_CURRENT=E.IDDGGAMEEVENT"
###########################
db2 terminate
###########################
###########################
csvFileName="tx-draws"
###########################
split --numeric-suffixes --suffix-length=3  -l $num_rows $csvFileName'_TMP.csv' $csvFileName'_unix-'$fileNameEndDate'_'
for file in tx-draws_unix-*
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

echo "---------------------------"
echo "TX-DRAW-ENTRY"
echo "---------------------------"
db2 connect to pddb
log_with_timestamp "CREATE tx-draw-entry_ files"
db2 export to tx-draw-entry_HEADER.csv OF DEL MODIFIED BY NOCHARDEL  "
            SELECT
               'tx_draw_entry_id',
               'tx_transaction_uuid',
               'draw_id',
               'product_id',
               'winning_status',
               'json_data'
            FROM sysibm.sysdummy1"
db2 export to tx-draw-entry_TMP.csv OF DEL MODIFIED BY NOCHARDEL  "
            SELECT DE.id as tx_draw_entry_id,
                            DE.uuid as tx_transaction_uuid,
                            DE.drawnumber as draw_id,
                            DE.product as product_id,
                            DE.win_status as winning_status,
                            null as json_data
            FROM TXSTORE.MIGRATED_TX_DRAW_ENTRY as DE
            join TXSTORE.MIGRATED_TX_TRANSACTION as t on DE.UUID=t.UUID"
###########################
db2 terminate
###########################
###########################
csvFileName="tx-draw-entry"
###########################
split --numeric-suffixes --suffix-length=3  -l $num_rows $csvFileName'_TMP.csv' $csvFileName'_unix-'$fileNameEndDate'_'
for file in tx-draw-entry_unix-*
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
echo "---------------------------"
echo "TX-RESULT"
echo "---------------------------"
db2 connect to pddb
log_with_timestamp "CREATE tx-result_ files"
db2 export to tx-result_HEADER.csv OF DEL MODIFIED BY NOCHARDEL  "
            SELECT
               'draw_id',
               'product_id',
               'prize_amount',
               'ts_created',
               'ts_modified',
               'tx_draw_entry_id',
               'validation_id',
               'claim_id',
               'prize_description',
               'prize_type',
               'winning_board_index',
               'winning_division'
            FROM sysibm.sysdummy1"
db2 export to tx-result_TMP.csv OF DEL MODIFIED BY NOCHARDEL  "
            SELECT
                r.DRAWNUMBER as draw_id,
                r.PRODUCT as product_id,
                r.TRANSACTION_AMOUNT as prize_amount,
                varchar_format(r.TRANSACTION_TIME_UTC,'YYYY-MM-DD HH24:MI:SS.FF3') as ts_created,
                varchar_format(r.TRANSACTION_TIME_UTC,'YYYY-MM-DD HH24:MI:SS.FF3') as ts_modified,
                r.TX_DRAW_ENTRY_ID as tx_draw_entry_id,
                r.LOTTERY_TX_HEADER_ID as validation_id,
                NULL as claim_id,
                NULL as prize_description,
                'CASH' as prize_type,
                NULL as winning_board_index,
                r.winningDivision as winning_division
            FROM
                TXSTORE.MIGRATED_RESULTS as r"
###########################
db2 terminate
###########################
###########################
csvFileName="tx-result"
###########################
split --numeric-suffixes --suffix-length=3  -l $num_rows $csvFileName'_TMP.csv' $csvFileName'_unix-'$fileNameEndDate'_'
for file in tx-result_unix-*
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