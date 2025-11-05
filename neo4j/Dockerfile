# Dockerfile for Neo4j 5.x

# Set the base image - Neo4j 5.x
FROM neo4j:5-community

# 기본 데이터베이스를 csadb01로 설정
ENV NEO4J_initial_dbms_default__database=csadb01

# APOC 플러그인 활성화 (선택사항이지만 유용함)
ENV NEO4J_dbms_security_procedures_unrestricted=apoc.*
ENV NEO4J_dbms_security_procedures_allowlist=apoc.*

# 메모리 설정 (개발환경 최적화)
ENV NEO4J_dbms_memory_heap_initial__size=512m
ENV NEO4J_dbms_memory_heap_max__size=2G
ENV NEO4J_dbms_memory_pagecache_size=512m

# 원격 접속 허용
ENV NEO4J_dbms_connector_bolt_listen__address=0.0.0.0:7687
ENV NEO4J_dbms_connector_http_listen__address=0.0.0.0:7474

# Expose ports
# 7474 for HTTP (Neo4j Browser)
# 7687 for Bolt (Neo4j Driver)
EXPOSE 7474 7687

# 초기화 스크립트 복사
COPY init-neo4j.sh /docker-entrypoint-initdb.d/

# Set up volumes for data persistence
VOLUME /data
VOLUME /logs

# The base image's default CMD will run Neo4j
