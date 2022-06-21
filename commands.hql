CREATE TABLE data (id STRING, step BIGINT, type STRING, amount FLOAT, nameOrig STRING, oldbalanceOrg FLOAT, newbalanceOrig FLOAT, nameDest STRING, oldbalanceDest FLOAT, newbalanceDest FLOAT,isFruad  TINYINT, isFlaggedFruad TINYINT)
STORED BY 'org.apache.hadoop.hive.hbase.HBaseStorageHandler'
WITH SERDEPROPERTIES ("hbase.columns.mapping" = ":key,cf1:step,cf1:type,cf1:amount,cf1:nameOrig,cf1:oldbalanceOrg,cf1:newbalanceOrig,cf1:nameDest,cf1:oldbalanceDest,cf1:newbalanceDest,cf1:isFruad,cf1: isFlaggedFruad")
TBLPROPERTIES ("hbase.table.name" = "data");
CREATE TABLE temp_data (id STRING, step BIGINT, type STRING, amount FLOAT, nameOrig STRING, oldbalanceOrg FLOAT, newbalanceOrig FLOAT, nameDest STRING, oldbalanceDest FLOAT, newbalanceDest FLOAT,isFruad  TINYINT, isFlaggedFruad TINYINT) ROW FORMAT DELIMITED FIELDS TERMINATED BY ',';
LOAD DATA LOCAL INPATH 'data.csv' OVERWRITE INTO TABLE temp_data;
INSERT OVERWRITE TABLE data SELECT b.* FROM temp_data b;
select count(*) from data;
CREATE EXTERNAL TABLE solr_2 (id STRING, step_l BIGINT, type_s STRING, amount_f FLOAT, nameOrig_s STRING, oldbalanceOrg_f FLOAT, newbalanceOrig_f FLOAT, nameDest_s STRING, oldbalanceDest_f FLOAT, newbalanceDest_f FLOAT,isFruad_i  TINYINT, isFlaggedFruad_i TINYINT)
STORED BY 'com.lucidworks.hadoop.hive.LWStorageHandler'
TBLPROPERTIES('solr.server.url' = 'http://172.17.0.3:8983/solr',
'solr.collection' = 'solr_analysis',
'solr.query' = '*:*');
describe solr_2;
INSERT OVERWRITE TABLE solr_2 SELECT b.* FROM data b;