CREATE OR REPLACE FUNCTION get_restheart_data_media(
    pURL VARCHAR2,
    pUserPass VARCHAR2
) RETURN CLOB IS
    l_req    UTL_HTTP.req;
    l_resp   UTL_HTTP.resp;
    l_text   VARCHAR2(32767);
    l_clob   CLOB;
BEGIN
    DBMS_LOB.createtemporary(l_clob, TRUE);

    l_req := UTL_HTTP.begin_request(pURL);

    UTL_HTTP.set_header(
        l_req,
        'Authorization',
        'Basic ' ||
        UTL_RAW.cast_to_varchar2(
            UTL_ENCODE.base64_encode(
                UTL_I18N.string_to_raw(pUserPass, 'AL32UTF8')
            )
        )
    );

    l_resp := UTL_HTTP.get_response(l_req);

    BEGIN
        LOOP
            UTL_HTTP.read_text(l_resp, l_text, 32767);
            DBMS_LOB.writeappend(l_clob, LENGTH(l_text), l_text);
        END LOOP;
    EXCEPTION
        WHEN UTL_HTTP.end_of_body THEN
            UTL_HTTP.end_response(l_resp);
    END;

    RETURN l_clob;
END;
/

SELECT get_restheart_data_media(
    'http://localhost:8081/client_risk',
    'admin:secret'
) AS json_doc
FROM dual;