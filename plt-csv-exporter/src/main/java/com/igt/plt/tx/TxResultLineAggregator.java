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
 * Created by TSENDELA on 2023-02-16.
 */
public class TxResultLineAggregator implements LineAggregator<TxResultRecord>{
    @Override
    public String aggregate(TxResultRecord item){
        String returned = String.valueOf(item.getDrawId());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getGameId());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getPrizeAmount());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getTsCreated());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getTsModified());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getTxDrawEntryId());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getValidationUuid());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getClaimId());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getPrizeDescription());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getPrizeType());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getWinningBoardIndex());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getWinningDivision());
        return returned;
    }
}
