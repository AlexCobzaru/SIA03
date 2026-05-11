package org.j4di.analytical.views;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import org.hibernate.annotations.Immutable;

@Getter
@Entity
@Immutable
@Table(name = "OLAP_FRAUD_BY_TYPE_SPARK")
public class OLAP_FRAUD_BY_TYPE_SPARK {

    @Id
    @Column(name = "type")
    private String type;

    @Column(name = "total_transactions")
    private Long total_transactions;

    @Column(name = "total_amount")
    private Double total_amount;

    @Column(name = "fraud_count")
    private Long fraud_count;
}