---
name: setup-local
description: Local environment bootstrap, build, database initialization, and service startup for Yugastore. Use when a developer needs to prepare a fresh machine or verify the stack runs locally.
---

# setup-local

Use this skill when the task is to set up the local Yugastore stack, build the
modules, initialize YugabyteDB, or start the services.

## Prerequisites

- JDK 17 exactly. On macOS:
  ```sh
  export JAVA_HOME=$(brew --prefix openjdk@17)/libexec/openjdk.jdk/Contents/Home
  ```
- Docker for YugabyteDB only.
- Python 3 for the product-data loader.
- The repo’s bundled Maven wrapper: `./mvnw` or `mvnw.cmd`.

## Build

```sh
./mvnw -DskipTests -Dexec.skip=true package      # macOS / Linux
mvnw.cmd -DskipTests -Dexec.skip=true package    # Windows
```

`-Dexec.skip=true` is required because several module poms invoke Docker build
steps during package. Without the flag, a plain local-jar build can fail when
Docker is unavailable.

## Database setup

Start YugabyteDB with YSQL, YCQL, and the admin UI exposed:

```sh
docker run -d --name yugastore-db \
  -p 7001:7000 -p 9000:9000 -p 5433:5433 -p 9042:9042 \
  yugabytedb/yugabyte:latest bin/yugabyted start --daemon=false
```

Wait until `docker exec yugastore-db bin/yugabyted status` reports `Running`
and `YSQL Status: Ready`.

Then load schemas from inside the container:

```sh
docker cp resources/ yugastore-db:/tmp/resources
docker exec yugastore-db sh -c 'bin/ysqlsh -h $(hostname) -U yugabyte -d postgres -f /tmp/resources/schema.sql'
docker exec yugastore-db sh -c 'bin/ycqlsh $(hostname) 9042 -f /tmp/resources/schema.cql'
```

Load sample data from the host:

```sh
cd resources
python3 parse_metadata_json.py products.json
```

Then run the loader commands listed in `resources/dataload.sh` against
`localhost:9042`.

## Run the services

Start in this order, waiting a few seconds between steps:

1. `eureka-server-local`
2. `api-gateway-microservice`, `products-microservice`,
   `checkout-microservice`, `cart-microservice`
3. `react-ui`

Each service is run from its module directory as `java -jar target/*.jar`.

Verify service registration at `http://localhost:8761/eureka/apps`.

## Troubleshooting and gotchas

- The gateway URL is `http://localhost:8081`; the backend services are not the
  expected browser entry point.
- Product API routes are route-prefixed; direct service requests and gateway
  requests differ.
- The product catalog endpoints require both `limit` and `offset` query params.
- If the VM disk is full, YugabyteDB can reject writes with "insufficient disk
  space"; check `docker exec yugastore-db df -h /`.
- On macOS, avoid using port 7000 because AirPlay can claim it and make the
  Yugabyte admin UI inaccessible.

## Done when

A fresh local environment can build, initialize YugabyteDB, and start all
required services without relying on ad hoc one-off commands.
