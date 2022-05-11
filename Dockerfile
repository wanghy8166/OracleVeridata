# FROM oracle/oggvdt:12.2.1.4-220228
FROM registry.cn-hangzhou.aliyuncs.com/hd2020/ka:OracleVeridata-12.2.1.4-220228

user root
# wget https://yum.oracle.com/repo/OracleLinux/OL7/latest/x86_64/getPackage/vim-minimal-7.4.629-8.0.1.el7_9.x86_64.rpm
copy vim-minimal-7.4.629-8.0.1.el7_9.x86_64.rpm /tmp/
run rpm -ivh /tmp/vim-minimal-7.4.629-8.0.1.el7_9.x86_64.rpm && \
rm -rf /tmp/vim-minimal-7.4.629-8.0.1.el7_9.x86_64.rpm

user oracle
copy rcuResponseFile.properties /tmp/
copy passwordfile.txt /tmp/
copy domain_silent.properties /tmp/

run /u01/oracle/oracle_common/bin/rcu -silent -responseFile /tmp/rcuResponseFile.properties -f < /tmp/passwordfile.txt && \
/u01/oracle/veridata/bin/domain_silent.sh /tmp/domain_silent.properties && \
mkdir -p /u01/oracle/base_domain/servers/AdminServer/security && \
mkdir -p /u01/oracle/base_domain/servers/VERIDATA_server1/security && \
rm -rf /tmp/*.map && \
mkdir -p /u01/oracle/agent1 && \
$ORACLE_HOME/veridata/agent/agent_config.sh /u01/oracle/agent1 && \
cp /u01/oracle/oracle_common/modules/oracle.jdbc/ojdbc8.jar /u01/oracle/agent1/drivers/ && \
cp /u01/oracle/oracle_common/modules/mysql-connector-java-commercial-8.0.14/mysql-connector-java-commercial-8.0.14.jar /u01/oracle/agent1/drivers/ && \
cp /u01/oracle/oracle_common/modules/datadirect/wlsqlserver.jar /u01/oracle/agent1/drivers/ && \
mkdir -p /u01/oracle/agent2 && \
$ORACLE_HOME/veridata/agent/agent_config.sh /u01/oracle/agent2 && \
cp /u01/oracle/oracle_common/modules/oracle.jdbc/ojdbc8.jar /u01/oracle/agent2/drivers/ && \
cp /u01/oracle/oracle_common/modules/mysql-connector-java-commercial-8.0.14/mysql-connector-java-commercial-8.0.14.jar /u01/oracle/agent2/drivers/ && \
cp /u01/oracle/oracle_common/modules/datadirect/wlsqlserver.jar /u01/oracle/agent2/drivers/

# wget --no-check-certificate https://jdbc.postgresql.org/download/postgresql-42.3.5.jar
copy postgresql-42.3.5.jar /u01/oracle/agent1/drivers/
copy postgresql-42.3.5.jar /u01/oracle/agent2/drivers/
copy agent1.properties /u01/oracle/agent1/
copy agent2.properties /u01/oracle/agent2/
copy boot.properties /u01/oracle/base_domain/servers/AdminServer/security/
copy boot.properties /u01/oracle/base_domain/servers/VERIDATA_server1/security/

EXPOSE        7001 8830
cmd nohup /u01/oracle/base_domain/bin/startWebLogic.sh >/tmp/startWebLogic.log 2>&1 & \
time sleep 180 && nohup /u01/oracle/base_domain/veridata/bin/veridataServer.sh start >/tmp/veridataServer-start.log 2>&1 & \
/u01/oracle/agent1/agent.sh start /u01/oracle/agent1/agent1.properties && \
/u01/oracle/agent2/agent.sh start /u01/oracle/agent2/agent2.properties && \
echo "请分别查看日志:" && \
echo "docker exec -it OracleVeridata tail -F /tmp/startWebLogic.log" && \
echo "docker exec -it OracleVeridata tail -F /tmp/veridataServer-start.log" && \
tail -F /dev/null

