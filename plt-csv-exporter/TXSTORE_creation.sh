#!/bin/bash

#--:::::::::::::::::::::::::::::::TXSTORE:::::::::::::::::::::::::::

start_table="BEGIN DECLARE CONTINUE HANDLER FOR SQLSTATE '42710' BEGIN END; EXECUTE IMMEDIATE '"
start_index="BEGIN DECLARE CONTINUE HANDLER FOR SQLSTATE '01550' BEGIN END; EXECUTE IMMEDIATE '"
end="';END"

##########    Create TMP table MIGRATED_TX_TRANSACTION    ##################

#####################
db2 connect to pddb
#####################

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
                            transaction_amount int NULL,
                            transaction_discount_amount int NULL,
                            currency varchar(10) NULL,
                            serial int NULL,
                            cdc int NULL,
                            game_engine_transaction_time timestamp NULL,
                            product_id int NULL,
                            start_draw_number int NULL,
                            end_draw_number int NULL,
                            is_open varchar(10),
                            site_json_data varchar(100) NULL,
                            serial_number varchar(30) NULL)
      $end"

##########    Create TMP table MIGR_TX_HEADER    ##################

db2 "$start_table
      create table TXSTORE.MIGR_TX_HEADER(
          TX_HEADER_ID BIGINT not null constraint XPKMIGR_TX_HEADER primary key,
          PLAYER_ID    BIGINT not null,
          UUID         VARCHAR(200))
      $end"

db2 " $start_index
      create unique index TXSTORE.UQIDXMIGR_TX_HEADER
          on TXSTORE.MIGR_TX_HEADER (UUID)
      $end"
db2 " $start_index
      create index TXSTORE.XIDXMIGR_TX_HEADERPLAYERID
          on TXSTORE.MIGR_TX_HEADER (PLAYER_ID)
      $end"

##########    Create VIEW  VIEW_MIGRATED_TX    ##################

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
             INNER JOIN TXSTORE.STRING_TX_BODY B ON B.UUID=H.UUID"


##########    Create TABLE  MIGRATED_TX_DRAW_ENTRY    ##################

db2 " $start_table
      CREATE TABLE TXSTORE.MIGRATED_TX_DRAW_ENTRY(
          ID BIGINT NOT NULL,
          UUID VARCHAR(200) NOT NULL,
          DRAWNUMBER INTEGER NOT NULL,
          PRODUCT INTEGER NOT NULL,
          WIN_STATUS VARCHAR(50) NOT NULL,
          CONSTRAINT XPKMIGRATED_TX_DRAW_ENTRY PRIMARY KEY (ID))
      $end"

db2 " CREATE or REPLACE SEQUENCE TXSTORE.MIGRATED_TX_DRAW_ENTRY_SEQ INCREMENT BY 1 START WITH 1"

db2 " $start_index
      CREATE INDEX TXSTORE.IDXMIGRATED_TX_DRAW_ENTRY ON TXSTORE.MIGRATED_TX_DRAW_ENTRY ( UUID ASC )
      $end"

db2 " $start_index
      CREATE index TXSTORE.LOTTERY_TX_HEADER_GLOBAL_TRANS_ID_START_DRAW_NUMBER
          on TXSTORE.LOTTERY_TX_HEADER (GLOBAL_TRANS_ID,START_DRAW_NUMBER,LOTTERY_TRANSACTION_TYPE)
      $end"

db2 "REORG INDEXES ALL FOR TABLE TXSTORE.LOTTERY_TX_HEADER"

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
             WHERE   D.LOTTERY_TRANSACTION_TYPE = 'WAGER';
         DECLARE CONTINUE HANDLER FOR SQLEXCEPTION, NOT FOUND, SQLWARNING
             SET V_SQLCODE = SQLCODE;
         -- Open cursor
         OPEN LOTTERY_TX_HEADER_FOR_ECH_WAGER;

         FETCH LOTTERY_TX_HEADER_FOR_ECH_WAGER INTO v_LOTTERY_TX_HEADER_ID,
             v_START_DRAW_NUMBER, v_END_DRAW_NUMBER,v_PRODUCT,v_UUID,v_GLOBAL_TRANS_ID;

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
                         commit;
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
     END"
##########    Create VIEW  MIGRATED_TX_DRAW    ##################

db2 "CREATE OR REPLACE VIEW TXSTORE.MIGRATED_TX_DRAW AS
  SELECT
    E.IDDGGAMEEVENT,
    E.IDDGGAME,
    E.DRAWNUMBER,
    E.DRAWDATE
  FROM TXSTORE.MIGRATED_TX_DRAW_ENTRY DE
       INNER JOIN GIS.DGGAMEEVENT E ON E.IDDGGAME=DE.PRODUCT AND E.DRAWNUMBER=DE.DRAWNUMBER
  GROUP BY E.IDDGGAMEEVENT,E.IDDGGAME,E.DRAWNUMBER,E.DRAWDATE"



db2 "CREATE or REPLACE SEQUENCE TXSTORE.MIGRATED_RESULTS_SEQ INCREMENT BY 1 START WITH 1"

ind='IN "TS_TXST" INDEX IN "TS_TXST_IDX"'
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
    DATA XML) $ind $end"