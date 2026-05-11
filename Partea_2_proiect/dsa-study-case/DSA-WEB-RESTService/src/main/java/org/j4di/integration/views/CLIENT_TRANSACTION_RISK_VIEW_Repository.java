package org.j4di.integration.views;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface CLIENT_TRANSACTION_RISK_VIEW_Repository
        extends JpaRepository<CLIENT_TRANSACTION_RISK_VIEW, String> {

    @Query("SELECT o FROM CLIENT_TRANSACTION_RISK_VIEW o")
    List<CLIENT_TRANSACTION_RISK_VIEW> get_CLIENT_TRANSACTION_RISK_VIEW();
}