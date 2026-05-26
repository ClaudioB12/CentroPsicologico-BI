FROM python:3.11-slim

WORKDIR /dbt

RUN apt-get update \
    && apt-get install -y --no-install-recommends git \
    && rm -rf /var/lib/apt/lists/* \
    && pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir dbt-core dbt-postgres

COPY . .

CMD ["sh", "-c", "\
  echo '>>> Esperando snapshot inicial de CDC (60s)...' && sleep 60 && \
  echo '>>> Ejecutando dbt por primera vez...' && \
  dbt run --profiles-dir /dbt --project-dir /dbt && \
  echo '>>> Datamart listo. Refreshing cada 5 minutos...' && \
  while true; do \
    sleep 300; \
    echo '>>> Refreshing datamart...'; \
    dbt run --profiles-dir /dbt --project-dir /dbt; \
  done"]