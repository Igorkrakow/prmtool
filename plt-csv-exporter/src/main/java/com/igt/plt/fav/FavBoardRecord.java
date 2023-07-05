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
 * Created by TSENDELA on 2023-02-02.
 */
public class FavBoardRecord{
    private final Long favBoardId;
    private final Long favBsId;
    private final Long stake;
    private final String pickSystem;
    private final Integer numberOfQuickPickMarks;
    private final Integer numberOfSecondaryQuickPickMarks;
    private final String primarySelections;
    private final String secondarySelections;
    private final String tertiarySelections = null;
    private final String addonSelections = null;
    private final Integer boardIndex;
    private final boolean modifier;

    public Long getFavBoardId(){
        return favBoardId;
    }

    public Long getFavBsId(){
        return favBsId;
    }

    public Long getStake(){
        return stake;
    }

    public String getPickSystem(){
        return pickSystem;
    }

    public Integer getNumberOfQuickPickMarks(){
        return numberOfQuickPickMarks;
    }

    public Integer getNumberOfSecondaryQuickPickMarks(){
        return numberOfSecondaryQuickPickMarks;
    }

    public String getPrimarySelections(){
        return primarySelections;
    }

    public String getSecondarySelections(){
        return secondarySelections;
    }

    public String getTertiarySelections(){
        return tertiarySelections;
    }

    public String getAddonSelections(){
        return addonSelections;
    }

    public Integer getBoardIndex(){
        return boardIndex;
    }

    public boolean isModifier(){
        return modifier;
    }

    public FavBoardRecord(Long favBoardId, Long favBsId, Long stake, String pickSystem, Integer numberOfQuickPickMarks, Integer numberOfSecondaryQuickPickMarks, String primarySelections, String secondarySelections, Integer boardIndex, boolean modifier){
        this.favBoardId = favBoardId;
        this.favBsId = favBsId;
        this.stake = stake;
        this.pickSystem = pickSystem;
        this.numberOfQuickPickMarks = numberOfQuickPickMarks;
        this.numberOfSecondaryQuickPickMarks = numberOfSecondaryQuickPickMarks;
        this.primarySelections = primarySelections;
        this.secondarySelections = secondarySelections;
        this.boardIndex = boardIndex;
        this.modifier = modifier;
    }
}
