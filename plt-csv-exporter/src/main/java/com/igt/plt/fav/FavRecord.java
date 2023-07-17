/*
 * Copyright © 2023 IGT.
 *
 * This software and all information contained therein is confidential and proprietary
 * and shall not be duplicated, used, disclosed or disseminated in any way except as
 * authorized by the applicable license agreement, without the express written permission of IGT.
 * All authorized reproductions must be marked with this language.
 */
package com.igt.plt.fav;

/**
 * Created by TSENDELA on 2023-02-01.
 */
public class FavRecord{
    private final Long favId;
    private final Long favNr;
    private final Integer duration;
    private final Long gameId;
    private final String playerId;
    private final Long price;
    private final Long stake;
    private final String name = null;
    private final String tsCreated;
    private final String tsLastModified;
    private final Long favBsId;
    private final String drawNames = null;
    private final Long addonStake = null;
    private final boolean addon = false;
    private final Long groupId;

    public Long getFavId(){
        return favId;
    }

    public Long getFavNr(){
        return favNr;
    }

    public Integer getDuration(){
        return duration;
    }

    public Long getGameId(){
        return gameId;
    }

    public String getPlayerId(){
        return playerId;
    }

    public Long getPrice(){
        return price;
    }

    public Long getStake(){
        return stake;
    }

    public String getName(){
        return name;
    }

    public String getTsCreated(){
        return tsCreated;
    }

    public String getTsLastModified(){
        return tsLastModified;
    }

    public Long getFavBsId(){
        return favBsId;
    }

    public String getDrawNames(){
        return drawNames;
    }

    public Long getAddonStake(){
        return addonStake;
    }

    public boolean isAddon(){
        return addon;
    }

    public Long getGroupId(){
        return groupId;
    }

    public FavRecord(Long favId, Long favNr, Integer duration, Long gameId, String playerId, Long price, Long stake, String tsCreated, String tsLastModified, Long favBsId, Long groupId){
        this.favId = favId;
        this.favNr = favNr;
        this.duration = duration;
        this.gameId = gameId;
        this.playerId = playerId;
        this.price = price;
        this.stake = stake;
        this.tsCreated = tsCreated;
        this.tsLastModified = tsLastModified;
        this.favBsId = favBsId;
        this.groupId = groupId;
    }
}
