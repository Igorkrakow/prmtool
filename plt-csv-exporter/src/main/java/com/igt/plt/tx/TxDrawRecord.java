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
 * Created by TSENDELA on 2023-02-14.
 */
public class TxDrawRecord{
    private final Long gameId;
    private final Long drawId;
    private final String drawName = null;
    private final String drawTime;
    private final String drawStatus;

    public Long getGameId(){
        return gameId;
    }

    public Long getDrawId(){
        return drawId;
    }

    public String getDrawName(){
        return drawName;
    }

    public String getDrawTime(){
        return drawTime;
    }

    public String getDrawStatus(){
        return drawStatus;
    }

    public TxDrawRecord(Long gameId, Long drawId, String drawTime, String drawStatus){
        this.gameId = gameId;
        this.drawId = drawId;
        this.drawTime = drawTime;
        this.drawStatus = drawStatus;
    }
}
