BEGIN DECLARE CONTINUE HANDLER FOR SQLSTATE '42710' BEGIN END;
    EXECUTE IMMEDIATE '
    create table TXSTORE.MIGRATED_TX_JSON
    (
        UUID VARCHAR(200),
        JSON VARCHAR(20000)
    )';
END
@