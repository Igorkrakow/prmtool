/*
 * Copyright © 2023 IGT.
 *
 * This software and all information contained therein is confidential and proprietary
 * and shall not be duplicated, used, disclosed or disseminated in any way except as
 * authorized by the applicable license agreement, without the express written permission of IGT.
 * All authorized reproductions must be marked with this language.
 */
package com.igt.plt.sub;

import org.springframework.batch.item.file.transform.LineAggregator;

import static com.igt.plt.common.PltCsvExporterUtils.SEPARATOR;
import static com.igt.plt.common.PltCsvExporterUtils.emptyIfNull;
import static com.igt.plt.common.PltCsvExporterUtils.emptyIfNullWrapped;

/**
 * Created by TSENDELA on 2023-01-27.
 */
public class BoardLineAggregator implements LineAggregator<BoardRecord> {
    @Override
    public String aggregate(BoardRecord item){
        String returned = String.valueOf(item.getBoardId());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getBoardStackId());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getBoardStake());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getPickSystem());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getNumberOfQuickPickMarks());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getNumberOfSecondaryQuickPickMarks());
        returned += SEPARATOR;
        returned += emptyIfNullWrapped(item.getPickValues());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getBoardIndex());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getModifier());
        return returned;
    }
}
