/*
 * Copyright © 2023 IGT.
 *
 * This software and all information contained therein is confidential and proprietary
 * and shall not be duplicated, used, disclosed or disseminated in any way except as
 * authorized by the applicable license agreement, without the express written permission of IGT.
 * All authorized reproductions must be marked with this language.
 */
package com.igt.plt.fav;

import org.springframework.jdbc.core.RowMapper;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * Created by TSENDELA on 2023-02-01.
 */
public class FavRowMapper implements RowMapper<FavRecord>{
    @Override
    public FavRecord mapRow(ResultSet rs, int rowNum) throws SQLException{
        final long favId = rs.getLong("IDDGFAVORITEWAGER");
        final long favNr = rs.getLong("IDDGFAVORITEWAGERNUMBER");
        final int duration = rs.getInt("NUMBEROFDRAWS");
        final long gameId = rs.getLong("IDDGGAME");
        final String playerId = rs.getString("PLAYERID");
        final long price = rs.getLong("TOTALPRICE");
        final long stake = rs.getLong("STAKE");
        final Date tsCreated = rs.getDate("TSCREATED");
        final Date tsLastModified = rs.getDate("TSLASTMODIFIED");
        final long favBsId = rs.getLong("IDDGFAVORITEBOARDSTACK");
        final SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
        return new FavRecord(favId //
                , favNr //
                , duration //
                , gameId //
                , playerId //
                , price //
                , stake //
                , sdf.format(tsCreated) //
                , sdf.format(tsLastModified) //
                , favBsId);
    }
}
