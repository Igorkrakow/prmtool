CREATE or replace PROCEDURE TXSTORE.TSO_PAYMENT_OPEN_SD_TO_CLOSED_DELTA(start_time TIMESTAMP, end_time TIMESTAMP)
    LANGUAGE SQL
BEGIN
    DECLARE SQLCODE INT DEFAULT 0;
    DECLARE V_SQLCODE INT DEFAULT 0;

    DECLARE V_LOTTERY_TX_HEADER_ID BIGINT;
    DECLARE V_PLAYER_ID BIGINT;
    DECLARE V_TRANSACTION_AMOUNT BIGINT;
    DECLARE V_TRANSACTION_TIME_LOCAL TIMESTAMP;
    DECLARE V_UUID VARCHAR (200);
    DECLARE V_PRODUCT SMALLINT;
    DECLARE V_GLOBAL_TRANS_ID VARCHAR(50);
    DECLARE V_START_DRAW_NUMBER INTEGER;

    DECLARE V_COUNT_COMMIT BIGINT;


    DECLARE MIGRATED_TX_CURSOR CURSOR WITH HOLD FOR
SELECT
    LTHW.LOTTERY_TX_HEADER_ID,
    THW.PLAYER_ID,
    NVL(VAL.TRANSACTION_AMOUNT,0),
    CASE WHEN VAL.TRANSACTION_TIME_LOCAL IS NULL THEN LTHW.TRANSACTION_TIME_LOCAL
         ELSE VAL.TRANSACTION_TIME_LOCAL END,
    CASE WHEN VAL.UUID IS NULL THEN THW.UUID
         ELSE VAL.UUID END,
    LTHW.PRODUCT,
    LTHW.GLOBAL_TRANS_ID,
    LTHW.START_DRAW_NUMBER
FROM TXSTORE.LOTTERY_TX_HEADER LTHW
    JOIN TXSTORE.TMP_TSO_OPEN_PAYMENT_TRANSACTION TTOPT ON LTHW.LOTTERY_TX_HEADER_ID = TTOPT.TRANSACTION_ID
    AND LTHW.LOTTERY_TRANSACTION_TYPE = 'WAGER'
         JOIN TXSTORE.TX_HEADER THW ON THW.TX_HEADER_ID = LTHW.LOTTERY_TX_HEADER_ID
    AND LTHW.TRANSACTION_TIME_LOCAL >= start_time AND LTHW.TRANSACTION_TIME_LOCAL < end_time
         LEFT JOIN (SELECT * FROM TXSTORE.LOTTERY_TX_HEADER LTHV JOIN TXSTORE.TX_HEADER THV ON LOTTERY_TX_HEADER_ID = TX_HEADER_ID
                    WHERE LOTTERY_TRANSACTION_TYPE  = 'VALIDATION') VAL ON
        (LTHW.GLOBAL_TRANS_ID = VAL.GLOBAL_TRANS_ID AND LTHW.SERIAL = VAL.SERIAL) OR
        (LTHW.START_DRAW_NUMBER=VAL.START_DRAW_NUMBER and
            LTHW.SERIAL = VAL.SERIAL AND THW.PLAYER_ID = VAL.PLAYER_ID AND LTHW.GLOBAL_TRANS_ID != VAL.GLOBAL_TRANS_ID)
         JOIN GIS.DGGAME ON LTHW.PRODUCT = GIS.DGGAME.HOSTPRODUCTNUMBER
-- Closed wagers only
         JOIN TXSTORE.LAST_CLOSED ON GIS.DGGAME.IDDGGAME = TXSTORE.LAST_CLOSED.IDDGGAME
    AND LTHW.END_DRAW_NUMBER <= TXSTORE.LAST_CLOSED.DRAWNUMBER
     -- Only migrate allowed player IDs
--JOIN PAM_CMD.SMS_CONTRACT_MIGRATION ON CONTRACT_IDENTITY = TXSTORE.TX_HEADER.PLAYER_ID

--where LOTTERY_TX_HEADER_ID not in (select WAGER_TRANSACTION_ID from TXSTORE.TMP_TSO_REFUND)
     --SD WAGER
WHERE TTOPT.SD_OR_MD = 1 AND TTOPT.STATUS = 0;

DECLARE CONTINUE HANDLER FOR SQLEXCEPTION, NOT FOUND, SQLWARNING
        SET V_SQLCODE = SQLCODE;
OPEN MIGRATED_TX_CURSOR;
CALL SYSIBMADM.DBMS_OUTPUT.PUT_LINE('Open and start reading the "TSO_PURCHASE_CURSOR" cursor.');
FETCH MIGRATED_TX_CURSOR INTO V_LOTTERY_TX_HEADER_ID,V_PLAYER_ID,V_TRANSACTION_AMOUNT,V_TRANSACTION_TIME_LOCAL,
    V_UUID,V_PRODUCT,V_GLOBAL_TRANS_ID,V_START_DRAW_NUMBER;

SET V_COUNT_COMMIT = 1;
    WHILE (V_SQLCODE = 0)
        DO
        INSERT INTO TXSTORE.TMP_TSO_PAYMENT (transaction_id,
                    player_id,
                    status,
                    DRAW,
                    transaction_date,
                    uuid,
                    product,
                    amount,
                    global_trans_id,
                    start_date_run,
                    end_date_run,
                    start_date_update,
                    end_date_update,
                    delta) VALUES (V_LOTTERY_TX_HEADER_ID,V_PLAYER_ID,
                                   CASE WHEN V_TRANSACTION_AMOUNT > 0 THEN 'WINNING' ELSE 'LOSE' END,
                                   V_START_DRAW_NUMBER,V_TRANSACTION_TIME_LOCAL,V_UUID,V_PRODUCT,V_TRANSACTION_AMOUNT,
                                   V_GLOBAL_TRANS_ID,start_time,end_time,start_time,end_time,'i');

        UPDATE TXSTORE.TMP_TSO_OPEN_PAYMENT_TRANSACTION
        SET STATUS = 1,
            START_UPDATE_DATE = start_time,END_UPDATE_DATE=end_time
        where TRANSACTION_ID = V_LOTTERY_TX_HEADER_ID;

            IF(V_COUNT_COMMIT = 10000) THEN
                SET V_COUNT_COMMIT = 1;
COMMIT ;
ELSE
                SET V_COUNT_COMMIT = V_COUNT_COMMIT + 1;
end if;
            SET V_SQLCODE = 0;
FETCH MIGRATED_TX_CURSOR INTO V_LOTTERY_TX_HEADER_ID,V_PLAYER_ID,V_TRANSACTION_AMOUNT,V_TRANSACTION_TIME_LOCAL,
    V_UUID,V_PRODUCT,V_GLOBAL_TRANS_ID,V_START_DRAW_NUMBER;
IF (V_SQLCODE <> 0) THEN
                CALL SYSIBMADM.DBMS_OUTPUT.PUT_LINE(
                            'Finish reading the cursor.' || V_SQLCODE);
END IF;
END WHILE;
CLOSE MIGRATED_TX_CURSOR;
CALL SYSIBMADM.DBMS_OUTPUT.PUT_LINE('Close the "TSO_PURCHASE_CURSOR" cursor.');
END
@
