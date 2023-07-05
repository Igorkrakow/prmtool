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
 * Created by TSENDELA on 2023-01-26.
 */
public class SubLineAggregator implements LineAggregator<SubRecord>{
    @Override
    public String aggregate(SubRecord item){
        String returned = String.valueOf(item.getSubId());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getPlayerId());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getGameId());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getDuration());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getDurationUnit());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getState());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getStartCdc());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getEndCdc());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getCdcCreated());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getTsCreated());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getTsLastModified());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getOriginChannelId());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getOriginSystemId());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getOriginClientid());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getTxUid());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getDescription());
        returned += SEPARATOR;
        returned += emptyIfNull(item.isAutoRenew());
        return returned;
    }
}
