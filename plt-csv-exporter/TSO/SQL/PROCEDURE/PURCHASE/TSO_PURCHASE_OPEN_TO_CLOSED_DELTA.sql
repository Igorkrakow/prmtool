CREATE or replace PROCEDURE TXSTORE.TSO_PURCHASE_OPEN_TO_CLOSED_DELTA(start_time TIMESTAMP, end_time TIMESTAMP)
    LANGUAGE SQL
BEGIN
    DECLARE SQLCODE INT DEFAULT 0;
    DECLARE V_SQLCODE INT DEFAULT 0;

    DECLARE V_WAGER_LOTTERY_TX_HEADER_ID BIGINT;
    DECLARE V_PLAYER_ID BIGINT;
    DECLARE V_TRANSACTION_DATE TIMESTAMP;
    DECLARE V_UUID VARCHAR(200);
    DECLARE V_PRODUCT SMALLINT;
    DECLARE V_AMOUNT BIGINT;
    DECLARE V_GLOBAL_TRANS_ID VARCHAR(50);

    DECLARE V_COUNT_COMMIT BIGINT;


    DECLARE MIGRATED_TX_CURSOR CURSOR WITH HOLD FOR
SELECT
    LTHW.LOTTERY_TX_HEADER_ID,
    THW.PLAYER_ID EXTERNAL_ID,
    VARCHAR_FORMAT(LTHW.TRANSACTION_TIME_LOCAL,'YYYY-MM-DD HH24:MI:SS.FF3') EXTERNAL_TRANSACTION_DATE,
    THW.UUID EXTERNAL_TRANSACTION_ID, -- ticket number
    LTHW.PRODUCT GAME_CODE,
    NVL(LTHW.TRANSACTION_AMOUNT, 0) AMOUNT,
    LTHW.GLOBAL_TRANS_ID ROUND_ID
FROM TXSTORE.TMP_TSO_OPEN_TRANSACTION TTOT
         JOIN TXSTORE.LOTTERY_TX_HEADER LTHW ON TTOT.TRANSACTION_ID = LTHW.LOTTERY_TX_HEADER_ID
    AND TTOT.STATUS = 'OPEN'
         JOIN TXSTORE.TX_HEADER THW ON THW.TX_HEADER_ID = LTHW.LOTTERY_TX_HEADER_ID
    AND LTHW.LOTTERY_TRANSACTION_TYPE = 'WAGER'
         JOIN GIS.DGGAME ON LTHW.PRODUCT = GIS.DGGAME.HOSTPRODUCTNUMBER

-- Closed wagers only
         JOIN TXSTORE.LAST_CLOSED ON GIS.DGGAME.IDDGGAME = TXSTORE.LAST_CLOSED.IDDGGAME
    AND START_DRAW_NUMBER <= TXSTORE.LAST_CLOSED.DRAWNUMBER;
-- Only migrate allowed player IDs
--JOIN PAM_CMD.SMS_CONTRACT_MIGRATION ON CONTRACT_IDENTITY = TXSTORE.TX_HEADER.PLAYER_ID

--where LOTTERY_TX_HEADER_ID not in (select WAGER_TRANSACTION_ID from TXSTORE.TMP_TSO_REFUND);



DECLARE CONTINUE HANDLER FOR SQLEXCEPTION, NOT FOUND, SQLWARNING
        SET V_SQLCODE = SQLCODE;
OPEN MIGRATED_TX_CURSOR;
CALL SYSIBMADM.DBMS_OUTPUT.PUT_LINE('Open and start reading the "TSO_PURCHASE_CURSOR" cursor.');
FETCH MIGRATED_TX_CURSOR
    INTO V_WAGER_LOTTERY_TX_HEADER_ID, V_PLAYER_ID,
    V_TRANSACTION_DATE, V_UUID,
    V_PRODUCT ,V_AMOUNT, V_GLOBAL_TRANS_ID;
SET V_COUNT_COMMIT = 1;
    WHILE (V_SQLCODE = 0)
        DO

        UPDATE TXSTORE.TMP_TSO_PURCHASE
        SET STATUS = 'CLOSED', DELTA = 'u',START_DATE_UPDATE = start_time,END_DATE_UPDATE = end_time
        WHERE WAGER_TRANSACTION_ID = V_WAGER_LOTTERY_TX_HEADER_ID;

        UPDATE TXSTORE.TMP_TSO_OPEN_TRANSACTION
            SET STATUS = 'CLOSED',
             START_UPDATE_DATE = start_time,END_UPDATE_DATE=end_time
        where TRANSACTION_ID = V_WAGER_LOTTERY_TX_HEADER_ID;


IF(V_COUNT_COMMIT = 10000) THEN
                SET V_COUNT_COMMIT = 1;
COMMIT ;
ELSE
                SET V_COUNT_COMMIT = V_COUNT_COMMIT + 1;
end if;
            SET V_SQLCODE = 0;
FETCH MIGRATED_TX_CURSOR
    INTO V_WAGER_LOTTERY_TX_HEADER_ID, V_PLAYER_ID,
    V_TRANSACTION_DATE, V_UUID,
    V_PRODUCT ,V_AMOUNT, V_GLOBAL_TRANS_ID;
IF (V_SQLCODE <> 0) THEN
                CALL SYSIBMADM.DBMS_OUTPUT.PUT_LINE(
                            'Finish reading the cursor.' || V_SQLCODE);
END IF;
END WHILE;
CLOSE MIGRATED_TX_CURSOR;
CALL SYSIBMADM.DBMS_OUTPUT.PUT_LINE('Close the "TSO_PURCHASE_CURSOR" cursor.');
END
;

