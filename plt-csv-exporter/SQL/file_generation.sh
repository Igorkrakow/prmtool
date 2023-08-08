#!/bin/bash
# The following three lines have been added by UDB DB2.
#to run this file use command: sh run.sh "KY(RI)"
# for bulk export use: sh file_generation.sh "" "2023-01-01 00:00:00.000000"
# for go-life run: sh file_generation.sh.sh "2023-01-01 00:00:00.000000" ""
# !!! Use current date to export !!!
#set variable
num_rows=100000
fileNameEndDate=$(date -d "$1" +%Y%m%d)
db2 connect to pddb
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
        FROM
            TXSTORE.MIGRATED_TX_JSON"
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