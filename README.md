# hbase-hive-solr-Integrated

# Contents :
1. [Requirements](#requirements)
2. [Instructions](#instructions)
3. [Note](#note)

#### Here is the apropriate Docker Images for setting up Apache Hbase + Hive in one container and Apache Solr in another. The steps to run these are as follows

# Requirements

- Docker version 20 and above
  
- Linux System (preferably Ubuntu 18 and above, with over 12 GB of RAM and sufficient disk space, say 20+ GB)
  

# Instructions

### Running Solr using Compose

After cloning the repository, in one terminal instance, run the following

```shell
sudo docker-compose up
```

Or

```bash
sudo docker compose up -d
```

### Running Hbase and Hive Integrations :

In another terminal instance,

- Build the image from the repository,
  
  ```bash
  sudo docker build -t <image-name> .
  ```
  
- Create and Run the container instance,
  
  ```bash
  sudo docker run -it --name <container-name> --hostname bigdata -p 50070:50070 -p 8088:8088 -p 10020:10020 -p 9042:9042 -p 10000:10000 -p 10001:10001 -p 10002:10002 <image-name>
  ```
  
- When the Hive Shell pops up, enter the following Hive Queries,
  
  ```sql
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
  ```
  

Note that " 'solr.server.url' = 'http://172.17.0.3:8983/solr' " is the Docker IP allocated to the before said Solr container, which can be viewed by

```shell
sudo docker network inspect bridge
```

Now the data in 'data.csv' file is **indexed** and **mapped** to Solr collection using Hbase-Hive bridge.

# Note

- You can make changes in the Dockerfile provided if you don't want to pop up the hive shell (Details are provided inside Dockerfile comments)
  
- The Solr instance is using local file system for storing indexes, not HDFS. (ToDo)
