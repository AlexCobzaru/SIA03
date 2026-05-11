package org.datasource.poi.clientprofiles;

import java.math.BigDecimal;

public class ClientProfileView {
    private Integer clientId;
    private Integer age;
    private String job;
    private String marital;
    private String education;
    private BigDecimal balance;
    private String housing;
    private String loan;

    public ClientProfileView() {
    }

    public ClientProfileView(Integer clientId, Integer age, String job, String marital,
                             String education, BigDecimal balance, String housing, String loan) {
        this.clientId = clientId;
        this.age = age;
        this.job = job;
        this.marital = marital;
        this.education = education;
        this.balance = balance;
        this.housing = housing;
        this.loan = loan;
    }

    public Integer getClientId() {
        return clientId;
    }

    public void setClientId(Integer clientId) {
        this.clientId = clientId;
    }

    public Integer getAge() {
        return age;
    }

    public void setAge(Integer age) {
        this.age = age;
    }

    public String getJob() {
        return job;
    }

    public void setJob(String job) {
        this.job = job;
    }

    public String getMarital() {
        return marital;
    }

    public void setMarital(String marital) {
        this.marital = marital;
    }

    public String getEducation() {
        return education;
    }

    public void setEducation(String education) {
        this.education = education;
    }

    public BigDecimal getBalance() {
        return balance;
    }

    public void setBalance(BigDecimal balance) {
        this.balance = balance;
    }

    public String getHousing() {
        return housing;
    }

    public void setHousing(String housing) {
        this.housing = housing;
    }

    public String getLoan() {
        return loan;
    }

    public void setLoan(String loan) {
        this.loan = loan;
    }
}