FROM joegagliardo/bigdata:latest
COPY data.csv /
RUN scripts/stop-everything.sh
RUN ls scripts/
RUN scripts/stop-thrift.sh
RUN git clone https://github.com/abhayhk2001/hive-solr
WORKDIR hive-solr
RUN ls
RUN git submodule init
RUN git submodule update
RUN ./gradlew clean shadowJar --info
WORKDIR /
COPY commands.hql /
CMD etc/bootstrap.sh && scripts/stop-everything.sh && (jps | egrep -v 'Jps' | awk '{print $1}' | xargs -t kill) && scripts/start-everything.sh && hive --auxpath hive-solr/solr-hive-serde/build/libs/

# For Including files containing hive commands, COMMENT ABOVE AND UNCOMMENT THE FOLLOWING
# CMD etc/bootstrap.sh && scripts/stop-everything.sh && (jps | egrep -v 'Jps' | awk '{print $1}' | xargs -t kill) && scripts/start-everything.sh && hbase shell && hive --auxpath hive-solr/solr-hive-serde/build/libs/ -f commands.hql
