--Creeaza endpoint-uri REST publicate prin ORDS în format JSON pentru view-urile din Oracle 'OLAP_FRAUD_BY_RISK', 'OLAP_FRAUD_BY_TYPE', 'OLAP_CUBE_ANALYSIS' si 'OLAP_ROLLUP_TIME'

BEGIN
  ORDS.ENABLE_OBJECT(
    p_enabled => TRUE,
    p_schema => 'FDBO',
    p_object => 'OLAP_FRAUD_BY_RISK',
    p_object_type => 'VIEW',
    p_object_alias => 'fraud_risk',
    p_auto_rest_auth => FALSE
  );

  ORDS.ENABLE_OBJECT(
    p_enabled => TRUE,
    p_schema => 'FDBO',
    p_object => 'OLAP_FRAUD_BY_TYPE',
    p_object_type => 'VIEW',
    p_object_alias => 'fraud_type',
    p_auto_rest_auth => FALSE
  );

  ORDS.ENABLE_OBJECT(
    p_enabled => TRUE,
    p_schema => 'FDBO',
    p_object => 'OLAP_CUBE_ANALYSIS',
    p_object_type => 'VIEW',
    p_object_alias => 'cube_analysis',
    p_auto_rest_auth => FALSE
  );

  ORDS.ENABLE_OBJECT(
    p_enabled => TRUE,
    p_schema => 'FDBO',
    p_object => 'OLAP_ROLLUP_TIME',
    p_object_type => 'VIEW',
    p_object_alias => 'rollup_time',
    p_auto_rest_auth => FALSE
  );

  COMMIT;
END;
/