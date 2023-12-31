CREATE OR REPLACE PROCEDURE TXSTORE.INSERT_INTO_MIGRATED_TX_DRAW_ENTRY()
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
                INNER JOIN TXSTORE.MIGRATED_TX_TRANSACTION H
                           ON D.LOTTERY_TX_HEADER_ID = H.TX_TRANSACTION_ID
        WHERE {PROJECT_CONDITION} D.LOTTERY_TRANSACTION_TYPE = 'WAGER';
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
                    INSERT INTO TXSTORE.MIGRATED_TX_DRAW_ENTRY (ID,UUID,DRAWNUMBER,PRODUCT,WIN_STATUS)
                    VALUES (
                               NEXT VALUE FOR TXSTORE.MIGRATED_TX_DRAW_ENTRY_SEQ,
                               v_UUID,
                               v_DRAW_NUMBER,
                               v_PRODUCT,
                               'NON_WINNING'
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
END
@