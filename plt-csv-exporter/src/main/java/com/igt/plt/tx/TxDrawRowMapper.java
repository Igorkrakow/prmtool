/*
 * Copyright © 2023 IGT.
 *
 * This software and all information contained therein is confidential and proprietary
 * and shall not be duplicated, used, disclosed or disseminated in any way except as
 * authorized by the applicable license agreement, without the express written permission of IGT.
 * All authorized reproductions must be marked with this language.
 */
package com.igt.plt.tx;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import org.springframework.jdbc.core.RowMapper;

/**
 * Created by TSENDELA on 2023-02-14.
 */
public class TxDrawRowMapper implements RowMapper<TxDrawRecord>{
    private final Map<Long, Integer> currDraws = new HashMap<>();
    private final Set<Long> closed = new HashSet<>(Arrays.asList(11L, 21L, 22L));

    public TxDrawRowMapper(String currDrawsString){
        for(String s : currDrawsString.split(",")){
            String[] second = s.split(":");
            currDraws.put(Long.valueOf(second[0]), Integer.valueOf(second[1]));
        }
    }

    @Override
    public TxDrawRecord mapRow(ResultSet rs, int rowNum) throws SQLException{
        final Long gameId = rs.getLong("IDDGGAME");
        final Long drawId = rs.getLong("DRAWNUMBER");
        final SimpleDateFormat SDF = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
        final String drawTime = SDF.format(rs.getDate("DRAWDATE"));
        final boolean open;
        if(closed.contains(gameId)) open = false;
        else open = drawId >= currDraws.get(gameId);
        return new TxDrawRecord(gameId, drawId, drawTime, open ? "OPEN" : "CLOSE");
    }
}
