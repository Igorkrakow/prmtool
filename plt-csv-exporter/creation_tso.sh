#!/bin/bash
logfile="scriptlog.log"
echo "" | tee -a $logfile
echo "------------ Start creation ------------" | tee -a $logfile
log_with_timestamp() {
  local current_timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo "" | tee -a $logfile
  echo "$current_timestamp - $1" | tee -a $logfile
}

#####################
db2 connect to pddb
#####################

##TRUNACATE
start_truncate="BEGIN DECLARE CONTINUE HANDLER FOR SQLSTATE '42704' BEGIN END; EXECUTE IMMEDIATE '"
end="';END"
echo "Do you want to drop all temp tables before run create? [Y/N]"
read -r response
if [[ "$response" == "Y" ]] || [[ "$response" == "y" ]]; then
  log_with_timestamp "Truncate temp tables"
  db2 "$start_truncate TRUNCATE TABLE TXSTORE.TMP_TSO_OPEN_PAYMENT_TRANSACTION IMMEDIATE $end"| tee -a $logfile
  db2 "$start_truncate TRUNCATE TABLE TXSTORE.TMP_TSO_OPEN_TRANSACTION IMMEDIATE $end"| tee -a $logfile
  db2 "$start_truncate TRUNCATE TABLE TXSTORE.TMP_TSO_PAYMENT IMMEDIATE $end"| tee -a $logfile
  db2 "$start_truncate TRUNCATE TABLE TXSTORE.TMP_TSO_PURCHASE IMMEDIATE $end"| tee -a $logfile
  db2 "$start_truncate TRUNCATE TABLE TXSTORE.TMP_TSO_ROUND_SESSION IMMEDIATE $end"| tee -a $logfile
  db2 "$start_truncate TRUNCATE TABLE TXSTORE.TMP_TSO_OPEN_RAUND_SESSION IMMEDIATE $end"| tee -a $logfile

  log_with_timestamp "Drop temp tables"
  db2 "$start_truncate DROP TABLE TXSTORE.TMP_TSO_OPEN_PAYMENT_TRANSACTION $end"| tee -a $logfile
  db2 "$start_truncate DROP TABLE TXSTORE.TMP_TSO_OPEN_TRANSACTION $end"| tee -a $logfile
  db2 "$start_truncate DROP TABLE TXSTORE.TMP_TSO_PAYMENT $end"| tee -a $logfile
  db2 "$start_truncate DROP TABLE TXSTORE.TMP_TSO_PURCHASE $end"| tee -a $logfile
  db2 "$start_truncate DROP TABLE TXSTORE.TMP_TSO_ROUND_SESSION $end"| tee -a $logfile
  db2 "$start_truncate DROP TABLE TXSTORE.TMP_TSO_OPEN_RAUND_SESSION $end"| tee -a $logfile
fi
###TABLES
###   Create TMP table CREATE_TMP_TSO_OPEN_PAYMENT_TRANSACTION  ####
log_with_timestamp "CREATE_TMP_TSO_OPEN_PAYMENT_TRANSACTION"
db2 -td@ -f TSO/SQL/CREATION/CREATE_TMP_TSO_OPEN_PAYMENT_TRANSACTION.SQL | tee -a $logfile

###   Create TMP table CREATE_TMP_TSO_OPEN_TRANSACTION  ####
log_with_timestamp "CREATE_TMP_TSO_OPEN_TRANSACTION"
db2 -td@ -f TSO/SQL/CREATION/CREATE_TMP_TSO_OPEN_TRANSACTION.SQL | tee -a $logfile

###   Create TMP table CREATE_TMP_TSO_PAYMENT  ####
log_with_timestamp "CREATE_TMP_TSO_PAYMENT"
db2 -td@ -f TSO/SQL/CREATION/CREATE_TMP_TSO_PAYMENT.SQL | tee -a $logfile

###   Create TMP table CREATE_TMP_TSO_PURCHASE.SQL  ####
log_with_timestamp "CREATE_TMP_TSO_PURCHASE"
db2 -td@ -f TSO/SQL/CREATION/CREATE_TMP_TSO_PURCHASE.SQL | tee -a $logfile

###   Create TMP table CREATE_TMP_TSO_ROUND_SESSION  ####
log_with_timestamp "CREATE_TMP_TSO_ROUND_SESSION"
db2 -td@ -f TSO/SQL/CREATION/CREATE_TMP_TSO_ROUND_SESSION.SQL | tee -a $logfile

###   Create TMP table CREATE_TMP_TSO_ROUND_SESSION_OPEN.SQL  ####
log_with_timestamp "CREATE_TMP_TSO_ROUND_SESSION_OPEN"
db2 -td@ -f TSO/SQL/CREATION/CREATE_TMP_TSO_ROUND_SESSION_OPEN.SQL | tee -a $logfile

###VIEWS
###   Create VIEW  CREATE_VIEW_CURRENT_DRAW  ####
log_with_timestamp "CREATE_VIEW_CURRENT_DRAW"
db2 -td@ -f TSO/SQL/CREATION/CREATE_VIEW_CURRENT_DRAW.SQL | tee -a $logfile

###PROCCEDURES PURCHASE
###   CREATE PROCEDURE TSO_PURCHASE_CLOSED ###########
log_with_timestamp "CREATE PROCEDURE TSO_PURCHASE_CLOSED"
db2 -td@ -f TSO/SQL/PROCEDURE/PURCHASE/TSO_PURCHASE_CLOSED.SQL | tee -a $logfile

###   CREATE PROCEDURE TSO_PURCHASE_OPEN_TO_CLOSED_DELTA ###########
log_with_timestamp "CREATE PROCEDURE TSO_PURCHASE_OPEN_TO_CLOSED_DELTA"
db2 -td@ -f TSO/SQL/PROCEDURE/PURCHASE/TSO_PURCHASE_OPEN_TO_CLOSED_DELTA.sql | tee -a $logfile

###   CREATE PROCEDURE TSO_PURCHASE_OPEN ###########
log_with_timestamp "CREATE PROCEDURE TSO_PURCHASE_OPEN"
db2 -td@ -f TSO/SQL/PROCEDURE/PURCHASE/TSO_PURCHASE_OPEN.SQL| tee -a $logfile

###PROCCEDURES PAYMENT
###   CREATE PROCEDURE TSO_PAYMENT_MD_CLOSED ###########
log_with_timestamp "CREATE PROCEDURE TSO_PAYMENT_MD_CLOSED"
db2 -td@ -f TSO/SQL/PROCEDURE/PAYMENT/TSO_PAYMENT_MD_CLOSED.SQL| tee -a $logfile

###   CREATE PROCEDURE TSO_PAYMENT_MD_OPEN ###########
log_with_timestamp "CREATE TSO_PAYMENT_MD_OPEN"
db2 -td@ -f TSO/SQL/PROCEDURE/PAYMENT/TSO_PAYMENT_MD_OPEN.SQL| tee -a $logfile

###   CREATE PROCEDURE TSO_PAYMENT_OPEN_MD_TO_CLOSED_DELTA ###########
log_with_timestamp "CREATE PROCEDURE TSO_PAYMENT_OPEN_MD_TO_CLOSED_DELTA"
db2 -td@ -f TSO/SQL/PROCEDURE/PAYMENT/TSO_PAYMENT_OPEN_MD_TO_CLOSED_DELTA.sql| tee -a $logfile

###   CREATE PROCEDURE TSO_PAYMENT_OPEN_SD_TO_CLOSED_DELTA ###########
log_with_timestamp "CREATE PROCEDURE TSO_PAYMENT_OPEN_SD_TO_CLOSED_DELTA"
db2 -td@ -f TSO/SQL/PROCEDURE/PAYMENT/TSO_PAYMENT_OPEN_SD_TO_CLOSED_DELTA.sql| tee -a $logfile

###   CREATE PROCEDURE TSO_PAYMENT_SD_CLOSED###########
log_with_timestamp "CREATE PROCEDURE TSO_PAYMENT_SD_CLOSED"
db2 -td@ -f TSO/SQL/PROCEDURE/PAYMENT/TSO_PAYMENT_SD_CLOSED.SQL| tee -a $logfile

###   CREATE PROCEDURE TSO_PAYMENT_SD_OPEN ###########
log_with_timestamp "CREATE PROCEDURE TSO_PAYMENT_SD_OPEN"
db2 -td@ -f TSO/SQL/PROCEDURE/PAYMENT/TSO_PAYMENT_SD_OPEN.SQL| tee -a $logfile
###PROCCEDURES ROUND_SESSION
###   CREATE PROCEDURE ROUND_SESSION_OPEN ###########
log_with_timestamp "CREATE PROCEDURE ROUND_SESSION_OPEN"
db2 -td@ -f TSO/SQL/PROCEDURE/ROUND_SESSION/ROUND_SESSION_OPEN.SQL| tee -a $logfile

###   CREATE PROCEDURE ROUND_SESSION_OPEN_TO_CLOSED_DELTA ###########
log_with_timestamp "CREATE PROCEDURE ROUND_SESSION_OPEN_TO_CLOSED_DELTA"
db2 -td@ -f TSO/SQL/PROCEDURE/ROUND_SESSION/ROUND_SESSION_OPEN_TO_CLOSED_DELTA.SQL| tee -a $logfile