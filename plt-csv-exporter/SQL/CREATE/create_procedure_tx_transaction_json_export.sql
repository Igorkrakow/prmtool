CREATE OR REPLACE PROCEDURE TXSTORE.TX_TRANSACTION_JSON_EXPORT(V_PROJECT varchar(10))
    LANGUAGE SQL
BEGIN
    DECLARE SQLCODE INT DEFAULT 0;
    DECLARE V_SQLCODE INT DEFAULT 0;
    DECLARE V_TX_HEADER_ID BIGINT;
    DECLARE V_GLOBAL_TRANS_ID VARCHAR(50);
    DECLARE V_CORRELATION_ID VARCHAR(50);
    DECLARE V_UUID VARCHAR(200);
    DECLARE V_PLAYER_ID BIGINT;
    DECLARE V_TRANSACTION_TIME_UTC TIMESTAMP;
    DECLARE V_LOTTERY_TRANSACTION_TYPE VARCHAR(25);
    DECLARE V_TRANSACTION_AMOUNT BIGINT;
    DECLARE V_SERIAL VARCHAR(50);
    DECLARE V_CDC INTEGER;
    DECLARE V_TRANSACTION_TIME_LOCAL TIMESTAMP;
    DECLARE V_PRODUCT SMALLINT;
    DECLARE V_START_DRAW_NUMBER INTEGER;
    DECLARE V_END_DRAW_NUMBER INTEGER;
    DECLARE V_SUBSCRIPTION_ID BIGINT;
    DECLARE V_JOURNAL_ADDRESS BIGINT;
    DECLARE V_JURISDICTION INT;
    DECLARE V_CURRENT_DRAW INTEGER;
    DECLARE V_DATA XML;
    DECLARE V_DRAW_IDS VARCHAR(200);
    DECLARE V_DRAW_ID INT;
    DECLARE V_MULTIPLIER INT;
    DECLARE V_JSON VARCHAR(20000);
    DECLARE V_INDEX INT DEFAULT 1;
    DECLARE V_BOARD_DATA XML;
    DECLARE V_BOARD_INDEX int;
    DECLARE V_QP varchar(10);
    DECLARE V_VALUE varchar (500);
    DECLARE V_PRIMARY_RESULT VARCHAR(8000) DEFAULT '';
    DECLARE V_SECONDARY_RESULT VARCHAR(8000) DEFAULT '';
    DECLARE V_RESULT VARCHAR(2000) DEFAULT '';
    DECLARE V_PRIMARY VARCHAR(1000) DEFAULT '';
    DECLARE V_SECONDARY VARCHAR(1000) DEFAULT '';
    DECLARE V_DRAW_DATE  VARCHAR(100);
    DECLARE V_UNIX_TIMESTAMP BIGINT;
    DECLARE V_TIER VARCHAR(10);
    DECLARE V_WIN_SET INTEGER;
    DECLARE V_DRAW INTEGER;
    DECLARE V_DIVISION INTEGER;
    DECLARE V_COUNT_COMMIT INTEGER;
    DECLARE V_CHANNEL_ID INTEGER;
    DECLARE V_SYSTEM_ID INTEGER;
    DECLARE V_SERIAL_NUMBER VARCHAR(30);
    DECLARE V_OPEN_TX_HEADER_ID BIGINT;
    DECLARE V_IS_OPEN BOOLEAN;
    DECLARE MIGRATED_TX_CURSOR CURSOR WITH HOLD FOR
        SELECT TX_HEADER_ID, GLOBAL_TRANS_ID, CORRELATION_ID, UUID, PLAYER_ID,
               TRANSACTION_TIME_UTC, LOTTERY_TRANSACTION_TYPE, TRANSACTION_AMOUNT,
               SERIAL, CDC, TRANSACTION_TIME_LOCAL, PRODUCT, START_DRAW_NUMBER,
               END_DRAW_NUMBER,SUBSCRIPTION_ID, JOURNAL_ADDRESS,DATA
        FROM TXSTORE.VIEW_MIGRATED_TX;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION, NOT FOUND, SQLWARNING
        SET V_SQLCODE = SQLCODE;
    OPEN MIGRATED_TX_CURSOR;
    CALL SYSIBMADM.DBMS_OUTPUT.PUT_LINE('Open and start reading the "MIGRATED_TX_CURSOR" cursor.');
    FETCH MIGRATED_TX_CURSOR
        INTO V_TX_HEADER_ID,V_GLOBAL_TRANS_ID,V_CORRELATION_ID,V_UUID,V_PLAYER_ID,V_TRANSACTION_TIME_UTC,
            V_LOTTERY_TRANSACTION_TYPE,V_TRANSACTION_AMOUNT,V_SERIAL,V_CDC,V_TRANSACTION_TIME_LOCAL,
            V_PRODUCT,V_START_DRAW_NUMBER,V_END_DRAW_NUMBER,V_SUBSCRIPTION_ID,V_JOURNAL_ADDRESS,V_DATA;
    SET V_COUNT_COMMIT = 1;
    WHILE (V_SQLCODE = 0)
        DO
        SET V_IS_OPEN = FALSE;
            ------------  WAGER  ------------
            IF V_LOTTERY_TRANSACTION_TYPE='WAGER' then
                SELECT E.DRAWNUMBER INTO V_CURRENT_DRAW FROM GIS.DGGAMEEVENT E
                                                        INNER JOIN GIS.DGGAME G ON G.IDDGGAME=V_PRODUCT
                                                        AND G.IDDGGAMEEVENT_CURRENT=E.IDDGGAMEEVENT;
                IF V_CURRENT_DRAW is NOT null AND V_END_DRAW_NUMBER is NOT null AND V_END_DRAW_NUMBER>V_CURRENT_DRAW
                    then
                    SET V_IS_OPEN = TRUE;
                    insert into TXSTORE.MIGR_OPEN_TX_HEADER (TX_HEADER_ID,PLAYER_ID,UUID,GLOBAL_TRANS_ID,CDC,SERIAL)
                    values (V_TX_HEADER_ID,V_PLAYER_ID,V_UUID,V_GLOBAL_TRANS_ID,V_CDC,V_SERIAL);
                    IF (V_SQLCODE != 0) THEN
                    CALL SYSIBMADM.DBMS_OUTPUT.PUT_LINE('Open wager '||'ERROR WHILE INSERT #'||V_SQLCODE);
                    END IF;
                    COMMIT;

            end if;
            end if;

            ------------  VALIDATION  ------------
            IF V_LOTTERY_TRANSACTION_TYPE='VALIDATION' then

                SELECT MAX(TX_HEADER_ID) into V_OPEN_TX_HEADER_ID FROM TXSTORE.MIGR_OPEN_TX_HEADER
                    where (GLOBAL_TRANS_ID=V_GLOBAL_TRANS_ID and  SERIAL=V_SERIAL)
                    or (CDC=V_CDC and SERIAL=V_SERIAL);
                IF V_OPEN_TX_HEADER_ID is not null then
                    SET V_IS_OPEN = TRUE;
                    insert into TXSTORE.MIGR_OPEN_TX_HEADER (TX_HEADER_ID,PLAYER_ID,UUID,GLOBAL_TRANS_ID,CDC,SERIAL)
                    values (V_TX_HEADER_ID,V_PLAYER_ID,V_UUID,V_GLOBAL_TRANS_ID,V_CDC,V_SERIAL);
                    IF (V_SQLCODE != 0) THEN
                        CALL SYSIBMADM.DBMS_OUTPUT.PUT_LINE('Open validation '||'ERROR WHILE INSERT #'||V_SQLCODE);
                    END IF;

                end if;
            end if;

        IF V_IS_OPEN = FALSE THEN
            SET V_JSON ='';
            IF V_PROJECT='KY' THEN
                SET V_JURISDICTION=16;
                SET V_CHANNEL_ID=5002;
                SET V_SYSTEM_ID=5008;
            elseif V_PROJECT='RI' THEN
                SET V_JURISDICTION=8;
                SET V_CHANNEL_ID=5002;
                SET V_SYSTEM_ID=5012;
                IF XMLEXISTS('$V_DATA/balanceTransaction/channel' PASSING V_DATA AS "V_DATA") THEN
                    SELECT XMLCAST(XMLQUERY('$V_DATA/balanceTransaction/channel/text()' PASSING V_DATA AS "V_DATA") AS INT) INTO V_CHANNEL_ID FROM SYSIBM.SYSDUMMY1;
                end if;
                IF XMLEXISTS('$V_DATA/balanceTransaction/sub-channel' PASSING V_DATA AS "V_DATA") THEN
                    SELECT XMLCAST(XMLQUERY('$V_DATA/balanceTransaction/sub-channel/text()' PASSING V_DATA AS "V_DATA") AS INT) INTO V_SYSTEM_ID FROM SYSIBM.SYSDUMMY1;
                end if;
            end if;
            CALL TXSTORE.RemoveXmlns(V_DATA);
            --             CALL SYSIBMADM.DBMS_OUTPUT.PUT_LINE('V_DATA' || XMLSERIALIZE(V_DATA AS VARCHAR(2000)));
            --- list of draw id`s ----
            if V_START_DRAW_NUMBER is null or V_END_DRAW_NUMBER is null then
                SET V_DRAW_IDS ='';
            else
                SET V_DRAW_ID = V_START_DRAW_NUMBER;
                SET V_DRAW_IDS ='';
                WHILE V_DRAW_ID <= V_END_DRAW_NUMBER DO
                        SET V_DRAW_IDS = V_DRAW_IDS || CAST(V_DRAW_ID AS VARCHAR(10));
                        IF V_DRAW_ID < V_END_DRAW_NUMBER THEN
                            SET V_DRAW_IDS = V_DRAW_IDS || ',';
                        END IF;
                        SET V_DRAW_ID = V_DRAW_ID + 1;
                    END WHILE;
            end if;

            ------------  WAGER  ------------
            IF V_LOTTERY_TRANSACTION_TYPE='WAGER' then
                --- multiplier ----
                IF XMLEXISTS('$V_DATA/balanceTransaction/details/wager-detail/multiplier' PASSING V_DATA AS "V_DATA") THEN
                    SELECT XMLCAST(XMLQUERY('$V_DATA/balanceTransaction/details/wager-detail/multiplier/text()' PASSING V_DATA AS "V_DATA") AS INT) INTO V_MULTIPLIER FROM SYSIBM.SYSDUMMY1;
                else
                    set V_MULTIPLIER=0;
                end if;
                IF V_PRODUCT IS NULL THEN SET V_PRODUCT = 0; end if;
                IF V_JOURNAL_ADDRESS IS NULL THEN SET V_JOURNAL_ADDRESS = 0; end if;
                SET V_JSON ='"{""drawGameWagerDetails"":{""trxLoyaltyPoints"":0,' ||
                                '""productNumber"": ' || V_PRODUCT || ',' ||
                                '""journalAddress"": ""' || V_JOURNAL_ADDRESS || '"",' ||
                                '""drawIds"": [' || V_DRAW_IDS || '],' ||
                                '""cardId"":""0"",'||
                                '""jurisdiction"":'||V_JURISDICTION||','||
                                '""multiplier"":'||V_MULTIPLIER||'},'||
                                '""drawGameBoards"":{""drawGameBoardDetails"":[';
                WHILE V_INDEX <= XMLCAST(XMLQUERY('count($V_DATA/balanceTransaction/details/wager-detail/board-data)' PASSING V_DATA AS "V_DATA") AS INT) DO
                        SET V_BOARD_DATA = XMLQUERY('$V_DATA/balanceTransaction/details/wager-detail/board-data[position() = $V_INDEX]' PASSING V_DATA AS "V_DATA", V_INDEX AS "V_INDEX");
                        SET V_VALUE = XMLCAST(XMLQUERY('fn:string($V_BOARD_DATA)' PASSING V_BOARD_DATA AS "V_BOARD_DATA") AS VARCHAR(100));
                        IF V_VALUE IS NOT NULL AND V_VALUE <> '' THEN
                            SET V_QP = XMLCAST(XMLQUERY('fn:string($V_BOARD_DATA/@qp)' PASSING V_BOARD_DATA AS "V_BOARD_DATA") AS VARCHAR(10));
                            SET V_BOARD_INDEX = CAST(V_INDEX AS INT) - 1;
                            IF V_INDEX > 1 THEN
                                SET V_JSON = V_JSON || ',{""boardIndex"":' || V_BOARD_INDEX || ',';
                            ELSE
                                SET V_JSON = V_JSON || '{""boardIndex"":' || V_BOARD_INDEX || ',';
                            END IF;
                            SET V_JSON = V_JSON || '""boardPrice"":0,' || '""stake"":0,' || '""betTypeId"":""0"",' || '""drawGameBoardSelections"":[';
                            IF LOCATE('-', V_VALUE) > 0 THEN
                                SET V_PRIMARY = SUBSTR(V_VALUE, 1, LOCATE(' - ', V_VALUE) - 1);
                                SET V_SECONDARY = SUBSTR(V_VALUE, LOCATE(' - ', V_VALUE) + 3);
                            ELSE
                                SET V_PRIMARY = V_VALUE;
                            END IF;
                            CALL TXSTORE.HANDLE_PART(V_PRIMARY, 'PRIMARY', V_PRIMARY_RESULT);
                            IF V_SECONDARY <> '' THEN
                                CALL TXSTORE.HANDLE_PART(V_SECONDARY, 'SECONDARY', V_SECONDARY_RESULT);
                            END IF;
                            SET V_RESULT = V_PRIMARY_RESULT;
                            IF V_SECONDARY_RESULT <> '' THEN
                                SET V_RESULT = V_RESULT || ',' || V_SECONDARY_RESULT;
                            END IF;
                            SET V_JSON = V_JSON || V_RESULT || ']}';
                        END IF;
                        SET V_INDEX = V_INDEX + 1;
                    END WHILE;
                IF V_PROJECT='KY' THEN
                    IF V_CDC IS NULL THEN SET V_CDC = 0; end if;
                    SET V_JSON = V_JSON||']}, ' ||
                        '""terminalSessionDetailsDTO"":{""sessionId"":0,""terminalId"":0,""retailerId"":0,""cdc"":'||V_CDC||'},'||
                        '""playerPreferences"":{""autopayWinnings"":false,""digitalTicketOnly"":false}}"';
                elseif V_PROJECT='RI' THEN
                    SET V_JSON = V_JSON||']}, ' ||
                        '""playerPreferences"":{""autopayWinnings"":false,""digitalTicketOnly"":false}}"';
                end if;
                ------------  VALIDATION  ------------
            ELSEIF V_LOTTERY_TRANSACTION_TYPE='VALIDATION' then
                --- draw date  ----
                IF XMLEXISTS('$V_DATA/balanceTransaction/details/validation-detail/win-details/win-detail[position() = 0]/draw-date' PASSING V_DATA AS "V_DATA") THEN
                    SELECT XMLCAST(XMLQUERY('$V_DATA/balanceTransaction/details/validation-detail/win-details/win-detail/draw-date/text()'
                                            PASSING V_DATA AS "V_DATA") AS VARCHAR(20)) INTO V_DRAW_DATE FROM SYSIBM.SYSDUMMY1;
                else
                    set V_DRAW_DATE=VARCHAR_FORMAT(CURRENT_DATE, 'YYYY-MM-DD') || 'Z';
                end if;
                --CALL SYSIBMADM.DBMS_OUTPUT.PUT_LINE('V_DRAW_DATE #'||V_DRAW_DATE);
                SELECT (DAYS(TIMESTAMP(SUBSTR(V_DRAW_DATE, 1, 10)))-DAYS(TIMESTAMP('1970-01-01'))) * 86400
                INTO V_UNIX_TIMESTAMP
                FROM SYSIBM.SYSDUMMY1;
                --- tier ----
                IF XMLEXISTS('$V_DATA/balanceTransaction/details/validation-detail/win-details/win-detail[position() = 0]/@tier' PASSING V_DATA AS "V_DATA") THEN
                    SELECT XMLCAST(XMLQUERY('$V_DATA/balanceTransaction/details/validation-detail/win-details/win-detail/@tier'
                                            PASSING V_DATA AS "V_DATA") AS VARCHAR(10)) INTO V_TIER FROM SYSIBM.SYSDUMMY1;
                else
                    set V_TIER='Low';
                end if;
                --CALL SYSIBMADM.DBMS_OUTPUT.PUT_LINE('V_TIER #'||V_TIER);
                ---  win-set ----
                IF XMLEXISTS('$V_DATA/balanceTransaction/details/validation-detail/win-details/win-detail[position() = 0]/win-set' PASSING V_DATA AS "V_DATA") THEN
                    SELECT XMLCAST(XMLQUERY('$V_DATA/balanceTransaction/details/validation-detail/win-details/win-detail/win-set/text()'
                                            PASSING V_DATA AS "V_DATA" ) AS INT) INTO V_WIN_SET FROM SYSIBM.SYSDUMMY1;
                else
                    set V_WIN_SET=0;
                end if;
                --CALL SYSIBMADM.DBMS_OUTPUT.PUT_LINE('V_WIN_SET #'||V_WIN_SET);
                --  draw ----
                IF XMLEXISTS('$V_DATA/balanceTransaction/details/validation-detail/win-details/win-detail[position() = 0]/draw' PASSING V_DATA AS "V_DATA") THEN
                    SELECT XMLCAST(XMLQUERY('$V_DATA/balanceTransaction/details/validation-detail/win-details/win-detail/draw/text()'
                                            PASSING V_DATA AS "V_DATA") AS INT) INTO V_DRAW FROM SYSIBM.SYSDUMMY1;
                else
                    set V_DRAW=0;
                end if;
                --  division ----
                IF XMLEXISTS('$V_DATA/balanceTransaction/details/validation-detail/win-details/win-detail[position() = 0]/division' PASSING V_DATA AS "V_DATA") THEN
                    SELECT XMLCAST(XMLQUERY('$V_DATA/balanceTransaction/details/validation-detail/win-details/win-detail/division/text()'
                                            PASSING V_DATA AS "V_DATA" ) AS INT) INTO V_DIVISION FROM SYSIBM.SYSDUMMY1;
                else
                    set V_DIVISION=0;
                end if;
                --  global transaction id ----
                if V_GLOBAL_TRANS_ID is null then
                    SET V_GLOBAL_TRANS_ID = '';
                end if;
                SET V_JSON='"{""drawGameWagerDetails"":'||
                            '{""drawTimes"":['||V_UNIX_TIMESTAMP||'],'||
                            '""drawIds"":['||V_DRAW_IDS||']},'||
                            '""drawGameValidationDetails"":'||
                            '{""prizeTier"":""'||V_TIER||'"",'||
                            '""jurisdiction"":'||V_JURISDICTION||','||
                            '""refExternalId"":""'||V_GLOBAL_TRANS_ID||'"",'||
                            '""validationType"":""CASH"",'||
                            '""winSet"":'||V_WIN_SET||','||
                            '""drawNumber"":'||V_DRAW||','||
                            '""prizeType"":""CASH"",'||
                            '""winningDivision"":'||V_DIVISION||'}}"';
            end if;
            INSERT INTO TXSTORE.MIGRATED_TX_JSON (uuid,json
            ) VALUES (V_UUID,V_JSON);
            IF (V_SQLCODE != 0) THEN
                CALL SYSIBMADM.DBMS_OUTPUT.PUT_LINE('ERROR WHILE INSERT #'||V_SQLCODE);
            END IF;
            SET V_SERIAL_NUMBER = V_CDC||'-'||V_SERIAL||'-'||V_PRODUCT;
            if V_CORRELATION_ID is null then
                SET V_CORRELATION_ID='';
            end if;
            if V_GLOBAL_TRANS_ID is null then
                SET V_GLOBAL_TRANS_ID='';
            end if;
            insert into TXSTORE.MIGRATED_TX_TRANSACTION (TX_TRANSACTION_ID, GLOBAL_TRANS_ID, CORRELATION_ID,
                                                         UUID, PLAYER_ID,TRANSACTION_TIME, TRANSACTION_TYPE, CHANNEL_ID, SYSTEM_ID, TRANSACTION_AMOUNT,
                                                         TRANSACTION_DISCOUNT_AMOUNT, CURRENCY, SERIAL, CDC, GAME_ENGINE_TRANSACTION_TIME,
                                                         PRODUCT_ID, START_DRAW_NUMBER, END_DRAW_NUMBER, SITE_JSON_DATA,
                                                         SERIAL_NUMBER,winningDivision)
            values (V_TX_HEADER_ID,V_GLOBAL_TRANS_ID,V_CORRELATION_ID, V_UUID, V_PLAYER_ID,
                    V_TRANSACTION_TIME_UTC, V_LOTTERY_TRANSACTION_TYPE,V_CHANNEL_ID,V_SYSTEM_ID,V_TRANSACTION_AMOUNT,
                    NULL,'USD', V_SERIAL, V_CDC,V_TRANSACTION_TIME_LOCAL,V_PRODUCT,V_START_DRAW_NUMBER,V_END_DRAW_NUMBER,
                    null,V_SERIAL_NUMBER,V_DIVISION);
            IF (V_SQLCODE != 0) THEN
                CALL SYSIBMADM.DBMS_OUTPUT.PUT_LINE('ERROR WHILE INSERT #'||V_SQLCODE);
            END IF;
        end if;
        IF(V_COUNT_COMMIT = 10000) THEN
            SET V_COUNT_COMMIT = 1;
            COMMIT ;
        ELSE
            SET V_COUNT_COMMIT = V_COUNT_COMMIT + 1;
        end if;
        SET V_INDEX=1;
        SET V_SQLCODE = 0;
        FETCH MIGRATED_TX_CURSOR
            INTO V_TX_HEADER_ID,V_GLOBAL_TRANS_ID,V_CORRELATION_ID,V_UUID,V_PLAYER_ID,V_TRANSACTION_TIME_UTC,
                V_LOTTERY_TRANSACTION_TYPE,V_TRANSACTION_AMOUNT,V_SERIAL,V_CDC,V_TRANSACTION_TIME_LOCAL,
                V_PRODUCT,V_START_DRAW_NUMBER,V_END_DRAW_NUMBER,V_SUBSCRIPTION_ID,V_JOURNAL_ADDRESS,V_DATA;
        IF (V_SQLCODE <> 0) THEN
            CALL SYSIBMADM.DBMS_OUTPUT.PUT_LINE(
                        'Finish reading the cursor.' || V_SQLCODE);
        END IF;


        END WHILE;
    CLOSE MIGRATED_TX_CURSOR;
    CALL SYSIBMADM.DBMS_OUTPUT.PUT_LINE('Close the "MIGRATED_TX_CURSOR" cursor.');
END
@