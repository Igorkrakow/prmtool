/*
 * Copyright © 2023 IGT.
 *
 * This software and all information contained therein is confidential and proprietary
 * and shall not be duplicated, used, disclosed or disseminated in any way except as
 * authorized by the applicable license agreement, without the express written permission of IGT.
 * All authorized reproductions must be marked with this language.
 */
package com.igt.plt;

import java.io.StringWriter;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.batch.item.ItemWriter;
import org.springframework.batch.item.file.FlatFileHeaderCallback;
import org.springframework.batch.item.file.transform.LineAggregator;
import org.springframework.core.io.Resource;

/**
 * Created by TSENDELA on 2023-01-26.
 */
public class ConsoleWriter implements ItemWriter<Object> {
    private boolean silent = false;
    private FlatFileHeaderCallback headerCallback;
    private LineAggregator<Object> lineAggregator;
    public static final String DEFAULT_LINE_SEPARATOR = System.getProperty("line.separator");
    private String lineSeparator = System.getProperty("line.separator");
    public void setSilent(boolean silent){
        this.silent = silent;
    }

    private static final Logger LOGGER = LoggerFactory.getLogger(ConsoleWriter.class);

    public void setHeaderCallback(FlatFileHeaderCallback headerCallback){
        this.headerCallback = headerCallback;
    }

    @Override
    public void write(List<? extends Object> items) throws Exception{
        if(silent)return;
        final StringBuilder lines = new StringBuilder();
        final StringWriter sw = new StringWriter();
        headerCallback.writeHeader(sw);
        lines.append(sw.toString()).append("\n");
        for(Object item:items){
            lines.append(this.lineAggregator.aggregate(item)).append(this.lineSeparator);
        }
        LOGGER.info("\n"+lines.toString());
    }
    public void setName(String name) { }
    public void setResource(Resource resource){ }
    public void setLineAggregator(LineAggregator<Object> lineAggregator){
        this.lineAggregator = lineAggregator;
    }
}
