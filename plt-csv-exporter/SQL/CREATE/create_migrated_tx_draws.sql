BEGIN DECLARE CONTINUE HANDLER FOR SQLSTATE '42710' BEGIN END;
    EXECUTE IMMEDIATE '
    CREATE TABLE TXSTORE.MIGRATED_TX_DRAWS (
                          IDDGGAME bigint not null,
                          DRAWNUMBER INTEGER not null
                          )';
END
@
