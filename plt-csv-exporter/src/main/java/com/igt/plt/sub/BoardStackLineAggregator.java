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

/**
 * Created by TSENDELA on 2023-01-27.
 */
public class BoardStackLineAggregator implements LineAggregator<SubRecord>{
    @Override
    public String aggregate(SubRecord item){
        String returned = String.valueOf(item.getBoardStackId());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getGameId());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getWagerId());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getSubId());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getExtraStake());
        returned += SEPARATOR;
        returned += emptyIfNull(item.isAddon());
        return returned;
    }
}
