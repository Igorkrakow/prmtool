/*
 * Copyright © 2023 IGT.
 *
 * This software and all information contained therein is confidential and proprietary
 * and shall not be duplicated, used, disclosed or disseminated in any way except as
 * authorized by the applicable license agreement, without the express written permission of IGT.
 * All authorized reproductions must be marked with this language.
 */
package com.igt.plt.tx;

import org.springframework.jdbc.core.RowMapper;

import java.sql.Date;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

/**
 * Created by TSENDELA on 2023-02-06.
 */
public class TxRowMapper implements RowMapper<TxRecord>{
    private final Map<Long, Integer> currDraws = new HashMap<>();
    private final Set<Long> closed = new HashSet<>(Arrays.asList(36L));
    public TxRowMapper(String currDrawsString){
        for(String s : currDrawsString.split(",")){
            String[] second = s.split(":");
            currDraws.put(Long.valueOf(second[0]), Integer.valueOf(second[1]));
        }
    }

    @Override
    public TxRecord mapRow(ResultSet rs, int rowNum) throws SQLException{
        final SimpleDateFormat SDF = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
        final Long subscriptionId = rs.getLong("SUBSCRIPTION_ID");
        final long transactionId = rs.getLong("TX_HEADER_ID");
        final String globalTransId = rs.getString("GLOBAL_TRANS_ID");
        final String correlationId = rs.getString("CORRELATION_ID");
        final String uuid = rs.getString("UUID");
        final String journalAddress = rs.getString("JOURNAL_ADDRESS");
        final String playerId = rs.getString("PLAYER_ID");
        Date transaction_time_utc = rs.getDate("TRANSACTION_TIME_UTC");
        Long transactionUtcTime = transaction_time_utc.getTime();
        final String transactionTime = SDF.format(transaction_time_utc);
        final String transactionType = rs.getString("LOTTERY_TRANSACTION_TYPE");
        final Long transactionAmount = rs.getLong("TRANSACTION_AMOUNT");
        final Integer cdc = rs.getInt("CDC");
        final String gameEngineTransactionTime = SDF.format(rs.getDate("TRANSACTION_TIME_LOCAL"));
        final Long gameId = rs.getLong("PRODUCT");
        final Integer startDrawNr = rs.getInt("START_DRAW_NUMBER");
        final Integer endDrawNr = rs.getInt("END_DRAW_NUMBER");
        final Integer serial;
        final String serialNr;

        //TO_CLARIFY
        serial = rs.getInt("SERIAL");
        serialNr = cdc + "-" + serial + "-" + getProductId(gameId);

        final String json = rs.getString("DATA");
        return new TxRecord(transactionId, globalTransId, correlationId, uuid, journalAddress, playerId, transactionTime, transactionType, null, null //
                , transactionAmount, subscriptionId, serial, cdc, gameEngineTransactionTime, gameId, startDrawNr, endDrawNr, serialNr, json, transactionUtcTime);
    }

    protected String getProductId(Long gameId){
        String productId = gameId.toString();
        return productId.length() == 1 ? "0" + productId : productId;
    }

    protected boolean transactionFromSubscription(Long subscriptionId){
        return subscriptionId != null && subscriptionId != 0L;
    }
}
