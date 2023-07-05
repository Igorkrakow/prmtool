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
 * Created by TSENDELA on 2023-02-06.
 */
public class TxRecord{
    private final Long transactionId;
    private final String globalTransId;
    private String correlationId;
    private final String uuid;
    private final String journalAddress;
    private final String playerId;
    private final String transactionTime;
    private final String transactionType;
    private  String channelId = null;
    private  String systemId = null;
    private final Long transactionAmount;
    private final Long subscriptionId;
    private final String transactionDiscountAmount = "0";
    private final String currency = "USD";
    private final Integer serial;
    private final Integer cdc;
    private final String gameEngineTransactionTime;
    private final Long gameId;
    private final Integer startDrawNr;
    private final Integer endDrawNr;
    private final String siteJsonData = null;
    private final String serialNr;
    private String json;
    private final Long transactionUtcTime;

    public Long getTransactionId(){
        return transactionId;
    }

    public String getGlobalTransId(){
        return globalTransId;
    }

    public String getCorrelationId(){
        return correlationId;
    }

    public void setCorrelationId(String correlationId){
        this.correlationId = correlationId;
    }

    public String getUuid(){
        return uuid;
    }

    public String getJournalAddress(){
        return journalAddress;
    }

    public String getPlayerId(){
        return playerId;
    }

    public String getTransactionTime(){
        return transactionTime;
    }

    public String getTransactionType(){
        return transactionType;
    }

    public String getChannelId(){
        return channelId;
    }

    public String getSystemId(){
        return systemId;
    }

    public Long getTransactionAmount(){
        return transactionAmount;
    }

    public Long getSubscriptionId(){
        return subscriptionId;
    }

    public String getTransactionDiscountAmount(){
        return transactionDiscountAmount;
    }

    public String getCurrency(){
        return currency;
    }

    public Integer getSerial(){
        return serial;
    }

    public Integer getCdc(){
        return cdc;
    }

    public String getGameEngineTransactionTime(){
        return gameEngineTransactionTime;
    }

    public Long getGameId(){
        return gameId;
    }

    public Integer getStartDrawNr(){
        return startDrawNr;
    }

    public Integer getEndDrawNr(){
        return endDrawNr;
    }

    public String getSiteJsonData(){
        return siteJsonData;
    }

    public String getSerialNr(){
        return serialNr;
    }

    public String getJson(){
        return json;
    }

    public void setJson(String json){
        this.json = json;
    }

    public void setChannelId(String channelId){
        this.channelId = channelId;
    }

    public void setSystemId(String systemId){
        this.systemId = systemId;
    }

    public Long getTransactionUtcTime(){
        return transactionUtcTime;
    }

    public TxRecord(Long transactionId, String globalTransId, String correlationId, String uuid, String journalAddress, String playerId, String transactionTime, String transactionType, String channelId, String systemId, Long transactionAmount, Long subscriptionId, Integer serial, Integer cdc, String gameEngineTransactionTime, Long gameId, Integer startDrawNr, Integer endDrawNr, String serialNr, String json, Long transactionUtcTime){
        this.transactionId = transactionId;
        this.globalTransId = globalTransId;
        this.correlationId = correlationId;
        this.uuid = uuid;
        this.journalAddress = journalAddress;
        this.playerId = playerId;
        this.transactionTime = transactionTime;
        this.transactionType = transactionType;
        this.channelId = channelId;
        this.systemId = systemId;
        this.transactionAmount = transactionAmount;
        this.subscriptionId = subscriptionId;
        this.serial = serial;
        this.cdc = cdc;
        this.gameEngineTransactionTime = gameEngineTransactionTime;
        this.gameId = gameId;
        this.startDrawNr = startDrawNr;
        this.endDrawNr = endDrawNr;
        this.serialNr = serialNr;
        this.json = json;
        this.transactionUtcTime = transactionUtcTime;
    }
}
