#!/bin/bash
# 准备DB环境
docker rm -f OracleVeridata
docker rm -f OracleVeridata_db
docker run -d \
  --name OracleVeridata_db \
  -p 61521:1521 \
  --restart=unless-stopped \
  registry.cn-hangzhou.aliyuncs.com/hd2020/ka:oracle11.2.0.4.190416
# docker logs -f --tail 100 OracleVeridata_db
time sleep 120;
# 编译
docker build --no-cache -t oracleveridata220228 .
# 运行
docker rm -f OracleVeridata
docker run -d \
  --name OracleVeridata \
  -p 7001:7001 \
  -p 8830:8830 \
  --restart=unless-stopped \
  oracleveridata220228
docker logs -f --tail 100 OracleVeridata

