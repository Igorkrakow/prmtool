/*
 * Copyright © 2023 IGT.
 *
 * This software and all information contained therein is confidential and proprietary
 * and shall not be duplicated, used, disclosed or disseminated in any way except as
 * authorized by the applicable license agreement, without the express written permission of IGT.
 * All authorized reproductions must be marked with this language.
 */
package com.igt.plt.tx;

import org.springframework.batch.item.file.transform.LineAggregator;

import static com.igt.plt.common.PltCsvExporterUtils.SEPARATOR;
import static com.igt.plt.common.PltCsvExporterUtils.emptyIfNull;

/**
 * Created by TSENDELA on 2023-02-06.
 */
public class TxLineAggregator implements LineAggregator<TxRecord> {

    @Override
    public String aggregate(TxRecord item) {
        String returned = String.valueOf(item.getTransactionId());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getGlobalTransId());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getCorrelationId());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getUuid());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getPlayerId());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getTransactionTime());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getTransactionType());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getChannelId());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getSystemId());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getTransactionAmount());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getTransactionDiscountAmount());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getCurrency());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getSerial());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getCdc());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getGameEngineTransactionTime());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getGameId());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getStartDrawNr());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getEndDrawNr());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getSiteJsonData());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getSerialNr());
        return returned;
    }
}
