/*
 * Copyright © 2023 IGT.
 *
 * This software and all information contained therein is confidential and proprietary
 * and shall not be duplicated, used, disclosed or disseminated in any way except as
 * authorized by the applicable license agreement, without the express written permission of IGT.
 * All authorized reproductions must be marked with this language.
 */
package com.igt.plt.fav;

import org.springframework.batch.item.file.transform.LineAggregator;

import static com.igt.plt.common.PltCsvExporterUtils.SEPARATOR;
import static com.igt.plt.common.PltCsvExporterUtils.emptyIfNull;
import static com.igt.plt.common.PltCsvExporterUtils.emptyIfNullWrapped;

/**
 * Created by TSENDELA on 2023-02-02.
 */
public class FavBoardLineAggregator implements LineAggregator<FavBoardRecord>{
    @Override
    public String aggregate(FavBoardRecord item){
        String returned = String.valueOf(item.getFavBoardId());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getFavBsId());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getStake());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getPickSystem());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getNumberOfQuickPickMarks());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getNumberOfSecondaryQuickPickMarks());
        returned += SEPARATOR;
        returned += emptyIfNullWrapped(item.getPrimarySelections());
        returned += SEPARATOR;
        returned += emptyIfNullWrapped(item.getSecondarySelections());
        returned += SEPARATOR;
        returned += emptyIfNullWrapped(item.getTertiarySelections());
        returned += SEPARATOR;
        returned += emptyIfNullWrapped(item.getAddonSelections());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getBoardIndex());
        returned += SEPARATOR;
        returned += emptyIfNull(item.isModifier());
        return returned;
    }
}
