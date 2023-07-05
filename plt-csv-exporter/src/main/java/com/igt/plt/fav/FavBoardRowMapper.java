/*
 * Copyright © 2023 IGT.
 *
 * This software and all information contained therein is confidential and proprietary
 * and shall not be duplicated, used, disclosed or disseminated in any way except as
 * authorized by the applicable license agreement, without the express written permission of IGT.
 * All authorized reproductions must be marked with this language.
 */
package com.igt.plt.fav;

import java.sql.ResultSet;
import java.sql.SQLException;

import org.springframework.jdbc.core.RowMapper;

/**
 * Created by TSENDELA on 2023-02-02.
 */
public class FavBoardRowMapper implements RowMapper<FavBoardRecord>{
    @Override
    public FavBoardRecord mapRow(ResultSet rs, int rowNum) throws SQLException{
        final long favBoardId = rs.getLong("IDDGFAVORITEBOARD");
        final long favBsId = rs.getLong("IDDGFAVORITEBOARDSTACK");
        final long stake = rs.getLong("BOARDSTAKE");
        final String pickSystem = rs.getString("PICKSYSTEM");
        final int numberOfQuickPickMarks = rs.getInt("NUMBEROFQUICKPICKMARKS");
        final int numberOfSecondaryQuickPickMarks = rs.getInt("NROFSECONDARYQUICKPICKMARKS");
        final String pickValues = rs.getString("PICKVALUES");
        final String primarySelections, secondarySelections;
        if(pickValues.contains(":")){
            final String[] split = pickValues.split(":");
            primarySelections = split[0];
            secondarySelections = split[1];
        }else{
            primarySelections = pickValues;
            secondarySelections = null;
        }
        final int boardIndex = rs.getInt("BOARDINDEX");
        final boolean modifier = rs.getBoolean("MODIFIER");
        return new FavBoardRecord(favBoardId //
                , favBsId //
                , stake //
                , pickSystem //
                , numberOfQuickPickMarks //
                , numberOfSecondaryQuickPickMarks //
                , primarySelections //
                , secondarySelections //
                , boardIndex //
                , modifier);
    }
}
