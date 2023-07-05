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
public class TxExtractPreparedStatementSetter implements ItemPreparedStatementSetter<TxRecord>{
    @Override
    public void setValues(TxRecord item, PreparedStatement ps) throws SQLException{
        final Long transactionId = item.getTransactionId();
        ps.setLong(1, transactionId);
        ps.setString(2, item.getGlobalTransId());
        ps.setString(3, item.getUuid());
        ps.setString(4, item.getPlayerId());
        ps.setString(5, item.getTransactionTime());
        ps.setString(6, item.getTransactionType());
        ps.setLong(7, item.getTransactionAmount());
        ps.setInt(8, item.getSerial());
        ps.setInt(9, item.getCdc());
        ps.setString(10, item.getGameEngineTransactionTime());
        ps.setLong(11, item.getGameId());
        ps.setInt(12, item.getStartDrawNr());
        ps.setInt(13, item.getEndDrawNr());
        ps.setString(14, item.getJson());
        ps.setLong(15, item.getSubscriptionId());
        ps.setString(16, item.getJournalAddress());
    }
}
