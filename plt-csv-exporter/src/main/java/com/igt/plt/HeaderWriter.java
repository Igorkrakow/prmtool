/*
 * Copyright © 2023 IGT.
 *
 * This software and all information contained therein is confidential and proprietary
 * and shall not be duplicated, used, disclosed or disseminated in any way except as
 * authorized by the applicable license agreement, without the express written permission of IGT.
 * All authorized reproductions must be marked with this language.
 */
package com.igt.plt;

import org.springframework.batch.item.file.FlatFileHeaderCallback;

import java.io.IOException;
import java.io.Writer;

/**
 * Created by TSENDELA on 2023-01-26.
 */
public class HeaderWriter implements FlatFileHeaderCallback{
    private final String header;
    private HeaderWriter(String header){ this.header = header; }

    @Override
    public void writeHeader(Writer writer) throws IOException{
        writer.write(header);
    }
}
