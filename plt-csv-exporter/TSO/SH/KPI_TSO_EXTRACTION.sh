#!/bin/bash
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
fileNameEndDate=$(date -d "$1" +%Y%m%d)
db2 connect to pddb

log_with_timestamp "KPI_RI_-DB2_COUNT_MIGRATED_DRAW_WAGERS.csv"

db2 export to KPI_RI_$fileNameEndDate-DB2_COUNT_MIGRATED_DRAW_WAGERS_HEADER.csv OF DEL MODIFIED BY NOCHARDEL coldel0x7C "
    SELECT
        'game_code',
        'count'
 FROM sysibm.sysdummy1"

db2 export to KPI_RI_$fileNameEndDate-DB2_COUNT_MIGRATED_DRAW_WAGERS_TMP.csv OF DEL MODIFIED BY NOCHARDEL coldel0x7C "
    select  PRODUCT as game_code,count(*) as count from TXSTORE.TMP_TSO_PURCHASE
    group by PRODUCT"

db2 terminate

csvFileName="KPI_RI_$fileNameEndDate-DB2_COUNT_MIGRATED_DRAW_WAGERS"

split --numeric-suffixes --suffix-length=3  -l $num_rows $csvFileName'_TMP.csv' $csvFileName'_unix-'
for file in KPI_RI_$fileNameEndDate-DB2_COUNT_MIGRATED_DRAW_WAGERS_unix-*
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


log_with_timestamp "KPI_RI_-DB2_COUNT_MIGRATED_DRAW_PRIZE_TRANSACTIONS_BY_TIER"
db2 connect to pddb
db2 export to KPI_RI_$fileNameEndDate-DB2_COUNT_MIGRATED_DRAW_PRIZE_TRANSACTIONS_BY_TIER_HEADER.csv OF DEL MODIFIED BY NOCHARDEL coldel0x7C "
    SELECT
        'tier_type',
        'count'
 FROM sysibm.sysdummy1"

db2 export to KPI_RI_$fileNameEndDate-DB2_COUNT_MIGRATED_DRAW_PRIZE_TRANSACTIONS_BY_TIER_TMP.csv OF DEL MODIFIED BY NOCHARDEL coldel0x7C "
    SELECT
        CASE WHEN AMOUNT > 2280000 THEN 'HIGH'
                ELSE 'LOW' END as tier_type,
        count(*) as count
    FROM TXSTORE.TMP_TSO_PAYMENT
    group by CASE WHEN AMOUNT > 2280000 THEN 'HIGH'
                  ELSE 'LOW' END"

db2 terminate

csvFileName="KPI_RI_$fileNameEndDate-DB2_COUNT_MIGRATED_DRAW_PRIZE_TRANSACTIONS_BY_TIER"

split --numeric-suffixes --suffix-length=3  -l $num_rows $csvFileName'_TMP.csv' $csvFileName'_unix-'
for file in KPI_RI_$fileNameEndDate-DB2_COUNT_MIGRATED_DRAW_PRIZE_TRANSACTIONS_BY_TIER_unix-*
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



log_with_timestamp "KPI_RI_-DB2_AGGREGATED_MIGRATED_DRAW_AMOUNTS_BY_TIER"
db2 connect to pddb
db2 export to KPI_RI_$fileNameEndDate-DB2_AGGREGATED_MIGRATED_DRAW_AMOUNTS_BY_TIER_HEADER.csv OF DEL MODIFIED BY NOCHARDEL coldel0x7C "
    SELECT
        'tier_type',
        'sum_amount'
 FROM sysibm.sysdummy1"

db2 export to KPI_RI_$fileNameEndDate-DB2_AGGREGATED_MIGRATED_DRAW_AMOUNTS_BY_TIER_TMP.csv OF DEL MODIFIED BY NOCHARDEL coldel0x7C "
   SELECT
           CASE WHEN AMOUNT > 2280000 THEN 'HIGH'
                ELSE 'LOW' END as tier_type,
           sum(AMOUNT) as sum_amount
       FROM TXSTORE.TMP_TSO_PAYMENT
       group by CASE WHEN AMOUNT > 2280000 THEN 'HIGH'
                     ELSE 'LOW' END"

db2 terminate

csvFileName="KPI_RI_$fileNameEndDate-DB2_AGGREGATED_MIGRATED_DRAW_AMOUNTS_BY_TIER"

split --numeric-suffixes --suffix-length=3  -l $num_rows $csvFileName'_TMP.csv' $csvFileName'_unix-'
for file in KPI_RI_$fileNameEndDate-DB2_AGGREGATED_MIGRATED_DRAW_AMOUNTS_BY_TIER_unix-*
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
