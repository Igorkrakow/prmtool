/*
 * Copyright © 2023 IGT.
 *
 * This software and all information contained therein is confidential and proprietary
 * and shall not be duplicated, used, disclosed or disseminated in any way except as
 * authorized by the applicable license agreement, without the express written permission of IGT.
 * All authorized reproductions must be marked with this language.
 */
package com.igt.plt.tx;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.batch.item.ItemProcessor;

import java.util.UUID;

/**
 * Created by TSENDELA on 2023-02-20.
 */
public class TxGrouppedProcessor implements ItemProcessor<TxRecord, TxRecord>{
    private static final Logger LOGGER = LoggerFactory.getLogger(TxGrouppedProcessor.class);
    @Override
    public TxRecord process(TxRecord item) throws Exception{
        try{
            item.setCorrelationId(UUID.randomUUID().toString());
            return item;
        }catch (Exception e){
            LOGGER.error("Caught " + e.getClass().getName(), e);
            throw new RuntimeException(e);
        }
    }
}
