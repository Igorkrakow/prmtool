/*
 * Copyright © 2023 IGT.
 *
 * This software and all information contained therein is confidential and proprietary
 * and shall not be duplicated, used, disclosed or disseminated in any way except as
 * authorized by the applicable license agreement, without the express written permission of IGT.
 * All authorized reproductions must be marked with this language.
 */
package com.igt.plt.tx;

import java.util.List;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBElement;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Unmarshaller;

import org.apache.camel.StringSource;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.batch.item.ItemProcessor;

import com.gtech.xml.extsys.common.balancev39.BalanceTransaction;
import com.gtech.xml.extsys.common.balancev39.TransactionDetail;
import com.gtech.xml.extsys.common.balancev39.ValidationDetail;
import com.gtech.xml.extsys.common.balancev39.WinDetails;
import com.gtech.xml.extsys.common.winxferv23.WinDetail;

/**
 * Created by TSENDELA on 2023-02-16.
 */
public class TxResultProcessor  implements ItemProcessor<TxResultRecord,TxResultRecord>{
    private static final Logger LOGGER = LoggerFactory.getLogger(TxRecordProcessor.class);
    private final JAXBContext context;
    public TxResultProcessor(){
        try{
            context = JAXBContext.newInstance(BalanceTransaction.class);
        }catch (JAXBException e){
            LOGGER.error("Caught " + e.getClass().getName(), e);
            throw new RuntimeException(e);
        }
    }

    @Override
    public TxResultRecord process(TxResultRecord item) throws Exception{
        final String xml = item.getXml();
        final Unmarshaller unmarshaller = context.createUnmarshaller();
        final JAXBElement<BalanceTransaction> element = unmarshaller.unmarshal(new StringSource(xml), BalanceTransaction.class);
        final BalanceTransaction root = element.getValue();
        final TransactionDetail details = root.getDetails();
        final ValidationDetail validationDetail = details.getValidationDetail();
        final WinDetails winDetails = validationDetail.getWinDetails();
        final List<WinDetail> winDetailsList = winDetails.getWinDetails();
        final WinDetail winDetail = winDetailsList.get(0);
        final Integer winningDivision = winDetail.getDivision();
        item.setWinningDivision(winningDivision);
        item.setXml(null);
        return item;
    }
}
