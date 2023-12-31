BEGIN DECLARE CONTINUE HANDLER FOR SQLSTATE '42710' BEGIN END;
EXECUTE IMMEDIATE 'CREATE TABLE TXSTORE.TMP_TSO_PURCHASE
(
    WAGER_TRANSACTION_ID BIGINT,
    PLAYER_ID            BIGINT,
    STATUS               varchar(50),
    TRANSACTION_DATE     TIMESTAMP,
    UUID                 VARCHAR(200),
    PRODUCT              SMALLINT,
    AMOUNT               BIGINT,
    GLOBAL_TRANS_ID      VARCHAR(50),
    START_DATE_RUN       TIMESTAMP,
    END_DATE_RUN         TIMESTAMP,
    START_DATE_UPDATE    TIMESTAMP,
    END_DATE_UPDATE      TIMESTAMP,
    DELTA                VARCHAR(1),
    INSERT_TIME          TIMESTAMP WITH DEFAULT CURRENT_TIMESTAMP
)';
END
@
