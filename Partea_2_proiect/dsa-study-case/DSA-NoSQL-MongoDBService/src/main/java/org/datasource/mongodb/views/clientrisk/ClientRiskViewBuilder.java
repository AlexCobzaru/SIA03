package org.datasource.mongodb.views.clientrisk;

import com.mongodb.client.FindIterable;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import org.bson.Document;
import org.datasource.mongodb.MongoDataSourceConnector;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

@Service
public class ClientRiskViewBuilder {
    private static final Logger logger = Logger.getLogger(ClientRiskViewBuilder.class.getName());

    private final String collectionName = "client_risk";

    private List<ClientRiskView> viewList = new ArrayList<>();

    private MongoDataSourceConnector mongoConnector;

    public ClientRiskViewBuilder(MongoDataSourceConnector mongoConnector) {
        this.mongoConnector = mongoConnector;
    }

    public List<ClientRiskView> getViewList() {
        return this.viewList;
    }

    public ClientRiskViewBuilder build() {
        logger.info(">>> Building ClientRiskView from MongoDB collection: " + collectionName);

        this.viewList = new ArrayList<>();

        try {
            MongoDatabase database = mongoConnector.getMongoDatabase();
            MongoCollection<Document> collection = database.getCollection(collectionName);

            FindIterable<Document> documents = collection.find().limit(100);

            for (Document doc : documents) {
                Integer clientId = getInteger(doc, "client_id", "clientId", "CLIENT_ID");
                Double riskScore = getDouble(doc, "risk_score", "riskScore", "RISK_SCORE");
                String currency = getString(doc, "currency", "CURRENCY");
                String status = getString(doc, "status", "STATUS");

                this.viewList.add(new ClientRiskView(
                        clientId,
                        riskScore,
                        currency,
                        status
                ));
            }

        } catch (Exception ex) {
            ex.printStackTrace();
        }

        return this;
    }

    private String getString(Document doc, String... keys) {
        for (String key : keys) {
            Object value = doc.get(key);
            if (value != null) {
                return value.toString();
            }
        }
        return null;
    }

    private Integer getInteger(Document doc, String... keys) {
        for (String key : keys) {
            Object value = doc.get(key);
            if (value == null) {
                continue;
            }

            try {
                if (value instanceof Integer) {
                    return (Integer) value;
                }
                if (value instanceof Number) {
                    return ((Number) value).intValue();
                }
                return Integer.parseInt(value.toString());
            } catch (Exception ignored) {
            }
        }
        return null;
    }

    private Double getDouble(Document doc, String... keys) {
        for (String key : keys) {
            Object value = doc.get(key);
            if (value == null) {
                continue;
            }

            try {
                if (value instanceof Double) {
                    return (Double) value;
                }
                if (value instanceof Number) {
                    return ((Number) value).doubleValue();
                }
                return Double.parseDouble(value.toString());
            } catch (Exception ignored) {
            }
        }
        return null;
    }
}