package org.datasource.jdbc.views.transactions;

import java.math.BigDecimal;

public class TransactionView {
    private Integer clientId;
    private Integer step;
    private String type;
    private BigDecimal amount;
    private String nameOrig;
    private String nameDest;
    private Integer isFraud;
    private Integer isFlaggedFraud;

    public TransactionView() {
    }

    public TransactionView(Integer clientId, Integer step, String type, BigDecimal amount,
                           String nameOrig, String nameDest, Integer isFraud, Integer isFlaggedFraud) {
        this.clientId = clientId;
        this.step = step;
        this.type = type;
        this.amount = amount;
        this.nameOrig = nameOrig;
        this.nameDest = nameDest;
        this.isFraud = isFraud;
        this.isFlaggedFraud = isFlaggedFraud;
    }

    public Integer getClientId() {
        return clientId;
    }

    public void setClientId(Integer clientId) {
        this.clientId = clientId;
    }

    public Integer getStep() {
        return step;
    }

    public void setStep(Integer step) {
        this.step = step;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }

    public String getNameOrig() {
        return nameOrig;
    }

    public void setNameOrig(String nameOrig) {
        this.nameOrig = nameOrig;
    }

    public String getNameDest() {
        return nameDest;
    }

    public void setNameDest(String nameDest) {
        this.nameDest = nameDest;
    }

    public Integer getIsFraud() {
        return isFraud;
    }

    public void setIsFraud(Integer isFraud) {
        this.isFraud = isFraud;
    }

    public Integer getIsFlaggedFraud() {
        return isFlaggedFraud;
    }

    public void setIsFlaggedFraud(Integer isFlaggedFraud) {
        this.isFlaggedFraud = isFlaggedFraud;
    }
}