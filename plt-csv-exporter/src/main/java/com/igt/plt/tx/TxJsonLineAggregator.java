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
import static com.igt.plt.common.PltCsvExporterUtils.emptyIfNullWrapped;

/**
 * @author mpielak
 */
public class TxJsonLineAggregator implements LineAggregator<TxRecord> {
    @Override
    public String aggregate(TxRecord item) {
        String returned = String.valueOf(item.getUuid());
        returned += SEPARATOR;
        returned += emptyIfNullWrapped(item.getJson());
        return returned;
    }
}
