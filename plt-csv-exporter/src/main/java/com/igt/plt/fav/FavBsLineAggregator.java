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

/**
 * Created by TSENDELA on 2023-02-01.
 */
public class FavBsLineAggregator implements LineAggregator<FavRecord>{
    @Override
    public String aggregate(FavRecord item){
        String returned = String.valueOf(item.getFavId());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getFavBsId());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getGameId());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getDrawNames());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getAddonStake());
        returned += SEPARATOR;
        returned += emptyIfNull(item.isAddon());
        return returned;
    }
}
