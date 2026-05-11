package org.datasource;

import org.datasource.poi.clientprofiles.ClientProfileView;
import org.datasource.poi.clientprofiles.ClientProfileViewBuilder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.logging.Logger;

@RestController
@RequestMapping("/customers")
public class RESTViewServiceXLS {
    private static Logger logger = Logger.getLogger(RESTViewServiceXLS.class.getName());

    @RequestMapping(value = "/ping", method = RequestMethod.GET,
            produces = {MediaType.TEXT_PLAIN_VALUE})
    @ResponseBody
    public String pingDataSource() {
        logger.info(">>>> DSA-DOC-XLSService:: Client Profile REST Service is Up!");
        return "PING response from DSA-DOC-XLSService!";
    }

    @RequestMapping(value = "/ClientProfileView", method = RequestMethod.GET,
            produces = {MediaType.APPLICATION_JSON_VALUE, MediaType.APPLICATION_XML_VALUE})
    @ResponseBody
    public List<ClientProfileView> get_ClientProfileView() throws Exception {
        return this.clientProfileViewBuilder.build().getViewList();
    }

    @Autowired
    private ClientProfileViewBuilder clientProfileViewBuilder;
}