/*
 * Copyright © 2023 IGT.
 *
 * This software and all information contained therein is confidential and proprietary
 * and shall not be duplicated, used, disclosed or disseminated in any way except as
 * authorized by the applicable license agreement, without the express written permission of IGT.
 * All authorized reproductions must be marked with this language.
 */
package com.igt.plt.tx;

import org.springframework.batch.item.database.ItemPreparedStatementSetter;

import java.sql.PreparedStatement;
import java.sql.SQLException;

/**
 * Created by TSENDELA on 2023-02-20.
 */
public class TxGrouppedPreparedStatementSetter implements ItemPreparedStatementSetter<TxRecord>{
    @Override
    public void setValues(TxRecord item, PreparedStatement ps) throws SQLException{
        ps.setString(1, item.getCorrelationId());
        ps.setString(2, item.getGlobalTransId());
    }
}
