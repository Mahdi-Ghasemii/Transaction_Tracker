FROM postgres

ENV POSTGRES_USER=mahdi
ENV POSTGRES_PASSWORD=1234
ENV POSTGRES_DB=bank

COPY 01_Branch.sql /docker-entrypoint-initdb.d/
COPY 01_Customer.sql /docker-entrypoint-initdb.d/
COPY 01_Deposit_Status.sql /docker-entrypoint-initdb.d/
COPY 01_Deposit_Type.sql /docker-entrypoint-initdb.d/
COPY 02_Deposit.sql /docker-entrypoint-initdb.d/
COPY 03_Transaction.sql /docker-entrypoint-initdb.d/
COPY 04_MainQuery.sql /docker-entrypoint-initdb.d/
COPY 04_part1.sql /docker-entrypoint-initdb.d/
COPY 04_part2.sql /docker-entrypoint-initdb.d/

EXPOSE 5432