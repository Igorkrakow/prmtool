/*
 * Copyright © 2023 IGT.
 *
 * This software and all information contained therein is confidential and proprietary
 * and shall not be duplicated, used, disclosed or disseminated in any way except as
 * authorized by the applicable license agreement, without the express written permission of IGT.
 * All authorized reproductions must be marked with this language.
 */
package com.igt.plt.common;

/**
 * Created by TSENDELA on 2023-02-13.
 */
public class PltCsvExporterUtils{
    public static final String SEPARATOR = ",";

    public static Object emptyIfNull(Object o){
        return o == null ? "" : o;
    }
    public static Object emptyIfNullWrapped(Object o){
        return o == null ? "" : "\""+o+"\"";
    }
}
