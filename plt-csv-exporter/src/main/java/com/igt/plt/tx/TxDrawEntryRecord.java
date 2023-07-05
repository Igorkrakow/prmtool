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
 * @author mpielak
 */
public class TxDrawEntryRecord {
    private final Long txDrawEntryId;
    private final String txTransactionUuid;
    private final Long drawId;
    private final Long productId;
    private final String winningStatus;
    private final String jsonData = null;

    public TxDrawEntryRecord(Long txDrawEntryId, String txTransactionUuid, Long drawId, Long productId, String winningStatus) {
        this.txDrawEntryId = txDrawEntryId;
        this.txTransactionUuid = txTransactionUuid;
        this.drawId = drawId;
        this.productId = productId;
        this.winningStatus = winningStatus;
    }

    public Long getTxDrawEntryId() {
        return txDrawEntryId;
    }

    public String getTxTransactionUuid() {
        return txTransactionUuid;
    }

    public Long getDrawId() {
        return drawId;
    }

    public Long getProductId() {
        return productId;
    }

    public String getWinningStatus() {
        return winningStatus;
    }

    public String getJsonData() {
        return jsonData;
    }
}
