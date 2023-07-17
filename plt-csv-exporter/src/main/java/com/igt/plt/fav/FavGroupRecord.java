/*
 * Copyright © 2023 IGT.
 *
 * This software and all information contained therein is confidential and proprietary
 * and shall not be duplicated, used, disclosed or disseminated in any way except as
 * authorized by the applicable license agreement, without the express written permission of IGT.
 * All authorized reproductions must be marked with this language.
 */
package com.igt.plt.fav;


public class FavGroupRecord{
    private final Long favGroupId;
    private final String favGroupNr;
    private final String favGroupName;
    private final Long playerId;

    public Long getFavGroupId(){
        return favGroupId;
    }

    public String getFavGroupNr(){
        return favGroupNr;
    }

    public String getFavGroupName(){
        return favGroupName;
    }

    public Long getPlayerId(){
        return playerId;
    }


    public FavGroupRecord(Long favGroupId,String favGroupNr,String favGroupName, Long playerId){
        this.favGroupId = favGroupId;
        this.favGroupNr = favGroupNr;
        this.favGroupName = favGroupName;
        this.playerId = playerId;

    }
}
