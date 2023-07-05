/*
 * Copyright © 2023 IGT.
 *
 * This software and all information contained therein is confidential and proprietary
 * and shall not be duplicated, used, disclosed or disseminated in any way except as
 * authorized by the applicable license agreement, without the express written permission of IGT.
 * All authorized reproductions must be marked with this language.
 */
package com.igt.plt.sub;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;

import org.springframework.jdbc.core.RowMapper;

/**
 * Created by TSENDELA on 2023-01-25.
 */
public class SubRowMapper implements RowMapper<SubRecord> {

    @Override
    public SubRecord mapRow(ResultSet rs, int rowNum) throws SQLException{
        final long subId = rs.getLong("IDDGSUBSCRIPTION");
        final String playerId = rs.getString("PLAYERID");
        final long gameId = rs.getLong("IDDGGAME");
        final int startCdc = rs.getInt("STARTCDC");
        final int cdcCreated = rs.getInt("CDCCREATED");
        final Date tsCreated = rs.getDate("TSCREATED");
        final Date tsLastModified = rs.getDate("TSLASTMODIFIED");
        final String txUid = rs.getString("TXUID");
        final long wagerAmount = rs.getLong("WAGERAMOUNT");
        final long boardStackId = rs.getLong("IDDGBOARDSTACK");
        final SimpleDateFormat SDF = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
        final SubRecord returned = new SubRecord(subId //
                , playerId //
                , gameId //
                , startCdc //
                , cdcCreated //
                , SDF.format(tsCreated) //
                , SDF.format(tsLastModified) //
                , txUid //
                , wagerAmount //
                , boardStackId);
        return returned;
    }
}
