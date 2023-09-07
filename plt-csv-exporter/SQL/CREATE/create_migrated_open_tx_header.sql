BEGIN DECLARE CONTINUE HANDLER FOR SQLSTATE '42710' BEGIN END;
    EXECUTE IMMEDIATE '
create table TXSTORE.MIGR_OPEN_TX_HEADER(
                         TX_HEADER_ID BIGINT not null
                                      constraint XPKMIGR_TX_HEADER
                                           primary key,
                         PLAYER_ID    BIGINT not null,
                         UUID         VARCHAR(200),
                         GLOBAL_TRANS_ID VARCHAR(50),
                         CDC INTEGER,
                         SERIAL BIGINT)';
END
@
BEGIN DECLARE CONTINUE HANDLER FOR SQLSTATE '01550' BEGIN END;
EXECUTE IMMEDIATE 'create unique index TXSTORE.UQIDXMIGR_OPEN_TX_HEADER
    on TXSTORE.MIGR_OPEN_TX_HEADER (UUID)';
END
@
BEGIN DECLARE CONTINUE HANDLER FOR SQLSTATE '01550' BEGIN END;
EXECUTE IMMEDIATE 'create index TXSTORE.XIDXMIGR_OPEN_TX_HEADERPLAYERID
    on TXSTORE.MIGR_OPEN_TX_HEADER (PLAYER_ID)';
END
@