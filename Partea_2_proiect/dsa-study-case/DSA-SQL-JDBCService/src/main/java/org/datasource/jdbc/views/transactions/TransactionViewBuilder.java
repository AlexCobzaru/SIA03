package org.datasource.jdbc.views.transactions;

import org.datasource.jdbc.JDBCDataSourceConnector;
import org.springframework.stereotype.Service;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

@Service
public class TransactionViewBuilder {
    private static Logger logger = Logger.getLogger(TransactionViewBuilder.class.getName());

    private String SQL_TRANSACTIONS_SELECT = """
            SELECT
                client_id,
                step,
                type,
                amount,
                nameorig,
                namedest,
                isfraud,
                isflaggedfraud
            FROM customers.transactions
            LIMIT 25
            """;

    private List<TransactionView> transactionViewList = new ArrayList<>();

    private JDBCDataSourceConnector jdbcConnector;

    public TransactionViewBuilder(JDBCDataSourceConnector jdbcConnector) {
        this.jdbcConnector = jdbcConnector;
    }

    public List<TransactionView> getViewList() {
        return this.transactionViewList;
    }

    public TransactionViewBuilder build() {
        logger.info(">>> Building TransactionView");

        try (Connection jdbcConnection = jdbcConnector.getConnection()) {
            PreparedStatement selectStmt = jdbcConnection.prepareStatement(SQL_TRANSACTIONS_SELECT);
            ResultSet rs = selectStmt.executeQuery();

            transactionViewList = new ArrayList<>();

            while (rs.next()) {
                this.transactionViewList.add(new TransactionView(
                        rs.getInt("client_id"),
                        rs.getInt("step"),
                        rs.getString("type"),
                        rs.getBigDecimal("amount"),
                        rs.getString("nameorig"),
                        rs.getString("namedest"),
                        rs.getInt("isfraud"),
                        rs.getInt("isflaggedfraud")
                ));
            }

        } catch (Exception ex) {
            ex.printStackTrace();
        }

        return this;
    }
}