#!/bin/bash
# To run this file use command: sh TXSTORE_creation.sh "KY(RI)"
# Declare log file
logfile="scriptlog.log"
echo "" | tee -a $logfile
echo "------------ Start creation ------------" | tee -a $logfile
log_with_timestamp() {
  local current_timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo "" | tee -a $logfile
  echo "$current_timestamp - $1" | tee -a $logfile
}
project=$1
if [ "$project" = "KY" ]; then
	project_condition="D.PRODUCT NOT IN (30,35) AND "
elif [ "$project" = "RI" ]; then
  project_condition="D.PRODUCT IN (15) AND "
else
  echo "Project with name $project - not exist"
  exit 1
fi
#--:::::::::::::::::::::::::::::::TXSTORE:::::::::::::::::::::::::::
start_truncate="BEGIN DECLARE CONTINUE HANDLER FOR SQLSTATE '42704' BEGIN END; EXECUTE IMMEDIATE '"
end="';END"

##########    Create TMP table MIGRATED_TX_TRANSACTION   ###########

#####################
db2 connect to pddb
#####################

echo "Do you want to drop all temp tables before run create(all data from MIGRATED_TX_DRAW_ENTRY, MIGR_OPEN_TX_HEADER, MIGRATED_RESULTS, MIGR_TX_HEADER, MIGRATED_TX_JSON, MIGRATED_TX_TRANSACTION)? [Y/N]"
read -r response
if [[ "$response" == "Y" ]] || [[ "$response" == "y" ]]; then
  log_with_timestamp "Truncate temp tables"
  db2 "$start_truncate TRUNCATE TABLE TXSTORE.MIGRATED_RESULTS IMMEDIATE $end"| tee -a $logfile
  db2 "$start_truncate TRUNCATE TABLE TXSTORE.MIGRATED_TX_DRAW_ENTRY IMMEDIATE $end"| tee -a $logfile
  db2 "$start_truncate TRUNCATE TABLE TXSTORE.MIGR_TX_HEADER IMMEDIATE $end"| tee -a $logfile
  db2 "$start_truncate TRUNCATE TABLE TXSTORE.MIGRATED_TX_JSON IMMEDIATE $end"| tee -a $logfile
  db2 "$start_truncate TRUNCATE TABLE TXSTORE.MIGRATED_TX_TRANSACTION IMMEDIATE $end"| tee -a $logfile
  db2 "$start_truncate TRUNCATE TABLE TXSTORE.MIGR_OPEN_TX_HEADER IMMEDIATE $end"| tee -a $logfile
  db2 "$start_truncate TRUNCATE TABLE TXSTORE.MIGRATED_TX_DRAWS IMMEDIATE $end"| tee -a $logfile
  db2 "$start_truncate TRUNCATE TABLE TXSTORE.MIGRATION_ERRORS IMMEDIATE $end"| tee -a $logfile
  log_with_timestamp "Drop temp tables"
  db2 "$start_truncate DROP TABLE TXSTORE.MIGRATED_TX_DRAW_ENTRY $end"| tee -a $logfile
  db2 "$start_truncate DROP TABLE TXSTORE.MIGRATED_RESULTS $end"| tee -a $logfile
  db2 "$start_truncate DROP TABLE TXSTORE.MIGR_TX_HEADER $end"| tee -a $logfile
  db2 "$start_truncate DROP TABLE TXSTORE.MIGRATED_TX_JSON $end"| tee -a $logfile
  db2 "$start_truncate DROP TABLE TXSTORE.MIGRATED_TX_TRANSACTION $end"| tee -a $logfile
  db2 "$start_truncate DROP TABLE TXSTORE.MIGR_OPEN_TX_HEADER $end"| tee -a $logfile
  db2 "$start_truncate DROP INDEX TXSTORE.MIGRATED_TX_TRANSACTION_TX_TRANSACTION_ID $end"| tee -a $logfile
  db2 "$start_truncate DROP INDEX TXSTORE.UQIDXMIGR_OPEN_TX_HEADER $end"| tee -a $logfile
  db2 "$start_truncate DROP INDEX TXSTORE.XIDXMIGR_OPEN_TX_HEADERPLAYERID $end"| tee -a $logfile
  db2 "$start_truncate DROP INDEX TXSTORE.UQIDXMIGR_TX_HEADER $end"| tee -a $logfile
  db2 "$start_truncate DROP INDEX TXSTORE.XIDXMIGR_TX_HEADERPLAYERID $end"| tee -a $logfile
  db2 "$start_truncate DROP INDEX TXSTORE.IDXMIGRATED_TX_DRAW_ENTRY $end"| tee -a $logfile
  db2 "$start_truncate DROP TABLE TXSTORE.MIGRATED_TX_DRAWS $end"| tee -a $logfile
  db2 "$start_truncate DROP TABLE TXSTORE.MIGRATION_ERRORS $end"| tee -a $logfile
fi

###   Create TMP table MIGRATED_TX_TRANSACTION  ####
log_with_timestamp "CREATE TABLE MIGRATED_TX_TRANSACTION"
db2 -td@ -f SQL/CREATE/create_migrated_tx_transaction.sql | tee -a $logfile

###   Create TMP table MIGR_TX_HEADER  ####
log_with_timestamp "CREATE TABLE MIGR_TX_HEADER"
db2 -td@ -f SQL/CREATE/create_migrated_tx_header.sql | tee -a $logfile

###   Create TMP table MIGRATION_ERRORS  ####
log_with_timestamp "CREATE TABLE MIGRATION_ERRORS"
db2 -td@ -f SQL/CREATE/create_migration_errors.sql | tee -a $logfile

###   Create VIEW  MIGR_OPEN_TX_HEADER  ####
log_with_timestamp "CREATE TABLE MIGR_OPEN_TX_HEADER"
db2 -td@ -f SQL/CREATE/create_migrated_open_tx_header.sql | tee -a $logfile

###   Create VIEW  VIEW_MIGRATED_TX  ####
log_with_timestamp "CREATE VIEW VIEW_MIGRATED_TX"
db2 -td@ -f SQL/CREATE/create_view_migrated_tx.sql | tee -a $logfile

###   Create TABLE  MIGRATED_TX_DRAWS  ####
log_with_timestamp "CREATE TABLE MIGRATED_TX_DRAWS"
db2 -td@ -f SQL/CREATE/create_migrated_tx_draws.sql | tee -a $logfile

###   Create TABLE  MIGRATED_TX_DRAW_ENTRY  ####
log_with_timestamp "CREATE TABLE MIGRATED_TX_DRAW_ENTRY"
db2 -td@ -f SQL/CREATE/create_migrated_tx_draw_entry.sql | tee -a $logfile

###   CREATE AND REORG INDEX LOTTERY_TX_HEADER  (GLOBAL_TRANS_ID,START_DRAW_NUMBER,LOTTERY_TRANSACTION_TYPE) ###########
log_with_timestamp "CREATE AND REORG INDEX LOTTERY_TX_HEADER (GLOBAL_TRANS_ID,START_DRAW_NUMBER,LOTTERY_TRANSACTION_TYPE)"
db2 -td@ -f SQL/CREATE/create_index_on_lottery_tx_header.sql | tee -a $logfile

###   CREATE PROCEDURE INSERT_INTO_MIGRATED_TX_DRAW_ENTRY ###########
sed "s/{PROJECT_CONDITION}/$project_condition/g" SQL/CREATE/create_procedure_for_insert_into_migrated_tx_draw_entry.sql > SQL/CREATE/create_procedure_for_insert_into_migrated_tx_draw_entry_tmp.sql
log_with_timestamp "CREATE PROCEDURE INSERT_INTO_MIGRATED_TX_DRAW_ENTRY"
db2 -td@ -f SQL/CREATE/create_procedure_for_insert_into_migrated_tx_draw_entry_tmp.sql | tee -a $logfile
rm SQL/CREATE/create_procedure_for_insert_into_migrated_tx_draw_entry_tmp.sql

###   Create VIEW  MIGRATED_TX_DRAW   ###########
log_with_timestamp "CREATE VIEW MIGRATED_TX_DRAW"
db2 -td@ -f SQL/CREATE/create_view_migrated_tx_draw.sql | tee -a $logfile

####   CREATE TABLE MIGRATED_RESULTS   ###########
log_with_timestamp "CREATE TABLE MIGRATED_RESULTS"
db2 -td@ -f SQL/CREATE/create_migrated_results.sql| tee -a $logfile

###   CREATE TABLE MIGRATED_TX_JSON   ###########
log_with_timestamp "CREATE TABLE MIGRATED_TX_JSON"
db2 -td@ -f SQL/CREATE/create_migrated_tx_json.sql | tee -a $logfile

###   CREATE PROCEDURE to handle primarry/secondary board-data ###########
log_with_timestamp "CREATE PROCEDURE to handle primarry/secondary board-data"
db2 -td@ -f SQL/CREATE/create_or_replace_procedure_txstore.handle_part.sql | tee -a $logfile

###   CREATE PROCEDURE RemoveXmlns ###########
log_with_timestamp "CREATE PROCEDURE RemoveXmlns"
db2 -td@ -f SQL/CREATE/create_procedure_removexmlns.sql | tee -a $logfile

###   CREATE PROCEDURE TX_TRANSACTION_JSON_EXPORT ###########
log_with_timestamp "CREATE PROCEDURE TX_TRANSACTION_JSON_EXPORT"
db2 -td@ -f SQL/CREATE/create_procedure_tx_transaction_json_export.sql | tee -a $logfile

echo "" | tee -a $logfile
echo "------------ END creation ------------" | tee -a $logfile