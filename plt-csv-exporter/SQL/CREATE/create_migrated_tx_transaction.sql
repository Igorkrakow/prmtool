BEGIN DECLARE CONTINUE HANDLER FOR SQLSTATE '42710' BEGIN END;
    EXECUTE IMMEDIATE 'CREATE TABLE TXSTORE.MIGRATED_TX_TRANSACTION (
                            tx_transaction_id bigint NOT NULL,
                            global_trans_id varchar(50) NULL,
                            correlation_id varchar(60) NOT NULL,
                            uuid varchar(200) NOT NULL,
                            player_id bigint NOT NULL,
                            transaction_time timestamp NOT NULL,
                            transaction_type varchar(25) NOT NULL,
                            channel_id varchar(25) NULL,
                            system_id varchar(25) NULL,
                            transaction_amount bigint NULL,
                            transaction_discount_amount int NULL,
                            currency varchar(10) NULL,
                            serial varchar(50) NULL,
                            cdc int NULL,
                            game_engine_transaction_time timestamp NULL,
                            product_id smallint NULL,
                            start_draw_number int NULL,
                            end_draw_number int NULL,
                            site_json_data varchar(100) NULL,
                            serial_number varchar(50) NULL,
                            winningDivision int NULL)';
END
@
BEGIN DECLARE CONTINUE HANDLER FOR SQLSTATE '01550' BEGIN END;
EXECUTE IMMEDIATE 'CREATE INDEX TXSTORE.MIGRATED_TX_TRANSACTION_TX_TRANSACTION_ID
    on TXSTORE.MIGRATED_TX_TRANSACTION (TX_TRANSACTION_ID)';
END
@