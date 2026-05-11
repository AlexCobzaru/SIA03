package org.j4di;

import org.j4di.analytical.views.OLAP_FRAUD_BY_RISK_SPARK;
import org.j4di.analytical.views.OLAP_FRAUD_BY_RISK_SPARK_Repository;
import org.j4di.analytical.views.OLAP_FRAUD_BY_TYPE_SPARK;
import org.j4di.analytical.views.OLAP_FRAUD_BY_TYPE_SPARK_Repository;
import org.j4di.integration.views.CLIENT_TRANSACTION_RISK_VIEW;
import org.j4di.integration.views.CLIENT_TRANSACTION_RISK_VIEW_Repository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.logging.Logger;

/*
    REST Service URL:
    http://localhost:8096/DSA-WEB-RESTService/rest/OLAP/ping

    Integrated view:
    http://localhost:8096/DSA-WEB-RESTService/rest/OLAP/CLIENT_TRANSACTION_RISK_VIEW

    Analytical views:
    http://localhost:8096/DSA-WEB-RESTService/rest/OLAP/OLAP_FRAUD_BY_TYPE_SPARK
    http://localhost:8096/DSA-WEB-RESTService/rest/OLAP/OLAP_FRAUD_BY_RISK_SPARK
*/
@RestController
@RequestMapping("/OLAP")
public class RESTViewService {

    private static Logger logger = Logger.getLogger(RESTViewService.class.getName());

    @RequestMapping(value = "/ping", method = RequestMethod.GET,
            produces = {MediaType.TEXT_PLAIN_VALUE})
    @ResponseBody
    public String pingDataSource() {
        logger.info(">>>> DSA-WEB-RESTService:: Fraud RESTViewService is Up!");
        return "Ping response from DSA-WEB-RESTService - Fraud Analytics!";
    }

    @Autowired
    private CLIENT_TRANSACTION_RISK_VIEW_Repository clientTransactionRiskRepository;

    @GetMapping(value = "/CLIENT_TRANSACTION_RISK_VIEW",
            produces = {MediaType.APPLICATION_JSON_VALUE})
    @ResponseBody
    public List<CLIENT_TRANSACTION_RISK_VIEW> get_CLIENT_TRANSACTION_RISK_VIEW() {
        return this.clientTransactionRiskRepository.get_CLIENT_TRANSACTION_RISK_VIEW();
    }

    @Autowired
    private OLAP_FRAUD_BY_TYPE_SPARK_Repository olapFraudByTypeRepository;

    @GetMapping(value = "/OLAP_FRAUD_BY_TYPE_SPARK",
            produces = {MediaType.APPLICATION_JSON_VALUE})
    @ResponseBody
    public List<OLAP_FRAUD_BY_TYPE_SPARK> get_OLAP_FRAUD_BY_TYPE_SPARK() {
        return this.olapFraudByTypeRepository.get_OLAP_FRAUD_BY_TYPE_SPARK();
    }

    @Autowired
    private OLAP_FRAUD_BY_RISK_SPARK_Repository olapFraudByRiskRepository;

    @GetMapping(value = "/OLAP_FRAUD_BY_RISK_SPARK",
            produces = {MediaType.APPLICATION_JSON_VALUE})
    @ResponseBody
    public List<OLAP_FRAUD_BY_RISK_SPARK> get_OLAP_FRAUD_BY_RISK_SPARK() {
        return this.olapFraudByRiskRepository.get_OLAP_FRAUD_BY_RISK_SPARK();
    }
}