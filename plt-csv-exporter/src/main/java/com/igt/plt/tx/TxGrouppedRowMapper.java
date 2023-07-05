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

/**
 * Created by TSENDELA on 2023-02-21.
 */
public class TxGrouppedRowMapper implements RowMapper<TxRecord>{
    @Override
    public TxRecord mapRow(ResultSet rs, int rowNum) throws SQLException{
        final String globalTransId = rs.getString("GLOBAL_TRANS_ID");
        return new TxRecord(null, globalTransId, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
    }
}
