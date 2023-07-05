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
 * Created by TSENDELA on 2023-02-15.
 */
public class TxDrawLineAggregator implements LineAggregator<TxDrawRecord>{
    @Override
    public String aggregate(TxDrawRecord item){
        String returned = String.valueOf(item.getGameId());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getDrawId());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getDrawName());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getDrawTime());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getDrawStatus());
        return returned;
    }
}
