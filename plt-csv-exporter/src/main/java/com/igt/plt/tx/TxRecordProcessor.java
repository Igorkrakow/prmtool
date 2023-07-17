/*
 * Copyright © 2023 IGT.
 *
 * This software and all information contained therein is confidential and proprietary
 * and shall not be duplicated, used, disclosed or disseminated in any way except as
 * authorized by the applicable license agreement, without the express written permission of IGT.
 * All authorized reproductions must be marked with this language.
 */
package com.igt.plt.tx;

import java.math.BigDecimal;
import java.math.BigInteger;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBElement;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Unmarshaller;

import com.gtech.pd.iapi.transaction.dto.DrawGameClaimDetailsDTO;
import com.gtech.pd.iapi.transaction.dto.DrawGameValidationDetailsDTO;
import com.gtech.xml.base.common.basetypes.WinTier;
import com.gtech.xml.extsys.common.balancev39.ValidationDetail;
import com.gtech.xml.extsys.common.balancev39.WinDetails;
import com.gtech.xml.extsys.common.winxferv23.WinDetail;
import org.apache.camel.StringSource;
import org.apache.commons.lang3.RegExUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.batch.item.ItemProcessor;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.gtech.pd.iapi.transaction.dto.DrawGameBoardDetailsDTO;
import com.gtech.pd.iapi.transaction.dto.DrawGameBoardItemDTO;
import com.gtech.pd.iapi.transaction.dto.DrawGameBoardSelectionDTO;
import com.gtech.pd.iapi.transaction.dto.DrawGameBoardsDTO;
import com.gtech.pd.iapi.transaction.dto.DrawGameWagerDetailsDTO;
import com.gtech.pd.iapi.transaction.dto.PlayerPreferencesDTO;
import com.gtech.pd.iapi.transaction.dto.TerminalSessionDetailsDTO;
import com.gtech.pd.iapi.transaction.dto.TransactionDetailsDTO;
import com.gtech.xml.extsys.common.balancev39.BalanceTransaction;
import com.gtech.xml.extsys.common.balancev39.BoardData;
import com.gtech.xml.extsys.common.balancev39.TransactionDetail;
import com.gtech.xml.extsys.common.balancev39.WagerDetail;

import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * Created by TSENDELA on 2023-02-13.
 */
public class TxRecordProcessor implements ItemProcessor<TxRecord, TxRecord> {
    private static final Logger LOGGER = LoggerFactory.getLogger(TxRecordProcessor.class);
    private static final BigInteger MOD = new BigInteger("1");
    private final JAXBContext context;
    private final ObjectMapper mapper = new ObjectMapper();
    private final String proj;
    public TxRecordProcessor(String projString){
        proj = projString;
        try{
            context = JAXBContext.newInstance(BalanceTransaction.class);
            mapper.setSerializationInclusion(JsonInclude.Include.NON_NULL);
        }catch (JAXBException e){
            LOGGER.error("Caught " + e.getClass().getName(), e);
            throw new RuntimeException(e);
        }
    }

    @Override
    public TxRecord process(TxRecord item){
        try{
            final String xml = item.getJson();
            final Unmarshaller unmarshaller = context.createUnmarshaller();
            final JAXBElement<BalanceTransaction> element = unmarshaller.unmarshal(new StringSource(xml), BalanceTransaction.class);
            final BalanceTransaction root = element.getValue();
            final TransactionDetail details = root.getDetails();
            final TransactionDetailsDTO out = new TransactionDetailsDTO();
            if("WAGER".equals(item.getTransactionType())){
                final DrawGameBoardsDTO drawGameBoards = new DrawGameBoardsDTO();
                final List<DrawGameBoardDetailsDTO> drawGameBoardDetails = new ArrayList<>();
                drawGameBoards.setDrawGameBoardDetails(drawGameBoardDetails);
                out.setDrawGameBoards(drawGameBoards);
                final PlayerPreferencesDTO playerPreferences = new PlayerPreferencesDTO();
                playerPreferences.setAutopayWinnings(Boolean.FALSE);
                playerPreferences.setDigitalTicketOnly(Boolean.FALSE);
                out.setPlayerPreferences(playerPreferences);
                final DrawGameWagerDetailsDTO drawGameWagerDetails = new DrawGameWagerDetailsDTO();
                drawGameWagerDetails.setCardId("0");
                drawGameWagerDetails.setTrxLoyaltyPoints(BigDecimal.ZERO);
                if(proj.equals("KY")){
                    drawGameWagerDetails.setJurisdiction(16);
                }
                else {
                    drawGameWagerDetails.setJurisdiction(24);
                }
                drawGameWagerDetails.setProductNumber(item.getGameId().intValue());
                drawGameWagerDetails.setJournalAddress(item.getJournalAddress());
                final List<Integer> drawIds = new ArrayList<>();
                for(int i = item.getStartDrawNr();i <=item.getEndDrawNr();i++) drawIds.add(i);
                drawGameWagerDetails.setDrawIds(drawIds);
                out.setDrawGameWagerDetails(drawGameWagerDetails);
                final TerminalSessionDetailsDTO terminalSessionDetailsDTO = new TerminalSessionDetailsDTO();
                terminalSessionDetailsDTO.setCdc(item.getCdc());
                terminalSessionDetailsDTO.setSessionId(0L);
                terminalSessionDetailsDTO.setRetailerId(0L);
                terminalSessionDetailsDTO.setTerminalId(0L);
                out.setTerminalSessionDetailsDTO(terminalSessionDetailsDTO);
                final WagerDetail wagerDetail = details.getWagerDetail();
                final BigInteger multiplier = wagerDetail.getMultiplier();
                /*
                TO_CLARIFY added check for null for multiplayer, priveusly ut was missing but in KY those cases when
                multiplayer is null and when we tried to MOD.compareTo(multiplier) == 0 we catch an null pointer exeprion
                now if nulll then also 0 (shoud be confirmed)
                */
                if(multiplier == null){
                    drawGameWagerDetails.setMultiplier(0L);
                }
                else {
                    if (MOD.compareTo(multiplier) == 0) drawGameWagerDetails.setMultiplier(1L);
                    else drawGameWagerDetails.setMultiplier(0L);
                }
                boolean quickPicked  = false;
                for(int i = 0;i < wagerDetail.getBoardDatas().size();i++){
                    final BoardData boardData = wagerDetail.getBoardDatas().get(i);
                    final String value = boardData.getValue().trim();
                    final String qp = boardData.getQp();
                    if(i == 0){
                        if("true".equals(qp)) quickPicked = true;
                        else if("false".equals(qp)) quickPicked = false;
                        else{
                            final int parsed;
                            try{
                                parsed = Integer.parseInt(qp);
                                quickPicked = parsed > 0;
                            }catch(NumberFormatException e){
                                LOGGER.error("Caught " + e.getClass().getName() + " qp:" + qp, e);
                            }
                        }
                    }
                    final DrawGameBoardDetailsDTO bd = new DrawGameBoardDetailsDTO();
                    final List<DrawGameBoardSelectionDTO<DrawGameBoardItemDTO>> drawGameBoardSelections = new ArrayList<>();
                    bd.setDrawGameBoardSelections(drawGameBoardSelections);
                    bd.setBoardIndex(i);
                    bd.setBetTypeId("0");
                    bd.setStake(BigDecimal.ZERO);
                    bd.setBoardPrice(BigDecimal.ZERO);
                    drawGameBoardDetails.add(bd);
                    final DrawGameBoardSelectionDTO<DrawGameBoardItemDTO> sel = new DrawGameBoardSelectionDTO<>();
                    drawGameBoardSelections.add(sel);
                    final List<DrawGameBoardItemDTO> drawGameBoardItems = new ArrayList<>();
                    sel.setDrawGameBoardItems(drawGameBoardItems);
                    /*
                    TO_CLARIFY chenged logic for primery and secondaru selection type, priviusly it was harcoded for
                    specific game, like   if(17L == item.getGameId() || 18L == item.getGameId()){
                    now we check for '-' inside board selection
                    */
                    if(value.indexOf("-") != -1){
                        final String[] split1 = value.split(" - ");
                        final String[] split = split1[0].split(" ");
                        sel.setSelectionTypeName("PRIMARY");
                        for(int j = 0;j < split.length;j++){
                            final String selection = split[j];
                            final DrawGameBoardItemDTO boardItem = new DrawGameBoardItemDTO();
                            boardItem.setItemIndex("" + j);
                            final String itemValue = selection.startsWith("0") ? RegExUtils.replaceFirst(selection, "0", "") : selection;
                            boardItem.setItemValue(itemValue);
                            drawGameBoardItems.add(boardItem);
                        }
                        if(quickPicked)sel.setQuickpickCount(drawGameBoardItems.size());
                        else sel.setQuickpickCount(0);
                        final DrawGameBoardSelectionDTO<DrawGameBoardItemDTO> sec = new DrawGameBoardSelectionDTO<>();
                        drawGameBoardSelections.add(sec);
                        sec.setSelectionTypeName("SECONDARY");
                        sec.setDrawGameBoardItems(new ArrayList<>());
                        final String[] splitSec = split1[1].split(" ");
                        for(int j = 0;j < splitSec.length;j++){
                            final String selection = splitSec[j];
                            final DrawGameBoardItemDTO boardItem = new DrawGameBoardItemDTO();
                            boardItem.setItemIndex("" + j);
                            final String itemValue = selection.startsWith("0") ? RegExUtils.replaceFirst(selection, "0", "") : selection;
                            boardItem.setItemValue(itemValue);
                            sec.getDrawGameBoardItems().add(boardItem);
                        }
                        if(quickPicked)sec.setQuickpickCount(sec.getDrawGameBoardItems().size());
                        else sec.setQuickpickCount(0);
                    }else{
                        sel.setSelectionTypeName("PRIMARY");
                        final String[] split = value.split(" ");
                        for(int j = 0;j < split.length;j++){
                            final String selection = split[j];
                            final DrawGameBoardItemDTO boardItem = new DrawGameBoardItemDTO();
                            boardItem.setItemIndex("" + j);
                            final String itemValue = selection.startsWith("0") ? RegExUtils.replaceFirst(selection, "0", "") : selection;
                            boardItem.setItemValue(itemValue);
                            drawGameBoardItems.add(boardItem);
                        }
                        if(quickPicked)sel.setQuickpickCount(drawGameBoardItems.size());
                        else sel.setQuickpickCount(0);
                    }
                }
            }else if("VALIDATION".equals(item.getTransactionType())){
                final DrawGameWagerDetailsDTO drawGameWagerDetails = new DrawGameWagerDetailsDTO();
                final List<Integer> drawIds = new ArrayList<>();
                for(int i = item.getStartDrawNr();i <=item.getEndDrawNr();i++) drawIds.add(i);
                drawGameWagerDetails.setDrawIds(drawIds);
                out.setDrawGameWagerDetails(drawGameWagerDetails);
                final ValidationDetail validationDetail = details.getValidationDetail();
                WinDetails winDetails = validationDetail.getWinDetails();
                List<WinDetail> winDetailList = winDetails.getWinDetails();
                WinDetail winDetail = winDetailList.get(0);
                DrawGameValidationDetailsDTO valid = new DrawGameValidationDetailsDTO();
                /*
                 TO_CLARIFY added check for nul for intValue()winset, on KY it may be null
                 and when we try to set it in  intValue() we recived null poiner exeption
                 now if it is null we scip thhis part in json (shoud be confirmed)
                 */
                if(winDetail.getWinSet() != null) {
                    valid.setWinSet(winDetail.getWinSet().intValue());
                }
                valid.setPrizeTier(WinTier.LOW == winDetail.getTier() ? "LOW" : "HIGH");
                valid.setPrizeType("CASH");
                valid.setDrawNumber(winDetail.getDraw());

                String drawDate = String.valueOf(winDetail.getDrawDate());
                drawDate = drawDate.replaceAll("Z", "");
                SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
                try {
                    Date date = formatter.parse(drawDate);
                    drawGameWagerDetails.setDrawTimes(Arrays.asList(date.getTime() / 1000));
                }catch (Exception e){
                    drawGameWagerDetails.setDrawTimes(Arrays.asList(0L));
                    System.out.println(e);
                }

                valid.setJurisdiction((short) 24);
                valid.setRefExternalId(item.getCorrelationId());
                valid.setValidationType("CASH");
                valid.setWinningDivision(winDetail.getDivision());
                out.setDrawGameValidationDetails(valid);
            }else if("CLAIM".equals(item.getTransactionType())){
                DrawGameClaimDetailsDTO drawGameClaimDetails = new DrawGameClaimDetailsDTO();
                out.setDrawGameClaimDetails(drawGameClaimDetails);
                final ValidationDetail validationDetail = details.getValidationDetail();
                WinDetails winDetails = validationDetail.getWinDetails();
                List<WinDetail> winDetailList = winDetails.getWinDetails();
                WinDetail winDetail = winDetailList.get(0);
                drawGameClaimDetails.setClaimAmount(winDetail.getAmount());
                drawGameClaimDetails.setClaimNetAmount(winDetail.getAmount());
                drawGameClaimDetails.setClaimSource("2");
                drawGameClaimDetails.setJurisdiction((short) 24);
                drawGameClaimDetails.setClaimId("0");
                drawGameClaimDetails.setClaimDate(item.getTransactionUtcTime());
                drawGameClaimDetails.setClaimStatus("000");
                drawGameClaimDetails.setClaimDrawNumber("000");
            }
            final String json = mapper.writeValueAsString(out);
            final String corrected = json.replaceAll("\"", "\"\"");
            item.setJson(corrected);
            if(proj.equals("KY")){
                item.setChannelId("5002");
                item.setSystemId("5008");
            }
            else {
                item.setChannelId(root.getChannel());
                item.setSystemId(root.getSubChannel());
            }
            return item;
        }catch (Exception e){
            LOGGER.error("Caught " + e.getClass().getName(), e);
            throw new RuntimeException(e);
        }
    }
}
