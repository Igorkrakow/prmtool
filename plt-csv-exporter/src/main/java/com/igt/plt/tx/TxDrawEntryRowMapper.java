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

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

/**
 * @author mpielak
 */
public class TxDrawEntryRowMapper implements RowMapper<TxDrawEntryRecord>{
    private final Map<Long, Integer> currDraws = new HashMap<>();
    private final Set<Long> closed = new HashSet<>(Arrays.asList(11L, 21L, 22L));

    public TxDrawEntryRowMapper(String currDrawsString){
        for(String s : currDrawsString.split(",")){
            String[] second = s.split(":");
            currDraws.put(Long.valueOf(second[0]), Integer.valueOf(second[1]));
        }
    }

    @Override
    public TxDrawEntryRecord mapRow(ResultSet rs, int i) throws SQLException{
        final Long txDrawEntryId = rs.getLong("ID");
        final String txTransactionUuid = rs.getString("UUID");
        final Long drawId = rs.getLong("DRAWNUMBER");
        final Long productId = rs.getLong("PRODUCT");
        final boolean open;
        if(closed.contains(productId)) open = false;
        else open = drawId >= currDraws.get(productId);
        final String winningStatus = open ? "OPEN" : "NON_WINNING";
        return new TxDrawEntryRecord(txDrawEntryId, txTransactionUuid, drawId, productId, winningStatus);
    }
}
