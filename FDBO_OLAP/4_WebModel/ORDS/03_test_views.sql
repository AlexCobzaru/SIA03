SELECT object_name, object_type
FROM user_objects
WHERE object_name IN (
  'OLAP_FRAUD_BY_RISK',
  'OLAP_FRAUD_BY_TYPE',
  'OLAP_CUBE_ANALYSIS',
  'OLAP_ROLLUP_TIME'
);