/*
 * Copyright © 2023 IGT.
 *
 * This software and all information contained therein is confidential and proprietary
 * and shall not be duplicated, used, disclosed or disseminated in any way except as
 * authorized by the applicable license agreement, without the express written permission of IGT.
 * All authorized reproductions must be marked with this language.
 */
package com.igt.plt.sub;

import org.springframework.jdbc.core.RowMapper;

import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Created by TSENDELA on 2023-01-27.
 */
public class BoardRowMapper implements RowMapper<BoardRecord>{
    @Override
    public BoardRecord mapRow(ResultSet rs, int rowNum) throws SQLException{
        final long boardId = rs.getLong("IDDGBOARD");
        final long boardStackId = rs.getLong("IDDGBOARDSTACK");
        final long boardStake = rs.getLong("BOARDSTAKE");
        final String pickSystem = rs.getString("PICKSYSTEM");
        final int numberOfQuickPickMarks = rs.getInt("NUMBEROFQUICKPICKMARKS");
        final int numberOfSecondaryQuickPickMarks = rs.getInt("NROFSECONDARYQUICKPICKMARKS");
        final String pickValues = rs.getString("PICKVALUES");
        final int boardIndex = rs.getInt("BOARDINDEX");
        final String modifier = rs.getString("MODIFIER");
        final BoardRecord returned = new BoardRecord(boardId //
                , boardStackId //
                , boardStake //
                , pickSystem //
                , numberOfQuickPickMarks //
                , numberOfSecondaryQuickPickMarks //
                , pickValues //
                , boardIndex //
                , modifier);
        return returned;
    }
}
