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
 * Created by TSENDELA on 2023-01-27.
 */
public class BoardRecord{
    private final Long boardId;
    private final Long boardStackId;
    private final Long boardStake;
    private final String pickSystem;
    private final Integer numberOfQuickPickMarks;
    private final Integer numberOfSecondaryQuickPickMarks;
    private final String pickValues;
    private final Integer boardIndex;
    private final String modifier;

    public Long getBoardId(){
        return boardId;
    }

    public Long getBoardStackId(){
        return boardStackId;
    }

    public Long getBoardStake(){
        return boardStake;
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

    public String getPickValues(){
        return pickValues;
    }

    public Integer getBoardIndex(){
        return boardIndex;
    }

    public String getModifier(){
        return modifier;
    }

    public BoardRecord(Long boardId, Long boardStackId, Long boardStake, String pickSystem, Integer numberOfQuickPickMarks, Integer numberOfSecondaryQuickPickMarks, String pickValues, Integer boardIndex, String modifier){
        this.boardId = boardId;
        this.boardStackId = boardStackId;
        this.boardStake = boardStake;
        this.pickSystem = pickSystem;
        this.numberOfQuickPickMarks = numberOfQuickPickMarks;
        this.numberOfSecondaryQuickPickMarks = numberOfSecondaryQuickPickMarks;
        this.pickValues = pickValues;
        this.boardIndex = boardIndex;
        this.modifier = modifier;
    }
}
