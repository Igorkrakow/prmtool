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

start_table="BEGIN DECLARE CONTINUE HANDLER FOR SQLSTATE '42710' BEGIN END; EXECUTE IMMEDIATE '"
start_index="BEGIN DECLARE CONTINUE HANDLER FOR SQLSTATE '01550' BEGIN END; EXECUTE IMMEDIATE '"
end="';END"

##########    Create TMP table MIGRATED_TX_TRANSACTION   ###########

#####################
db2 connect to pddb
#####################
log_with_timestamp "CREATE TABLE MIGRATED_TX_TRANSACTION"
db2 "$start_table CREATE TABLE TXSTORE.MIGRATED_TX_TRANSACTION (
                            tx_transaction_id int NOT NULL,
                            global_trans_id varchar(50) NULL,
                            correlation_id varchar(60) NOT NULL,
                            uuid varchar(200) NOT NULL,
                            player_id int NOT NULL,
                            transaction_time timestamp NOT NULL,
                            transaction_type varchar(50) NOT NULL,
                            channel_id varchar(25) NULL,
                            system_id varchar(25) NULL,
                            transaction_amount bigint NULL,
                            transaction_discount_amount int NULL,
                            currency varchar(10) NULL,
                            serial int NULL,
                            cdc int NULL,
                            game_engine_transaction_time timestamp NULL,
                            product_id int NULL,
                            start_draw_number int NULL,
                            end_draw_number int NULL,
                            site_json_data varchar(100) NULL,
                            serial_number varchar(30) NULL,
                            winningDivision int NULL)
      $end" | tee -a $logfile

log_with_timestamp "CREATE INDEX MIGRATED_TX_TRANSACTION (TX_TRANSACTION_ID)"
db2 " $start_index
      CREATE INDEX TXSTORE.MIGRATED_TX_TRANSACTION_TX_TRANSACTION_ID
          on TXSTORE.MIGRATED_TX_TRANSACTION (TX_TRANSACTION_ID)
      $end" | tee -a $logfile

###   REORG INDEXES on LOTTERY_TX_HEADER ###########
log_with_timestamp "REORG INDEXES on MIGRATED_TX_TRANSACTIONR"
db2 "REORG INDEXES ALL FOR TABLE TXSTORE.MIGRATED_TX_TRANSACTION" | tee -a $logfile

###   Create TMP table MIGR_TX_HEADER  ####

log_with_timestamp "CREATE TABLE MIGR_TX_HEADER"
db2 "$start_table
      create table TXSTORE.MIGR_TX_HEADER(
          TX_HEADER_ID BIGINT not null constraint XPKMIGR_TX_HEADER primary key,
          PLAYER_ID    BIGINT not null,
          UUID         VARCHAR(200))
      $end" | tee -a $logfile

log_with_timestamp "CREATE TABLE MIGR_OPEN_TX_HEADER"
db2 "$start_table
      create table TXSTORE.MIGR_OPEN_TX_HEADER(
          TX_HEADER_ID BIGINT not null
                  constraint XPKMIGR_TX_HEADER
                      primary key,
              PLAYER_ID    BIGINT not null,
              UUID         VARCHAR(200),
              GLOBAL_TRANS_ID VARCHAR(50),
              CDC INTEGER,
              SERIAL BIGINT)
      $end" | tee -a $logfile

log_with_timestamp "CREATE INDEX MIGR_OPEN_TX_HEADER (UUID)"
db2 " $start_index
      create unique index TXSTORE.UQIDXMIGR_OPEN_TX_HEADER
          on TXSTORE.MIGR_OPEN_TX_HEADER (UUID)
      $end" | tee -a $logfile

log_with_timestamp "CREATE INDEX MIGR_OPEN_TX_HEADER (PLAYER_ID)"
db2 " $start_index
      create index TXSTORE.XIDXMIGR_OPEN_TX_HEADERPLAYERID
          on TXSTORE.MIGR_OPEN_TX_HEADER (PLAYER_ID)
      $end" | tee -a $logfile

log_with_timestamp "CREATE INDEX MIGR_TX_HEADER (UUID)"
db2 " $start_index
      create unique index TXSTORE.UQIDXMIGR_TX_HEADER
          on TXSTORE.MIGR_TX_HEADER (UUID)
      $end" | tee -a $logfile

log_with_timestamp "CREATE INDEX MIGR_TX_HEADER (PLAYER_ID)"
db2 " $start_index
      create index TXSTORE.XIDXMIGR_TX_HEADERPLAYERID
          on TXSTORE.MIGR_TX_HEADER (PLAYER_ID)
      $end" | tee -a $logfile

###   Create VIEW  VIEW_MIGRATED_TX  ####

log_with_timestamp "CREATE VIEW VIEW_MIGRATED_TX"
db2 "CREATE OR REPLACE VIEW TXSTORE.VIEW_MIGRATED_TX AS
      SELECT
        H.TX_HEADER_ID,
        L.GLOBAL_TRANS_ID,
        L.GLOBAL_TRANS_ID AS CORRELATION_ID,
        H.UUID,
        H.PLAYER_ID,
        L.TRANSACTION_TIME_UTC,
        L.LOTTERY_TRANSACTION_TYPE,
        L.TRANSACTION_AMOUNT,
        L.SERIAL,
        L.CDC,
        L.TRANSACTION_TIME_LOCAL,
        L.PRODUCT,
        L.START_DRAW_NUMBER,
        L.END_DRAW_NUMBER,
        B.DATA,
        L.SUBSCRIPTION_ID,
        L.JOURNAL_ADDRESS
        FROM TXSTORE.MIGR_TX_HEADER H
             INNER JOIN TXSTORE.LOTTERY_TX_HEADER L ON L.LOTTERY_TX_HEADER_ID=H.TX_HEADER_ID
             INNER JOIN TXSTORE.STRING_TX_BODY B ON B.UUID=H.UUID" | tee -a $logfile


###   Create TABLE  MIGRATED_TX_DRAW_ENTRY  ####

log_with_timestamp "CREATE TABLE MIGRATED_TX_DRAW_ENTRY"
db2 " $start_table
      CREATE TABLE TXSTORE.MIGRATED_TX_DRAW_ENTRY(
          ID BIGINT NOT NULL,
          UUID VARCHAR(200) NOT NULL,
          DRAWNUMBER INTEGER NOT NULL,
          PRODUCT INTEGER NOT NULL,
          WIN_STATUS VARCHAR(50) NOT NULL,
          CONSTRAINT XPKMIGRATED_TX_DRAW_ENTRY PRIMARY KEY (ID))
      $end" | tee -a $logfile

###   CREATE SEQUENCE  MIGRATED_TX_DRAW_ENTRY_SEQ   ###########
log_with_timestamp "CREATE SEQUENCE MIGRATED_TX_DRAW_ENTRY_SEQ"
db2 " CREATE or REPLACE SEQUENCE TXSTORE.MIGRATED_TX_DRAW_ENTRY_SEQ INCREMENT BY 1 START WITH 1" | tee -a $logfile

###   CREATE INDEX  MIGRATED_TX_DRAW_ENTRY  ( UUID ASC ) ###########
log_with_timestamp "CREATE INDEX MIGRATED_TX_DRAW_ENTRY ( UUID ASC )"
db2 " $start_index
      CREATE INDEX TXSTORE.IDXMIGRATED_TX_DRAW_ENTRY ON TXSTORE.MIGRATED_TX_DRAW_ENTRY ( UUID ASC )
      $end" | tee -a $logfile

###   CREATE INDEX  LOTTERY_TX_HEADER  (GLOBAL_TRANS_ID,START_DRAW_NUMBER,LOTTERY_TRANSACTION_TYPE) ###########
log_with_timestamp "CREATE INDEX LOTTERY_TX_HEADER (GLOBAL_TRANS_ID,START_DRAW_NUMBER,LOTTERY_TRANSACTION_TYPE)"
db2 " $start_index
      CREATE INDEX TXSTORE.LOTTERY_TX_HEADER_GLOBAL_TRANS_ID_START_DRAW_NUMBER
          on TXSTORE.LOTTERY_TX_HEADER (GLOBAL_TRANS_ID,START_DRAW_NUMBER,LOTTERY_TRANSACTION_TYPE)
      $end" | tee -a $logfile

###   REORG INDEXES on LOTTERY_TX_HEADER ###########
log_with_timestamp "REORG INDEXES on LOTTERY_TX_HEADER"
db2 "REORG INDEXES ALL FOR TABLE TXSTORE.LOTTERY_TX_HEADER" | tee -a $logfile

###   CREATE PROCEDURE INSERT_INTO_MIGRATED_TX_DRAW_ENTRY ###########
log_with_timestamp "CREATE PROCEDURE INSERT_INTO_MIGRATED_TX_DRAW_ENTRY"
db2 "CREATE OR REPLACE PROCEDURE TXSTORE.INSERT_INTO_MIGRATED_TX_DRAW_ENTRY()
         DYNAMIC RESULT SETS 1
         LANGUAGE SQL
     BEGIN
         -- Declare variables
         declare SQLCODE int default 0;
         DECLARE V_SQLCODE INT DEFAULT 0;
         DECLARE v_LOTTERY_TX_HEADER_ID BIGINT;
         DECLARE v_START_DRAW_NUMBER INT;
         DECLARE v_END_DRAW_NUMBER INT;
         DECLARE v_DRAW_NUMBER INT;
         DECLARE v_PRODUCT INT;
         DECLARE v_UUID VARCHAR(200);
         DECLARE v_GLOBAL_TRANS_ID VARCHAR(50);
         DECLARE V_COUNT_VALIDATION INT;
         DECLARE V_COUNT_COMMIT INTEGER;
         -- Declare cursor
         DECLARE LOTTERY_TX_HEADER_FOR_ECH_WAGER CURSOR WITH HOLD FOR
             SELECT
                 D.LOTTERY_TX_HEADER_ID,
                 D.START_DRAW_NUMBER,
                 D.END_DRAW_NUMBER,
                 D.PRODUCT,
                 H.UUID,
                 D.GLOBAL_TRANS_ID
             FROM
                 TXSTORE.LOTTERY_TX_HEADER D
                 INNER JOIN TXSTORE.MIGR_TX_HEADER H
                     ON D.LOTTERY_TX_HEADER_ID = H.TX_HEADER_ID
             WHERE $project_condition D.LOTTERY_TRANSACTION_TYPE = 'WAGER';
         DECLARE CONTINUE HANDLER FOR SQLEXCEPTION, NOT FOUND, SQLWARNING
             SET V_SQLCODE = SQLCODE;
         -- Open cursor
         OPEN LOTTERY_TX_HEADER_FOR_ECH_WAGER;

         FETCH LOTTERY_TX_HEADER_FOR_ECH_WAGER INTO v_LOTTERY_TX_HEADER_ID,
             v_START_DRAW_NUMBER, v_END_DRAW_NUMBER,v_PRODUCT,v_UUID,v_GLOBAL_TRANS_ID;

         SET V_COUNT_COMMIT = 1;
         WHILE (V_SQLCODE = 0) DO
                 SET v_DRAW_NUMBER = v_START_DRAW_NUMBER;
                 WHILE (v_DRAW_NUMBER <= v_END_DRAW_NUMBER) DO
                         SELECT  COUNT(*)
                         INTO    V_COUNT_VALIDATION
                         FROM    TXSTORE.LOTTERY_TX_HEADER
                         WHERE   LOTTERY_TRANSACTION_TYPE = 'VALIDATION'
                                 and GLOBAL_TRANS_ID=v_GLOBAL_TRANS_ID
                                 and START_DRAW_NUMBER=v_DRAW_NUMBER;

                         INSERT INTO TXSTORE.MIGRATED_TX_DRAW_ENTRY (ID,UUID,DRAWNUMBER,PRODUCT,WIN_STATUS)
                         VALUES (
                                    NEXT VALUE FOR TXSTORE.MIGRATED_TX_DRAW_ENTRY_SEQ,
                                    v_UUID,
                                    v_DRAW_NUMBER,
                                    v_PRODUCT,
                                    CASE WHEN V_COUNT_VALIDATION >= 1 THEN 'WINNING' ELSE 'NON_WINNING' END
                                );
                         IF(V_COUNT_COMMIT = 10000) THEN
                                         SET V_COUNT_COMMIT = 1;
                                         COMMIT ;
                                     ELSE
                                         SET V_COUNT_COMMIT = V_COUNT_COMMIT + 1;
                                     end if;
                     SET v_DRAW_NUMBER = v_DRAW_NUMBER + 1;
                 END WHILE;
                 SET V_SQLCODE = 0;
                 FETCH LOTTERY_TX_HEADER_FOR_ECH_WAGER INTO v_LOTTERY_TX_HEADER_ID,
                             v_START_DRAW_NUMBER, v_END_DRAW_NUMBER,v_PRODUCT,v_UUID,v_GLOBAL_TRANS_ID;
                 IF (V_SQLCODE <> 0) THEN
                             CALL SYSIBMADM.DBMS_OUTPUT.PUT_LINE('End reading cursor');
                 END IF;
         END WHILE;
     CLOSE LOTTERY_TX_HEADER_FOR_ECH_WAGER;
     END" | tee -a $logfile

###   Create VIEW  MIGRATED_TX_DRAW   ###########
log_with_timestamp "CREATE VIEW MIGRATED_TX_DRAW"
db2 "CREATE OR REPLACE VIEW TXSTORE.MIGRATED_TX_DRAW AS
  SELECT
    E.IDDGGAMEEVENT,
    E.IDDGGAME,
    E.DRAWNUMBER,
    E.DRAWDATE
  FROM TXSTORE.MIGRATED_TX_DRAW_ENTRY DE
       INNER JOIN GIS.DGGAMEEVENT E ON E.IDDGGAME=DE.PRODUCT AND E.DRAWNUMBER=DE.DRAWNUMBER
  GROUP BY E.IDDGGAMEEVENT,E.IDDGGAME,E.DRAWNUMBER,E.DRAWDATE" | tee -a $logfile

###   CREATE SEQUENCE  MIGRATED_RESULTS_SEQ   ###########
log_with_timestamp "CREATE SEQUENCE  MIGRATED_RESULTS_SEQ"
db2 "CREATE or REPLACE SEQUENCE TXSTORE.MIGRATED_RESULTS_SEQ INCREMENT BY 1 START WITH 1" | tee -a $logfile

####   CREATE TABLE MIGRATED_RESULTS   ###########
log_with_timestamp "CREATE TABLE MIGRATED_RESULTS"
index='IN "TS_TXST" INDEX IN "TS_TXST_IDX"'
db2 " $start_table
      CREATE TABLE TXSTORE.MIGRATED_RESULTS (
        ID BIGINT NOT NULL constraint XPMIGRATED_RESULTS primary key,
        LOTTERY_TX_HEADER_ID BIGINT NOT NULL,
        DRAWNUMBER INTEGER NOT NULL,
        PRODUCT SMALLINT NOT NULL,
        TRANSACTION_AMOUNT BIGINT NOT NULL,
        TRANSACTION_TIME_UTC TIMESTAMP NOT NULL,
        TX_DRAW_ENTRY_ID BIGINT NOT NULL,
        UUID VARCHAR(200),
        WINNINGDIVISION INTEGER) $index $end" | tee -a $logfile

###   CREATE TABLE BATCH_JOB_INSTANCE   ###########
log_with_timestamp "CREATE TABLE BATCH_JOB_INSTANCE"
db2 " $start_table
      create table GIS.BATCH_JOB_INSTANCE
      (
          JOB_INSTANCE_ID BIGINT       not null primary key,
          VERSION         BIGINT,
          JOB_NAME        VARCHAR(100) not null,
          JOB_KEY         VARCHAR(32)  not null,
          constraint JOB_INST_UN unique (JOB_NAME, JOB_KEY)
      ) $end" | tee -a $logfile
log_with_timestamp "grant access to BATCH_JOB_INSTANCE"
db2 "grant select on table GIS.BATCH_JOB_INSTANCE to GTDBVWO1" | tee -a $logfile
db2 "grant alter, delete, index, insert, references, select, update on table GIS.BATCH_JOB_INSTANCE to GTDBDEV1" | tee -a $logfile
db2 "grant alter, delete, index, insert, references, select, update on table GIS.BATCH_JOB_INSTANCE to GTDBAPP1" | tee -a $logfile

###   CREATE TABLE BATCH_JOB_EXECUTION   ###########
log_with_timestamp "CREATE TABLE BATCH_JOB_EXECUTION"
db2 " $start_table
     create table GIS.BATCH_JOB_EXECUTION
      (
          JOB_EXECUTION_ID           BIGINT       not null
              primary key,
          VERSION                    BIGINT,
          JOB_INSTANCE_ID            BIGINT       not null
              constraint JOB_INST_EXEC_FK
                  references GIS.BATCH_JOB_INSTANCE,
          CREATE_TIME                TIMESTAMP(6) not null,
          START_TIME                 TIMESTAMP(6) default NULL,
          END_TIME                   TIMESTAMP(6) default NULL,
          STATUS                     VARCHAR(10),
          EXIT_CODE                  VARCHAR(2500),
          EXIT_MESSAGE               VARCHAR(2500),
          LAST_UPDATED               TIMESTAMP(6),
          JOB_CONFIGURATION_LOCATION VARCHAR(2500)
      )$end" | tee -a $logfile
log_with_timestamp "grant access to BATCH_JOB_INSTANCE"
db2 "grant select on table GIS.BATCH_JOB_EXECUTION to GTDBVWO1" | tee -a $logfile
db2 "grant alter, delete, index, insert, references, select, update on table GIS.BATCH_JOB_EXECUTION to GTDBAPP1" | tee -a $logfile
db2 "grant alter, delete, index, insert, references, select, update on table GIS.BATCH_JOB_EXECUTION to GTDBDEV1" | tee -a $logfile

###   CREATE TABLE BATCH_JOB_EXECUTION_CONTEXT   ###########
log_with_timestamp "CREATE TABLE BATCH_JOB_EXECUTION_CONTEXT"
db2 " $start_table
     create table GIS.BATCH_JOB_EXECUTION_CONTEXT
      (
          JOB_EXECUTION_ID   BIGINT        not null
              primary key
              constraint JOB_EXEC_CTX_FK
                  references GIS.BATCH_JOB_EXECUTION,
          SHORT_CONTEXT      VARCHAR(2500) not null,
          SERIALIZED_CONTEXT CLOB(1048576)
      )$end" | tee -a $logfile
log_with_timestamp "grant access to BATCH_JOB_INSTANCE"
db2 "grant alter, delete, index, insert, references, select, update on table GIS.BATCH_JOB_EXECUTION_CONTEXT to GTDBDEV1" | tee -a $logfile
db2 "grant alter, delete, index, insert, references, select, update on table GIS.BATCH_JOB_EXECUTION_CONTEXT to GTDBAPP1" | tee -a $logfile
db2 "grant select on table GIS.BATCH_JOB_EXECUTION_CONTEXT to GTDBVWO1" | tee -a $logfile

###   CREATE TABLE BATCH_JOB_EXECUTION_PARAMS   ###########
log_with_timestamp "CREATE TABLE BATCH_JOB_EXECUTION_PARAMS"
db2 " $start_table
     create table GIS.BATCH_JOB_EXECUTION_PARAMS
      (
          JOB_EXECUTION_ID BIGINT       not null
              constraint JOB_EXEC_PARAMS_FK
                  references GIS.BATCH_JOB_EXECUTION,
          TYPE_CD          VARCHAR(6)   not null,
          KEY_NAME         VARCHAR(100) not null,
          STRING_VAL       VARCHAR(250),
          DATE_VAL         TIMESTAMP(6) default NULL,
          LONG_VAL         BIGINT,
          DOUBLE_VAL       DOUBLE,
          IDENTIFYING      CHARACTER(1) not null
      )$end" | tee -a $logfile
log_with_timestamp "grant access to BATCH_JOB_INSTANCE"
db2 "grant alter, delete, index, insert, references, select, update on table GIS.BATCH_JOB_EXECUTION_PARAMS to GTDBDEV1" | tee -a $logfile
db2 "grant alter, delete, index, insert, references, select, update on table GIS.BATCH_JOB_EXECUTION_PARAMS to GTDBAPP1" | tee -a $logfile
db2 "grant select on table GIS.BATCH_JOB_EXECUTION_PARAMS to GTDBVWO1" | tee -a $logfile

###   CREATE TABLE BATCH_STEP_EXECUTION   ###########
log_with_timestamp "CREATE TABLE BATCH_STEP_EXECUTION"
db2 " $start_table
     create table GIS.BATCH_STEP_EXECUTION
      (
          STEP_EXECUTION_ID  BIGINT       not null
              primary key,
          VERSION            BIGINT       not null,
          STEP_NAME          VARCHAR(100) not null,
          JOB_EXECUTION_ID   BIGINT       not null
              constraint JOB_EXEC_STEP_FK
                  references GIS.BATCH_JOB_EXECUTION,
          START_TIME         TIMESTAMP(6) not null,
          END_TIME           TIMESTAMP(6) default NULL,
          STATUS             VARCHAR(10),
          COMMIT_COUNT       BIGINT,
          READ_COUNT         BIGINT,
          FILTER_COUNT       BIGINT,
          WRITE_COUNT        BIGINT,
          READ_SKIP_COUNT    BIGINT,
          WRITE_SKIP_COUNT   BIGINT,
          PROCESS_SKIP_COUNT BIGINT,
          ROLLBACK_COUNT     BIGINT,
          EXIT_CODE          VARCHAR(2500),
          EXIT_MESSAGE       VARCHAR(2500),
          LAST_UPDATED       TIMESTAMP(6)
      )$end" | tee -a $logfile
log_with_timestamp "grant access to BATCH_JOB_INSTANCE"
db2 "grant alter, delete, index, insert, references, select, update on table GIS.BATCH_STEP_EXECUTION to GTDBDEV1" | tee -a $logfile
db2 "grant alter, delete, index, insert, references, select, update on table GIS.BATCH_STEP_EXECUTION to GTDBAPP1" | tee -a $logfile
db2 "grant select on table GIS.BATCH_STEP_EXECUTION to GTDBVWO1" | tee -a $logfile

###   CREATE TABLE BATCH_STEP_EXECUTION_CONTEXT   ###########
log_with_timestamp "CREATE TABLE BATCH_STEP_EXECUTION_CONTEXT"
db2 " $start_table
     create table GIS.BATCH_STEP_EXECUTION_CONTEXT
      (
          STEP_EXECUTION_ID  BIGINT        not null
              primary key
              constraint STEP_EXEC_CTX_FK
                  references GIS.BATCH_STEP_EXECUTION,
          SHORT_CONTEXT      VARCHAR(2500) not null,
          SERIALIZED_CONTEXT CLOB(1048576)
      )$end" | tee -a $logfile
log_with_timestamp "grant access to BATCH_JOB_INSTANCE"
db2 "grant alter, delete, index, insert, references, select, update on table GIS.BATCH_STEP_EXECUTION_CONTEXT to GTDBDEV1" | tee -a $logfile
db2 "grant alter, delete, index, insert, references, select, update on table GIS.BATCH_STEP_EXECUTION_CONTEXT to GTDBAPP1" | tee -a $logfile
db2 "grant select on table GIS.BATCH_STEP_EXECUTION_CONTEXT to GTDBVWO1" | tee -a $logfile

###   CREATE SEQUENCE  BATCH_JOB_EXECUTION_SEQ   ###########
log_with_timestamp "CREATE SEQUENCE BATCH_JOB_EXECUTION_SEQ"
db2 "CREATE or REPLACE sequence GIS.BATCH_JOB_EXECUTION_SEQ as BIGINT" | tee -a $logfile
log_with_timestamp "grant access to BATCH_JOB_EXECUTION_SEQ"
db2 "grant alter, usage on sequence GIS.BATCH_JOB_EXECUTION_SEQ to GTDBAPP1" | tee -a $logfile
db2 "grant alter, usage on sequence GIS.BATCH_JOB_EXECUTION_SEQ to GTDBDEV1" | tee -a $logfile

###   CREATE SEQUENCE  BATCH_JOB_SEQ   ###########
log_with_timestamp "CREATE SEQUENCE BATCH_JOB_SEQ"
db2 "CREATE or REPLACE sequence GIS.BATCH_JOB_SEQ as BIGINT" | tee -a $logfile
log_with_timestamp "grant access to BATCH_JOB_SEQ"
db2 "grant alter, usage on sequence GIS.BATCH_JOB_SEQ to GTDBDEV1" | tee -a $logfile
db2 "grant alter, usage on sequence GIS.BATCH_JOB_SEQ to GTDBAPP1" | tee -a $logfile


###   CREATE SEQUENCE  BATCH_JOB_SEQ   ###########
log_with_timestamp "CREATE SEQUENCE BATCH_STEP_EXECUTION_SEQ"
db2 "CREATE or REPLACE sequence GIS.BATCH_STEP_EXECUTION_SEQ as BIGINT" | tee -a $logfile
log_with_timestamp "grant access to BATCH_STEP_EXECUTION_SEQ"
db2 "grant alter, usage on sequence GIS.BATCH_STEP_EXECUTION_SEQ to GTDBDEV1" | tee -a $logfile
db2 "grant alter, usage on sequence GIS.BATCH_STEP_EXECUTION_SEQ to GTDBAPP1" | tee -a $logfile

echo "" | tee -a $logfile
echo "------------ END creation ------------" | tee -a $logfile

###   CREATE TABLE MIGRATED_TX_JSON   ###########
log_with_timestamp "CREATE TABLE MIGRATED_TX_JSON"
db2 " $start_table
     create table TXSTORE.MIGRATED_TX_JSON
      (
          UUID VARCHAR(200),
          JSON VARCHAR(20000)
      )$end" | tee -a $logfile

###   CREATE PROCEDURE to handle primarry/secondary board-data ###########
log_with_timestamp "CREATE PROCEDURE to handle primarry/secondary board-data"
db2 -td@ -vf SQL/CREATE_OR_REPLACE_PROCEDURE_TXSTORE.HANDLE_PART.db2 | tee -a $logfile

###   CREATE PROCEDURE RemoveXmlns ###########
log_with_timestamp "CREATE PROCEDURE RemoveXmlns"
db2 -td@ -vf SQL/CREATE_PROCEDURE_RemoveXmlns.db2 | tee -a $logfile

###   CREATE PROCEDURE TX_TRANSACTION_JSON_EXPORT ###########
log_with_timestamp "CREATE PROCEDURE TX_TRANSACTION_JSON_EXPORT"
db2 -td@ -vf SQL/CREATE_PROCEDURE_TX_TRANSACTION_JSON_EXPORT.db2 | tee -a $logfile

