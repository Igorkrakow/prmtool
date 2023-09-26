#!/bin/bash
# The following three lines have been added by UDB DB2.
# To run this file use command: sh TSO_GENERATION.sh "2023-01-01 00:00:00.000000" "2023-02-01 00:00:00.000000"
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


echo "------------ Start TSO PURCHASE GENERATION ------------" | tee -a $logfile

#####################
db2 connect to pddb
#####################

log_with_timestamp "TSO_PURCHASE_OPEN_TO_REFUND_DELTA procedure starting"
db2 "call TXSTORE.TSO_PURCHASE_OPEN_TO_REFUND_DELTA(START_TIME => '$start_date',END_TIME => '$end_date')"| tee -a $logfile
log_with_timestamp "TSO_PURCHASE_OPEN_TO_CLOSED_DELTA procedure starting"
db2 "call TXSTORE.TSO_PURCHASE_OPEN_TO_CLOSED_DELTA(START_TIME => '$start_date',END_TIME => '$end_date')"| tee -a $logfile
log_with_timestamp "TSO_PURCHASE_CLOSED procedure starting"
db2 "call TXSTORE.TSO_PURCHASE_CLOSED(START_TIME => '$start_date',END_TIME => '$end_date')"| tee -a $logfile
log_with_timestamp "TSO_PURCHASE_OPEN procedure starting"
db2 "call TXSTORE.TSO_PURCHASE_OPEN(START_TIME => '$start_date',END_TIME => '$end_date')"| tee -a $logfile

echo "------------ TSO PURCHASE GENERATION Finished------------" | tee -a $logfile

###############################################################################################################################
echo "------------ Start TSO PAYMENT GENERATION ------------" | tee -a $logfile

log_with_timestamp "TSO_PAYMENT_REFUND procedure starting"
db2 "call TTXSTORE.TSO_PAYMENT_REFUND(START_TIME => '$start_date',END_TIME => '$end_date')"| tee -a $logfile
log_with_timestamp "TSO_PAYMENT_VALIDATION procedure starting"
db2 "call  TXSTORE.TSO_PAYMENT_VALIDATION(START_TIME => '$start_date',END_TIME => '$end_date')"| tee -a $logfile

echo "------------ TSO PAYMENT GENERATION Finished------------" | tee -a $logfile


