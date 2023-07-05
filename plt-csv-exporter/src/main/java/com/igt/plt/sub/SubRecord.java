/*
 * Copyright © 2023 IGT.
 *
 * This software and all information contained therein is confidential and proprietary
 * and shall not be duplicated, used, disclosed or disseminated in any way except as
 * authorized by the applicable license agreement, without the express written permission of IGT.
 * All authorized reproductions must be marked with this language.
 */
package com.igt.plt.sub;

/**
 * Created by TSENDELA on 2023-01-25.
 */
public class SubRecord{
    private final Long subId;
    private final String playerId;
    private final Long gameId;
    private final Integer duration = 1;
    private final String durationUnit = "DRAWS";
    private final String state = "ACTIVE";
    private final Integer startCdc;
    private final String endCdc = null;
    private final Integer cdcCreated;
    private final String tsCreated;
    private final String tsLastModified;
    private final String originChannelId = "5002";
    private final String originSystemId = "5008";
    private final String originClientid = null;
    private final String txUid;
    private final String description = null;
    private final boolean autoRenew = true;
    private final Long wageramount;
    private final boolean autoTopUp = false;
    private final Long boardStackId;
    private final String wagerId = null;
    private final String extraStake = null;
    private final boolean addon = false;

    public Long getSubId(){
        return subId;
    }

    public String getPlayerId(){
        return playerId;
    }

    public Long getGameId(){
        return gameId;
    }

    public Integer getDuration(){
        return duration;
    }

    public String getDurationUnit(){
        return durationUnit;
    }

    public String getState(){
        return state;
    }

    public Integer getStartCdc(){
        return startCdc;
    }

    public String getEndCdc(){
        return endCdc;
    }

    public Integer getCdcCreated(){
        return cdcCreated;
    }

    public String getTsCreated(){
        return tsCreated;
    }

    public String getTsLastModified(){
        return tsLastModified;
    }

    public String getOriginChannelId(){
        return originChannelId;
    }

    public String getOriginSystemId(){
        return originSystemId;
    }

    public String getOriginClientid(){
        return originClientid;
    }

    public String getTxUid(){
        return txUid;
    }

    public String getDescription(){
        return description;
    }

    public boolean isAutoRenew(){
        return autoRenew;
    }

    public Long getWageramount(){
        return wageramount;
    }

    public boolean isAutoTopUp(){
        return autoTopUp;
    }

    public Long getBoardStackId(){
        return boardStackId;
    }

    public String getWagerId(){
        return wagerId;
    }

    public String getExtraStake(){
        return extraStake;
    }

    public boolean isAddon(){
        return addon;
    }

    public SubRecord(Long subId, String playerId, Long gameId, Integer startCdc, Integer cdcCreated, String tsCreated, String tsLastModified, String txUid, Long wageramount, Long boardStackId){
        this.subId = subId;
        this.playerId = playerId;
        this.gameId = gameId;
        this.startCdc = startCdc;
        this.cdcCreated = cdcCreated;
        this.tsCreated = tsCreated;
        this.tsLastModified = tsLastModified;
        this.txUid = txUid;
        this.wageramount = wageramount;
        this.boardStackId = boardStackId;
    }
}
