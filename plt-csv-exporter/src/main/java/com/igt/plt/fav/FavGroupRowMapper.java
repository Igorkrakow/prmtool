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
public class FavGroupRowMapper implements RowMapper<FavGroupRecord>{
    @Override
    public FavGroupRecord mapRow(ResultSet rs, int rowNum) throws SQLException{
        final long favGroupId = rs.getLong("IDDGFAVORITEWAGERGROUP");
        final String favGroupNr = rs.getString("IDDGFAVORITEWAGERGROUPNUMBER");
        final String favGroupName = rs.getString("IDDGFAVORITEWAGERGROUPNAME");
        final long playerId = rs.getLong("PLAYERID");
        return new FavGroupRecord(favGroupId //
                , favGroupNr //
                , favGroupName //
                , playerId);
    }
}
