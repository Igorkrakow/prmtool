/*
 * Copyright © 2023 IGT.
 *
 * This software and all information contained therein is confidential and proprietary
 * and shall not be duplicated, used, disclosed or disseminated in any way except as
 * authorized by the applicable license agreement, without the express written permission of IGT.
 * All authorized reproductions must be marked with this language.
 */
package com.igt.plt;

import org.springframework.batch.item.ItemProcessor;

/**
 * Created by TSENDELA on 2023-01-25.
 */
public class EmptyProcessor implements ItemProcessor<Object,Object>{
    @Override
    public Object process(Object item) throws Exception{ return item; }
}
