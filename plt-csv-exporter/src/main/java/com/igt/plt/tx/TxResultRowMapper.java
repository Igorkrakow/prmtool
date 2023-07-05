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
import java.text.SimpleDateFormat;

/**
 * Created by TSENDELA on 2023-02-16.
 */
public class TxResultRowMapper implements RowMapper<TxResultRecord>{
    @Override
    public TxResultRecord mapRow(ResultSet rs, int rowNum) throws SQLException{
        final Long drawId = rs.getLong("DRAWNUMBER");
        final Long gameId = rs.getLong("PRODUCT");
        final Long prizeAmount = rs.getLong("TRANSACTION_AMOUNT");
        final SimpleDateFormat SDF = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
        final String tsCreated = SDF.format(rs.getDate("TRANSACTION_TIME_UTC"));
        final String tsModified = tsCreated;
        final Long txDrawEntryId = rs.getLong("TX_DRAW_ENTRY_ID");
        final String validationUuid = rs.getString("UUID");
        final String xml = rs.getString("DATA");
        return new TxResultRecord(drawId, gameId, prizeAmount, tsCreated, tsModified, txDrawEntryId, validationUuid, xml);
    }
}
