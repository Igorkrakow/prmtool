BEGIN DECLARE CONTINUE HANDLER FOR SQLSTATE '42710' BEGIN END;
    EXECUTE IMMEDIATE '
create table TXSTORE.MIGRATION_ERRORS
                       (TABLE_NAME VARCHAR(30),
                        ID         BIGINT,
                        STATUS     VARCHAR(300))';
END
@
