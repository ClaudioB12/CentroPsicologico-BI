FROM python:3.11-slim

RUN pip install --no-cache-dir dbt-postgres==1.8.2

WORKDIR /dbt
COPY . .

ENTRYPOINT ["sh", "-c", \
  "echo 'Esperando que CDC complete el snapshot inicial...' && sleep 60 && \
   dbt run --profiles-dir /dbt --project-dir /dbt && \
   echo 'dbt finalizado correctamente.'"]
