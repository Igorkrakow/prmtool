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
public class FavLineAggregator implements LineAggregator<FavRecord>{
    @Override
    public String aggregate(FavRecord item){
        String returned = String.valueOf(item.getFavId());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getFavNr());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getDuration());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getGameId());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getPlayerId());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getPrice());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getStake());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getName());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getTsCreated());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getTsLastModified());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getGroupId());
        returned += SEPARATOR;
        return returned;
    }
}
