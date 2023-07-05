/*
 * Copyright © 2023 IGT.
 *
 * This software and all information contained therein is confidential and proprietary
 * and shall not be duplicated, used, disclosed or disseminated in any way except as
 * authorized by the applicable license agreement, without the express written permission of IGT.
 * All authorized reproductions must be marked with this language.
 */
package com.igt.plt.tx;

/**
 * Created by TSENDELA on 2023-02-16.
 */
public class TxResultRecord{
    private final Long drawId;
    private final Long gameId;
    private final Long prizeAmount;
    private final String tsCreated;
    private final String tsModified;
    private final Long txDrawEntryId;
    private final String validationUuid;
    private final String claimId = null;
    private final String prizeDescription = null;
    private final String prizeType = "CASH";
    private final String winningBoardIndex = null;
    private String xml;
    private Integer winningDivision;

    public Long getDrawId(){
        return drawId;
    }

    public Long getGameId(){
        return gameId;
    }

    public Long getPrizeAmount(){
        return prizeAmount;
    }

    public String getTsCreated(){
        return tsCreated;
    }

    public String getTsModified(){
        return tsModified;
    }

    public Long getTxDrawEntryId(){
        return txDrawEntryId;
    }

    public String getValidationUuid(){
        return validationUuid;
    }

    public String getClaimId(){
        return claimId;
    }

    public String getPrizeDescription(){
        return prizeDescription;
    }

    public String getPrizeType(){
        return prizeType;
    }

    public String getWinningBoardIndex(){
        return winningBoardIndex;
    }

    public String getXml(){
        return xml;
    }

    public void setXml(String xml){
        this.xml = xml;
    }

    public Integer getWinningDivision(){
        return winningDivision;
    }

    public void setWinningDivision(Integer winningDivision){
        this.winningDivision = winningDivision;
    }

    public TxResultRecord(Long drawId, Long gameId, Long prizeAmount, String tsCreated, String tsModified, Long txDrawEntryId, String validationUuid, String xml){
        this.drawId = drawId;
        this.gameId = gameId;
        this.prizeAmount = prizeAmount;
        this.tsCreated = tsCreated;
        this.tsModified = tsModified;
        this.txDrawEntryId = txDrawEntryId;
        this.validationUuid = validationUuid;
        this.xml = xml;
    }
}
