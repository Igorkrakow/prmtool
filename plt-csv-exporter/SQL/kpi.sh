#!/bin/bash
# The following three lines have been added by UDB DB2.
#to run this file use command: sh run.sh "KY(RI)"
# for bulk export use: sh file_generation.sh "" "2023-01-01 00:00:00.000000"
# for go-life run: sh file_generation.sh.sh "2023-01-01 00:00:00.000000" ""
# !!! Use current date to export !!!
#set variable
logfile="scriptlog.log"

min_id_from_first_run=100000
project=$1
max_id_from_current_run=$2
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

db2 connect to PDDB
db2 export to kpi_HEADER.csv OF DEL MODIFIED BY NOCHARDEL  "
    SELECT
        'name',
        'value'
    FROM sysibm.sysdummy1"

echo "---------------------------"
echo "TRANSACTION KPIS"
echo "---------------------------"

db2 export to kpis_transactions_1all_.csv OF DEL MODIFIED BY NOCHARDEL  "
    SELECT
        'TRANSACTION. all transactions on db' as name,
        count(*) from TXSTORE.MIGR_TX_HEADER"

db2 export to kpis_transactions_2all_by_types.csv OF DEL MODIFIED BY NOCHARDEL  "
    SELECT
        'TRANSACTION. all transactions. '||LOTTERY_TRANSACTION_TYPE,
        count(*) FROM TXSTORE.MIGR_TX_HEADER MTH
        JOIN TXSTORE.LOTTERY_TX_HEADER LTH ON MTH.TX_HEADER_ID = LTH.LOTTERY_TX_HEADER_ID
        GROUP BY LOTTERY_TRANSACTION_TYPE"
db2 export to kpis_transactions_3closed.csv OF DEL MODIFIED BY NOCHARDEL  "
    SELECT
        'TRANSACTION. closed transactions (migrated)' as name,
        count(*) from TXSTORE.MIGRATED_TX_TRANSACTION"
db2 export to kpis_transactions_4closed_by_types.csv OF DEL MODIFIED BY NOCHARDEL  "
    SELECT
        'TRANSACTION. closed transactions. '||TRANSACTION_TYPE,
        count(*)
        from TXSTORE.MIGRATED_TX_TRANSACTION
             group by TRANSACTION_TYPE"
db2 export to kpis_transactions_5open.csv OF DEL MODIFIED BY NOCHARDEL  "
    SELECT
        'TRANSACTION. open transactions (not migrated yet)' as name,
        count(*) from TXSTORE.MIGR_OPEN_TX_HEADER"
db2 export to kpis_transactions_6open_by_types.csv OF DEL MODIFIED BY NOCHARDEL  "
    SELECT
        'TRANSACTION. open transactions. '||LOTTERY_TRANSACTION_TYPE,count(*)
        FROM TXSTORE.MIGR_OPEN_TX_HEADER MTH
        JOIN TXSTORE.LOTTERY_TX_HEADER LTH ON MTH.TX_HEADER_ID = LTH.LOTTERY_TX_HEADER_ID
        GROUP BY LOTTERY_TRANSACTION_TYPE"

echo "---------------------------"
echo "RESULTS KPIS"
echo "---------------------------"
db2 export to kpis_results_1all_validations.csv OF DEL MODIFIED BY NOCHARDEL  "
    SELECT
        'RESULT.All validations' as name,
        count(*) from TXSTORE.MIGRATED_TX_TRANSACTION MTX
                       WHERE MTX.TRANSACTION_TYPE = 'VALIDATION'"
db2 export to kpis_results_2migrated.csv OF DEL MODIFIED BY NOCHARDEL  "
    SELECT
        'RESULT.Migrated results' as name,
         count(*) from (select distinct (LOTTERY_TX_HEADER_ID) from TXSTORE.MIGRATED_RESULTS)"
db2 export to kpis_results_3Wagers_without_draw_id.csv OF DEL MODIFIED BY NOCHARDEL  "
    SELECT
        'RESULT.Validations for dirty WAGERS(without start-end draw id)' as name,
        count(DISTINCT TX_TRANSACTION_ID) FROM
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
             where t.TRANSACTION_TYPE = 'WAGER' and t.START_DRAW_NUMBER is null
             )"
db2 export to kpis_results_4VALIDATIONs_without_WAGERs.csv OF DEL MODIFIED BY NOCHARDEL  "
    SELECT
        'RESULT.VALIDATIONs without WAGERs' as name,
        count(*)
    FROM TXSTORE.MIGRATED_TX_TRANSACTION LTV
        WHERE LTV.TRANSACTION_TYPE='VALIDATION' and
              LTV.TX_TRANSACTION_ID not in (
                    SELECT tv.TX_TRANSACTION_ID
                    FROM TXSTORE.MIGRATED_TX_TRANSACTION as tv
                             JOIN TXSTORE.LOTTERY_TX_HEADER LTW
                                 ON tv.SERIAL = LTW.SERIAL
                                 and tv.CDC = LTW.CDC
                                 AND LTW.LOTTERY_TRANSACTION_TYPE = 'WAGER'
                            WHERE tv.TRANSACTION_TYPE='VALIDATION'
                    UNION ALL
                    SELECT tv.TX_TRANSACTION_ID
                    FROM TXSTORE.MIGRATED_TX_TRANSACTION as tv
                             JOIN TXSTORE.LOTTERY_TX_HEADER LTW
                                  ON tv.GLOBAL_TRANS_ID = LTW.GLOBAL_TRANS_ID
                                  and tv.SERIAL = LTW.SERIAL
                                  AND LTW.LOTTERY_TRANSACTION_TYPE = 'WAGER'
                    WHERE tv.TRANSACTION_TYPE='VALIDATION')"

db2 export to kpis_results_5wagers_before_first_day_of_run.csv OF DEL MODIFIED BY NOCHARDEL  "
    SELECT
        'RESULT.Wagers before first day of run' as name,
        SUM(Count) AS TotalCount
    FROM (   SELECT COUNT(*) AS Count
             FROM TXSTORE.LOTTERY_TX_HEADER LTH
                      JOIN TXSTORE.TX_HEADER TH ON LTH.LOTTERY_TX_HEADER_ID = TH.TX_HEADER_ID
                      JOIN (SELECT LTH.GLOBAL_TRANS_ID, LTH.SERIAL, LTH.CDC
                                FROM TXSTORE.MIGRATED_TX_TRANSACTION MTH
                                JOIN TXSTORE.LOTTERY_TX_HEADER LTH
                                    ON MTH.TX_TRANSACTION_ID = LTH.LOTTERY_TX_HEADER_ID
                                WHERE LTH.LOTTERY_TRANSACTION_TYPE = 'VALIDATION'
                                  AND LTH.LOTTERY_TX_HEADER_ID NOT IN (SELECT LOTTERY_TX_HEADER_ID
                                                                        FROM TXSTORE.MIGRATED_RESULTS)
                            ) INSEL ON LTH.GLOBAL_TRANS_ID = INSEL.GLOBAL_TRANS_ID
                                    AND LTH.SERIAL = INSEL.SERIAL
             WHERE LTH.LOTTERY_TRANSACTION_TYPE = 'WAGER'
                AND (TH.TX_HEADER_ID<$min_id_from_first_run -- min id from first run
                    or TH.TX_HEADER_ID> $max_id_from_current_run)
             UNION ALL
             SELECT COUNT(*) AS Count
             FROM TXSTORE.LOTTERY_TX_HEADER LTH
                      JOIN TXSTORE.TX_HEADER TH ON LTH.LOTTERY_TX_HEADER_ID = TH.TX_HEADER_ID
                      JOIN (SELECT LTH.GLOBAL_TRANS_ID, LTH.SERIAL, LTH.CDC
                             FROM TXSTORE.MIGRATED_TX_TRANSACTION MTH
                             JOIN TXSTORE.LOTTERY_TX_HEADER LTH
                                 ON MTH.TX_TRANSACTION_ID = LTH.LOTTERY_TX_HEADER_ID
                             WHERE LTH.LOTTERY_TRANSACTION_TYPE = 'VALIDATION'
                               AND LTH.LOTTERY_TX_HEADER_ID NOT IN (SELECT LOTTERY_TX_HEADER_ID
                                                                    FROM TXSTORE.MIGRATED_RESULTS)
                            ) INSEL ON LTH.CDC = INSEL.CDC AND LTH.SERIAL = INSEL.SERIAL
             WHERE LTH.LOTTERY_TRANSACTION_TYPE = 'WAGER'
               AND (TH.TX_HEADER_ID<$min_id_from_first_run
                 or TH.TX_HEADER_ID> $max_id_from_current_run) --max_id_from_current_run
               AND TH.TX_HEADER_ID not in (
                                         SELECT LTH.LOTTERY_TX_HEADER_ID AS Count
                                         FROM TXSTORE.LOTTERY_TX_HEADER LTH
                                                  JOIN TXSTORE.TX_HEADER TH ON LTH.LOTTERY_TX_HEADER_ID = TH.TX_HEADER_ID
                                                  JOIN (SELECT LTH.GLOBAL_TRANS_ID, LTH.SERIAL, LTH.CDC
                                                        FROM TXSTORE.MIGRATED_TX_TRANSACTION MTH
                                                                 JOIN TXSTORE.LOTTERY_TX_HEADER LTH
                                                                      ON MTH.TX_TRANSACTION_ID = LTH.LOTTERY_TX_HEADER_ID
                                                        WHERE LTH.LOTTERY_TRANSACTION_TYPE = 'VALIDATION'
                                                          AND LTH.LOTTERY_TX_HEADER_ID NOT IN (SELECT LOTTERY_TX_HEADER_ID
                                                                                               FROM TXSTORE.MIGRATED_RESULTS)
                                         ) INSEL ON LTH.GLOBAL_TRANS_ID = INSEL.GLOBAL_TRANS_ID
                                             AND LTH.SERIAL = INSEL.SERIAL
                                         WHERE LTH.LOTTERY_TRANSACTION_TYPE = 'WAGER'
                                           AND (TH.TX_HEADER_ID<$min_id_from_first_run
                                             or TH.TX_HEADER_ID> $max_id_from_current_run)
             )
         ) AS SubQuery"

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

db2 export to kpis_draw_4entry_wining_not_winung.csv OF DEL MODIFIED BY NOCHARDEL  "
    SELECT
        'DRAWS. all draws' ,
        count(*)
        FROM GIS.DGGAMEEVENT E"

###########################
db2 terminate
###########################
cat "kpi_HEADER.csv" kpis_transactions_*.csv kpis_results_*.csv kpis_draw_*.csv> "kpi.csv"
rm -f "kpi_HEADER.csv"
rm -f kpis_*.csv