# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Docker development environment repository that provides containerized database services (MySQL, PostgreSQL, Oracle, Neo4j) and Java development environments for Spring Boot applications. The architecture uses docker-compose to orchestrate multiple database containers with a Java development container.

## Architecture

### Service Structure
The repository defines multiple services in `docker-compose.yml`:
- **java-dev**: Java 21 development environment with Gradle 8.14 (uses `java-env/Dockerfile`)
- **mysql-db**: MySQL 8.0 database (port 3306)
- **postgres-db**: PostgreSQL 16 database (port 5432)
- **oracle-db**: Oracle XE 21 database (port 1521, SID: XE)
- **neo4j-db**: Neo4j graph database (ports 7474/7687) - note: not yet in docker-compose.yml but Dockerfile exists

### Two Java Environment Variants
1. **java-env/**: Alpine-based (eclipse-temurin:21-jdk-alpine), lightweight, Gradle pre-installed
2. **springboot/**: Ubuntu 22.04-based, uses SDKMAN for Java/Gradle version management

The `java-dev` service in docker-compose.yml currently uses the Alpine variant (`java-env/`).

### Networking
All services communicate through a bridge network named `my-network`. The Java dev container can connect to databases using service names (e.g., `mysql-db:3306`, `postgres-db:5432`, `oracle-db:1521`).

### Environment Configuration
All passwords and database names are defined in `.env` file (see `env.example` for template). Environment variables are passed to containers via docker-compose.yml and are available as Spring datasource properties in the java-dev container.

## Common Commands

### Docker Compose Operations

Start all services:
```bash
docker-compose up -d
```

Start with rebuild:
```bash
docker-compose up --build -d
```

Start specific service:
```bash
docker-compose up -d mysql-db
```

Stop and remove containers:
```bash
docker-compose down
```

Stop and remove including volumes:
```bash
docker-compose down -v
```

View logs:
```bash
docker-compose logs -f
docker-compose logs -f java-dev
```

Check service status:
```bash
docker-compose ps
```

Execute commands in running container:
```bash
docker-compose exec java-dev bash
docker-compose exec mysql-db mysql -u devuser -p
```

### Individual Service Build/Run

Build and run java-env standalone (using `makerun.sh`):
```bash
cd java-env
docker build -t java-env:latest .
docker run --name java-env-container -it java-env:latest bash
```

Build specific database:
```bash
docker-compose build mysql-db
docker-compose build postgres-db
```

### Database Connections

From java-dev container, databases are accessible at:
- MySQL: `jdbc:mysql://mysql-db:3306/devdb`
- PostgreSQL: `jdbc:postgresql://postgres-db:5432/devdb`
- Oracle: `jdbc:oracle:thin:@oracle-db:1521:XE`
- Neo4j: `bolt://neo4j-db:7687` (when added to docker-compose)

Default credentials are in `.env` (typically devuser/devpass for app users).

## Important Notes

### Database Persistence
All databases use named volumes (mysql_data, postgres_data, oracle_data) for data persistence. Use `docker-compose down -v` only when you want to completely wipe database data.

### Oracle Database
Uses gvenzl/oracle-xe:21-slim-faststart image. Environment variables:
- `ORACLE_PASSWORD`: Password for SYS/SYSTEM users
- `APP_USER`/`APP_USER_PASSWORD`: Application user credentials (auto-created)

### PostgreSQL Build Args
PostgreSQL Dockerfile accepts build-time arguments that are passed from docker-compose.yml:
- `POSTGRES_DB_ARG`
- `POSTGRES_USER_ARG`
- `POSTGRES_PASSWORD_ARG`

### Neo4j Service
Neo4j has a Dockerfile and makerun.sh script but is NOT currently included in docker-compose.yml. To add it, you would need to add a neo4j-db service definition similar to other database services.

### Java Environment
The java-dev container has:
- Eclipse Temurin 21 JDK
- Gradle 8.14
- Git, curl, bash, sudo, mysql-client
- Timezone: Asia/Seoul
- Locale: ko_KR.UTF-8
- Working directory: /home/workspace

The container runs with tty/stdin_open enabled for interactive development.

### File References
- Main orchestration: `docker-compose.yml:1`
- Environment variables: `.env:1`
- Java dev Dockerfile: `java-env/Dockerfile:1`
- Alternative Java Dockerfile: `springboot/Dockerfile:1` (SDKMAN-based)
- Helper scripts: `makerun.sh:1` (docker-compose commands reference)
