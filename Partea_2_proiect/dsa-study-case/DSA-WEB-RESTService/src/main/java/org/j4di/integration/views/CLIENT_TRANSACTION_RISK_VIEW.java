package org.j4di.integration.views;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import org.hibernate.annotations.Immutable;

@Getter
@Entity
@Immutable
@Table(name = "CLIENT_TRANSACTION_RISK_VIEW")
public class CLIENT_TRANSACTION_RISK_VIEW {

    @Id
    @Column(name = "transactionKey")
    private String transactionKey;

    @Column(name = "clientId")
    private Long clientId;

    @Column(name = "step")
    private Long step;

    @Column(name = "type")
    private String type;

    @Column(name = "amount")
    private Double amount;

    @Column(name = "nameOrig")
    private String nameOrig;

    @Column(name = "nameDest")
    private String nameDest;

    @Column(name = "isFraud")
    private Long isFraud;

    @Column(name = "isFlaggedFraud")
    private Long isFlaggedFraud;

    @Column(name = "age")
    private Long age;

    @Column(name = "job")
    private String job;

    @Column(name = "marital")
    private String marital;

    @Column(name = "education")
    private String education;

    @Column(name = "balance")
    private String balance;

    @Column(name = "housing")
    private String housing;

    @Column(name = "loan")
    private String loan;

    @Column(name = "riskScore")
    private Double riskScore;

    @Column(name = "currency")
    private String currency;

    @Column(name = "status")
    private String status;
}