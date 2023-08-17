#!/bin/bash
# The following three lines have been added by UDB DB2.
#to run this file use command: sh run.sh "KY(RI)"
# for bulk export use: sh file_generation.sh "" "2023-01-01 00:00:00.000000"
# for go-life run: sh file_generation.sh.sh "2023-01-01 00:00:00.000000" ""
# !!! Use current date to export !!!
#set variable
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
echo "RESULTS KPIS"
echo "---------------------------"
db2 export to kpis_all_validations.csv OF DEL MODIFIED BY NOCHARDEL  "
    SELECT
        'RESULT.All validations' as name,
        count(*) from TXSTORE.MIGRATED_TX_TRANSACTION MTX
                       WHERE MTX.TRANSACTION_TYPE = 'VALIDATION'"
db2 export to kpis_migrated_results.csv OF DEL MODIFIED BY NOCHARDEL  "
    SELECT
        'RESULT.Migrated results' as name,
         count(*) from (select distinct (LOTTERY_TX_HEADER_ID) from TXSTORE.MIGRATED_RESULTS)"
db2 export to kpis_Wagers_without_draw_id.csv OF DEL MODIFIED BY NOCHARDEL  "
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
db2 export to kpis_VALIDATIONs_without_WAGERs.csv OF DEL MODIFIED BY NOCHARDEL  "
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

db2 export to kpis_wagers_before_first_day_of_run.csv OF DEL MODIFIED BY NOCHARDEL  "
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

###########################
db2 terminate
###########################
cat "kpi_HEADER.csv" kpis_*.csv > "kpi.csv"
rm -f "kpi_HEADER.csv"
rm -f kpis_*.csv