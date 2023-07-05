package com.igt.plt.sub;

import org.springframework.batch.item.file.transform.LineAggregator;
import static com.igt.plt.common.PltCsvExporterUtils.SEPARATOR;
import static com.igt.plt.common.PltCsvExporterUtils.emptyIfNull;
import static com.igt.plt.common.PltCsvExporterUtils.emptyIfNullWrapped;

/**
 * Created by TSENDELA on 2023-01-26.
 */
public class SubWagerTemplateLineAggregator implements LineAggregator<SubRecord> {
    @Override
    public String aggregate(SubRecord item){
        String returned = String.valueOf(item.getSubId());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getSubId());
        returned += SEPARATOR;
        returned += emptyIfNull(item.getGameId());
        returned += SEPARATOR;
        final String drawDays;
        switch("" + item.getGameId()){
            case "8":
                drawDays = "TUESDAY,THURSDAY,SATURDAY";
                break;
            case "10":
            case "18":
            case "25":
            case "27":
                drawDays = "MONDAY,TUESDAY,WEDNESDAY,THURSDAY,FRIDAY,SATURDAY,SUNDAY";
                break;
            case "17":
                drawDays = "TUESDAY,FRIDAY";
                break;
            default:
                throw new RuntimeException("incorrect gameId=" + item.getGameId());
        }
        returned += emptyIfNullWrapped(drawDays);
        returned += SEPARATOR;
        returned += emptyIfNull(item.getWageramount());
        returned += SEPARATOR;
        returned += emptyIfNull(item.isAutoTopUp());
        return returned;
    }
}