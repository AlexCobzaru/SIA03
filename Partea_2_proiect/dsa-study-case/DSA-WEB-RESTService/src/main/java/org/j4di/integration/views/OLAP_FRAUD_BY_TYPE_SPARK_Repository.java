package org.j4di.analytical.views;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface OLAP_FRAUD_BY_TYPE_SPARK_Repository
        extends JpaRepository<OLAP_FRAUD_BY_TYPE_SPARK, String> {

    @Query("SELECT o FROM OLAP_FRAUD_BY_TYPE_SPARK o")
    List<OLAP_FRAUD_BY_TYPE_SPARK> get_OLAP_FRAUD_BY_TYPE_SPARK();
}