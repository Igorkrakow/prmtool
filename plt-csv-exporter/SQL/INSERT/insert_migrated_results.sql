INSERT INTO TXSTORE.MIGRATED_RESULTS( ID, LOTTERY_TX_HEADER_ID,DRAWNUMBER,PRODUCT,TRANSACTION_AMOUNT,TRANSACTION_TIME_UTC,TX_DRAW_ENTRY_ID,UUID,WINNINGDIVISION)
SELECT TXSTORE.MIGRATED_RESULTS_SEQ.NEXTVAL,LTV.TX_TRANSACTION_ID,DE.DRAWNUMBER,LTV.PRODUCT_ID,LTV.TRANSACTION_AMOUNT,LTV.TRANSACTION_TIME,DE.ID,ltv.UUID,ltv.WINNINGDIVISION
    FROM TXSTORE.MIGRATED_TX_TRANSACTION LTV
             JOIN TXSTORE.LOTTERY_TX_HEADER LTW
                  ON LTV.GLOBAL_TRANS_ID = LTW.GLOBAL_TRANS_ID
                      AND LTV.SERIAL = LTW.SERIAL
                      AND LTW.LOTTERY_TRANSACTION_TYPE = 'WAGER'
             JOIN TXSTORE.TX_HEADER TH
                  ON LTW.LOTTERY_TX_HEADER_ID = TH.TX_HEADER_ID
             JOIN TXSTORE.MIGRATED_TX_DRAW_ENTRY DE
                  ON TH.UUID = DE.UUID
                      AND DE.DRAWNUMBER = LTV.START_DRAW_NUMBER
    WHERE ltv.TRANSACTION_TYPE = 'VALIDATION'
    @
INSERT INTO TXSTORE.MIGRATED_RESULTS( ID, LOTTERY_TX_HEADER_ID,DRAWNUMBER,PRODUCT,TRANSACTION_AMOUNT,TRANSACTION_TIME_UTC,TX_DRAW_ENTRY_ID,UUID,WINNINGDIVISION)
    SELECT TXSTORE.MIGRATED_RESULTS_SEQ.NEXTVAL,LTV.TX_TRANSACTION_ID,DE.DRAWNUMBER,LTV.PRODUCT_ID,LTV.TRANSACTION_AMOUNT,LTV.TRANSACTION_TIME,DE.ID,LTV.UUID,ltv.WINNINGDIVISION
    FROM TXSTORE.MIGRATED_TX_TRANSACTION LTV
             JOIN TXSTORE.LOTTERY_TX_HEADER LTW
                  ON LTV.CDC = LTW.CDC
                      AND LTV.SERIAL = LTW.SERIAL
                      AND LTW.LOTTERY_TRANSACTION_TYPE = 'WAGER'
             JOIN TXSTORE.TX_HEADER TH
                  ON LTW.LOTTERY_TX_HEADER_ID = TH.TX_HEADER_ID
             JOIN TXSTORE.MIGRATED_TX_DRAW_ENTRY DE
                  ON TH.UUID = DE.UUID
                      AND DE.DRAWNUMBER = LTV.START_DRAW_NUMBER
    where  ltv.TRANSACTION_TYPE = 'VALIDATION'
      and NOT EXISTS (SELECT 1
                      FROM TXSTORE.MIGRATED_RESULTS mr
                      WHERE LTV.TX_TRANSACTION_ID = mr.LOTTERY_TX_HEADER_ID
    )
@



