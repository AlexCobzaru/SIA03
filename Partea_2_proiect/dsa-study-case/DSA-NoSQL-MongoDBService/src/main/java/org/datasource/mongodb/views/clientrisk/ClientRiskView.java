package org.datasource.mongodb.views.clientrisk;

public class ClientRiskView {
    private Integer clientId;
    private Double riskScore;
    private String currency;
    private String status;

    public ClientRiskView() {
    }

    public ClientRiskView(Integer clientId, Double riskScore, String currency, String status) {
        this.clientId = clientId;
        this.riskScore = riskScore;
        this.currency = currency;
        this.status = status;
    }

    public Integer getClientId() {
        return clientId;
    }

    public void setClientId(Integer clientId) {
        this.clientId = clientId;
    }

    public Double getRiskScore() {
        return riskScore;
    }

    public void setRiskScore(Double riskScore) {
        this.riskScore = riskScore;
    }

    public String getCurrency() {
        return currency;
    }

    public void setCurrency(String currency) {
        this.currency = currency;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}