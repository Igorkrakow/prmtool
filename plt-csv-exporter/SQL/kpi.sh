#!/bin/bash
# The following three lines have been added by UDB DB2.
#to run this file use command: sh run.sh "KY(RI)"
# for bulk export use: sh file_generation.sh "" "2023-01-01 00:00:00.000000"
# for go-life run: sh file_generation.sh.sh "2023-01-01 00:00:00.000000" ""
# !!! Use current date to export !!!
#set variable
logfile="scriptlog.log"

project=$1
min_id_from_current_run=$2
max_id_from_current_run=$3
if [ "$project" = "KY" ]; then
	project_condition="PRODUCT NOT IN (30,35) "
elif [ "$project" = "RI" ]; then
  project_condition="PRODUCT IN (15) "
else
  echo "Project with name $project - not exist"
  exit 1
fi
log_with_timestamp() {
  local current_timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo "" | tee -a $logfile
  echo "$current_timestamp - $1" | tee -a $logfile
}
#start_insert="BEGIN DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' BEGIN END; EXECUTE IMMEDIATE '"
#end="';END"

db2 connect to PDDB

#min_id_from_first_run=100000
min_id_from_first_run=$(db2 -x "SELECT TX_HEADER_ID FROM TXSTORE.TX_HEADER where uuid = (SELECT UUID FROM TXSTORE.MIGRATED_TX_DRAW_ENTRY FETCH FIRST 1 ROW ONLY)")
if (( $min_id_from_first_run < $min_id_from_current_run )); then
    min="$min_id_from_first_run"
else
    min="$min_id_from_current_run"
fi

db2 export to kpi_HEADER.csv OF DEL MODIFIED BY NOCHARDEL  "
    SELECT
        'name',
        'value'
    FROM sysibm.sysdummy1"

echo "---------------------------"
echo "TRANSACTION KPIS"
echo "---------------------------"

log_with_timestamp "Counting TRANSACTION. all transactions on db' as name"
echo "Counting TRANSACTION. all transactions on db' as name"
db2 export to kpis_transactions_1all_.csv OF DEL MODIFIED BY NOCHARDEL  "
    SELECT
        'TRANSACTION. all transactions on db' as name,
        count(*) from TXSTORE.MIGR_TX_HEADER"

log_with_timestamp "Counting TRANSACTION. all transactions by type' as name"
echo "Counting TRANSACTION. all transactions by type' as name"
db2 export to kpis_transactions_2all_by_types.csv OF DEL MODIFIED BY NOCHARDEL  "
    SELECT
        'TRANSACTION. all transactions. '||LOTTERY_TRANSACTION_TYPE,
        count(*) FROM TXSTORE.MIGR_TX_HEADER MTH
        JOIN TXSTORE.LOTTERY_TX_HEADER LTH ON MTH.TX_HEADER_ID = LTH.LOTTERY_TX_HEADER_ID
        GROUP BY LOTTERY_TRANSACTION_TYPE"

log_with_timestamp "Counting TRANSACTION. all transactions (migrated)' as name"
echo "Counting TRANSACTION. all transactions (migrated)' as name"
db2 export to kpis_transactions_3closed.csv OF DEL MODIFIED BY NOCHARDEL  "
    SELECT
        'TRANSACTION. closed transactions (migrated)' as name,
        count(*) from TXSTORE.MIGRATED_TX_TRANSACTION"

log_with_timestamp "Counting TRANSACTION. closed transactions"
echo "Counting TTRANSACTION. closed transactions"
db2 export to kpis_transactions_4closed_by_types.csv OF DEL MODIFIED BY NOCHARDEL  "
    SELECT
        'TRANSACTION. closed transactions. '||TRANSACTION_TYPE,
        count(*)
        from TXSTORE.MIGRATED_TX_TRANSACTION
             group by TRANSACTION_TYPE"

log_with_timestamp "Counting open transactions (not migrated yet)"
echo "Counting open transactions (not migrated yet)"
db2 export to kpis_transactions_5open.csv OF DEL MODIFIED BY NOCHARDEL  "
    SELECT
        'TRANSACTION. open transactions (not migrated yet)' as name,
        count(*) from TXSTORE.MIGR_OPEN_TX_HEADER"

log_with_timestamp "Counting open transactions by type"
echo "Counting open transactions by type"
db2 export to kpis_transactions_6open_by_types.csv OF DEL MODIFIED BY NOCHARDEL  "
    SELECT
        'TRANSACTION. open transactions. '||LOTTERY_TRANSACTION_TYPE,count(*)
        FROM TXSTORE.MIGR_OPEN_TX_HEADER MTH
        JOIN TXSTORE.LOTTERY_TX_HEADER LTH ON MTH.TX_HEADER_ID = LTH.LOTTERY_TX_HEADER_ID
        GROUP BY LOTTERY_TRANSACTION_TYPE"

echo "---------------------------"
echo "RESULTS KPIS"
echo "---------------------------"

log_with_timestamp "Counting RESULT.All validations"
echo "Counting RESULT.All validations"
db2 export to kpis_results_1all_validations.csv OF DEL MODIFIED BY NOCHARDEL  "
    SELECT
        'RESULT.All validations' as name,
        count(*) from TXSTORE.MIGRATED_TX_TRANSACTION MTX
                       WHERE MTX.TRANSACTION_TYPE = 'VALIDATION'"

log_with_timestamp "Counting RESULT.Migrated results"
echo "Counting RESULT.Migrated results"
db2 export to kpis_results_2migrated.csv OF DEL MODIFIED BY NOCHARDEL  "
    SELECT
        'RESULT.Migrated results' as name,
         count(*) from (select distinct (LOTTERY_TX_HEADER_ID) from TXSTORE.MIGRATED_RESULTS)"

############## insert into MIGRATION ERRORS ##############

log_with_timestamp "Counting RESULT.Validations for dirty WAGERS(without start-end draw id)"
echo "Counting RESULT.Validations for dirty WAGERS(without start-end draw id)"
db2 "INSERT INTO TXSTORE.MIGRATION_ERRORS (TABLE_NAME, ID, STATUS)
        SELECT
            'MIGRATED_RESULTS',
            TX_TRANSACTION_ID,
            'RESULT.Validations for dirty WAGERS(without start-end draw id)' as name
        FROM
            (SELECT MTV.TX_TRANSACTION_ID FROM TXSTORE.MIGRATED_TX_TRANSACTION t
                    join TXSTORE.MIGRATED_TX_TRANSACTION MTV on MTV.GLOBAL_TRANS_ID=t.GLOBAL_TRANS_ID
                and MTV.SERIAL=t.SERIAL
                and MTV.TRANSACTION_TYPE='VALIDATION'
             where t.TRANSACTION_TYPE = 'WAGER' and t.START_DRAW_NUMBER is null
             UNION ALL
             SELECT MTV.TX_TRANSACTION_ID FROM TXSTORE.MIGRATED_TX_TRANSACTION t
                    join TXSTORE.MIGRATED_TX_TRANSACTION MTV on MTV.CDC=t.CDC
                and MTV.SERIAL=t.SERIAL
                and MTV.TRANSACTION_TYPE='VALIDATION'
                and MTV.PLAYER_ID =t.PLAYER_ID
             where t.TRANSACTION_TYPE = 'WAGER' and t.START_DRAW_NUMBER is null
               and MTV.GLOBAL_TRANS_ID != t.GLOBAL_TRANS_ID)" | tee -a $logfile

log_with_timestamp "Counting Result validation with wagers_before_first_day_of_run with min $min and max $max_id_from_current_run"
echo "Counting Result validation with wagers_before_first_day_of_run with min $min and max $max_id_from_current_run"
db2 "INSERT INTO TXSTORE.MIGRATION_ERRORS (TABLE_NAME, ID, STATUS)
        SELECT 'MIGRATED_RESULTS',
               MTTV.TX_TRANSACTION_ID,
               'Result validation with wagers_before_first_day_of_run'
        FROM TXSTORE.MIGRATED_TX_TRANSACTION MTTV
                 JOIN (
                        SELECT W.LOTTERY_TX_HEADER_ID, W.GLOBAL_TRANS_ID, W.SERIAL, W.CDC,W.PLAYER_ID
                        FROM (
                                 SELECT LTH.LOTTERY_TX_HEADER_ID, LTH.GLOBAL_TRANS_ID, LTH.SERIAL, LTH.CDC,TH.PLAYER_ID
                                 FROM TXSTORE.LOTTERY_TX_HEADER LTH
                                          JOIN TXSTORE.TX_HEADER TH ON LTH.LOTTERY_TX_HEADER_ID = TH.TX_HEADER_ID
                                 WHERE LTH.LOTTERY_TRANSACTION_TYPE = 'WAGER'
                                   AND (TH.TX_HEADER_ID < $min OR TH.TX_HEADER_ID > $max_id_from_current_run)
                             ) W
                                 JOIN (
                                SELECT MTH.GLOBAL_TRANS_ID, MTH.SERIAL, MTH.CDC,MTH.PLAYER_ID
                                FROM TXSTORE.MIGRATED_TX_TRANSACTION MTH
                                WHERE MTH.TRANSACTION_TYPE = 'VALIDATION'
                                  AND MTH.TX_TRANSACTION_ID NOT IN (SELECT LOTTERY_TX_HEADER_ID FROM TXSTORE.MIGRATED_RESULTS)
                            ) V
                            ON (W.GLOBAL_TRANS_ID = V.GLOBAL_TRANS_ID AND W.SERIAL = V.SERIAL)
                                OR (W.CDC = V.CDC AND W.SERIAL = V.SERIAL and W.GLOBAL_TRANS_ID != V.GLOBAL_TRANS_ID and W.PLAYER_ID=V.PLAYER_ID)
                    ) R
                ON (MTTV.GLOBAL_TRANS_ID = R.GLOBAL_TRANS_ID AND MTTV.SERIAL = R.SERIAL)
            OR(MTTV.CDC = R.CDC AND MTTV.SERIAL = R.SERIAL AND MTTV.GLOBAL_TRANS_ID != R.GLOBAL_TRANS_ID and MTTV.PLAYER_ID=R.PLAYER_ID)
        WHERE MTTV.TRANSACTION_TYPE = 'VALIDATION'" | tee -a $logfile

log_with_timestamp "Counting RESULT.VALIDATIONs without WAGERs"
echo "Counting RESULT.VALIDATIONs without WAGERs"
db2 "INSERT INTO TXSTORE.MIGRATION_ERRORS (TABLE_NAME, ID, STATUS)
        SELECT
                'MIGRATED_RESULTS',
                LTV.TX_TRANSACTION_ID,
                'RESULT.VALIDATIONs without WAGERs'
        FROM TXSTORE.MIGRATED_TX_TRANSACTION LTV
        WHERE LTV.TRANSACTION_TYPE='VALIDATION'
          AND LTV.TX_TRANSACTION_ID NOT IN (
            SELECT tv.TX_TRANSACTION_ID
                FROM TXSTORE.MIGRATED_TX_TRANSACTION as tv
                         JOIN TXSTORE.LOTTERY_TX_HEADER LTW ON (
                        (tv.SERIAL = LTW.SERIAL AND tv.CDC = LTW.CDC and tv.GLOBAL_TRANS_ID != LTW.GLOBAL_TRANS_ID) OR
                        (tv.GLOBAL_TRANS_ID = LTW.GLOBAL_TRANS_ID AND tv.SERIAL = LTW.SERIAL)
                    )
                    JOIN TXSTORE.TX_HEADER as thw on ltw.LOTTERY_TX_HEADER_ID=thw.TX_HEADER_ID
                WHERE tv.TRANSACTION_TYPE='VALIDATION' AND LTW.LOTTERY_TRANSACTION_TYPE = 'WAGER'
                and thw.PLAYER_ID=tv.PLAYER_ID
        )" | tee -a $logfile

log_with_timestamp "Counting VALIDATION LINKED TO WAGER WITH DIFFERENT DRAW NUMBERS"
echo "Counting VALIDATION LINKED TO WAGER WITH DIFFERENT DRAW NUMBERS"
db2 "INSERT INTO TXSTORE.MIGRATION_ERRORS (TABLE_NAME, ID, STATUS)
        SELECT 'MIGRATED_RESULTS',
               V.TX_TRANSACTION_ID,
               'VALIDATION LINKED TO WAGER WITH DIFFERENT DRAW NUMBERS'
        FROM (
                 SELECT LTH.GLOBAL_TRANS_ID, LTH.SERIAL, LTH.CDC,LTH.START_DRAW_NUMBER,LTH.END_DRAW_NUMBER,TH.PLAYER_ID
                 FROM TXSTORE.MIGRATED_TX_TRANSACTION LTH
                          JOIN TXSTORE.TX_HEADER TH ON LTH.TX_TRANSACTION_ID = TH.TX_HEADER_ID
                 WHERE LTH.TRANSACTION_TYPE = 'WAGER'
             ) as W
                 JOIN (
                    SELECT MTH.TX_TRANSACTION_ID, MTH.GLOBAL_TRANS_ID, MTH.SERIAL, MTH.CDC,MTH.START_DRAW_NUMBER,MTH.PLAYER_ID
                    FROM TXSTORE.MIGRATED_TX_TRANSACTION MTH
                    WHERE MTH.TRANSACTION_TYPE = 'VALIDATION'
                      AND MTH.TX_TRANSACTION_ID NOT IN (SELECT LOTTERY_TX_HEADER_ID FROM TXSTORE.MIGRATED_RESULTS)
            ) as V ON (W.GLOBAL_TRANS_ID = V.GLOBAL_TRANS_ID AND W.SERIAL = V.SERIAL)
            OR (W.CDC = V.CDC AND W.SERIAL = V.SERIAL and W.GLOBAL_TRANS_ID != V.GLOBAL_TRANS_ID and W.PLAYER_ID=V.PLAYER_ID)
        WHERE V.START_DRAW_NUMBER NOT BETWEEN W.START_DRAW_NUMBER and W.END_DRAW_NUMBER and v.TX_TRANSACTION_ID not in (
            SELECT ID FROM TXSTORE.MIGRATION_ERRORS
            )" | tee -a $logfile
db2 export to kpis_results_3_errors.csv OF DEL MODIFIED BY NOCHARDEL  "
    SELECT
        'RESULT. '|| e.STATUS,
        count(DISTINCT e.ID)
        FROM TXSTORE.MIGRATION_ERRORS  as e
        join TXSTORE.MIGRATED_TX_TRANSACTION as t on t.TX_TRANSACTION_ID=e.ID
        group by e.STATUS"

echo "---------------------------"
echo "DRAW ENTRY"
echo "---------------------------"

db2 export to kpis_draw_1entry_from_all_runs.csv OF DEL MODIFIED BY NOCHARDEL  "
    SELECT
        'DRAW ENTRY. Draw entry from all runs' as name,
        count(*) from TXSTORE.MIGRATED_TX_DRAW_ENTRY"

db2 export to kpis_draw_2entry_should_be.csv OF DEL MODIFIED BY NOCHARDEL  "
    SELECT
        'DRAW ENTRY. Draw entry should be' as name,
        sum(L.END_DRAW_NUMBER - L.START_DRAW_NUMBER +1)
        FROM
            TXSTORE.LOTTERY_TX_HEADER L
                INNER JOIN TXSTORE.MIGRATED_TX_TRANSACTION H
                           ON L.LOTTERY_TX_HEADER_ID = H.TX_TRANSACTION_ID
        WHERE L.PRODUCT NOT IN (30,35) AND L.LOTTERY_TRANSACTION_TYPE = 'WAGER'"

db2 export to kpis_draw_3entry_migrated.csv OF DEL MODIFIED BY NOCHARDEL  "
    SELECT
        'DRAW ENTRY. Draw entry migrated' as name,
        count(*) FROM TXSTORE.MIGRATED_TX_DRAW_ENTRY as DE
        join TXSTORE.MIGRATED_TX_TRANSACTION as t on DE.UUID=t.UUID"

db2 export to kpis_draw_4entry_by_types.csv OF DEL MODIFIED BY NOCHARDEL  "
    SELECT
        'DRAW ENTRY. draw entry by types. '||DE.WIN_STATUS ,
        count(*) FROM TXSTORE.MIGRATED_TX_DRAW_ENTRY as DE
        join TXSTORE.MIGRATED_TX_TRANSACTION as t on DE.UUID=t.UUID
        group by DE.WIN_STATUS"

echo "---------------------------"
echo "DRAW"
echo "---------------------------"

db2 export to kpis_draw_5.csv OF DEL MODIFIED BY NOCHARDEL  "
    SELECT
        'DRAWS. all draws' ,
        count(*)
        FROM TXSTORE.MIGRATED_TX_DRAWS"

###########################
db2 terminate
###########################
cat "kpi_HEADER.csv" kpis_transactions_*.csv kpis_results_*.csv kpis_draw_*.csv> "kpi.csv"
rm -f "kpi_HEADER.csv"
rm -f kpis_*.csv