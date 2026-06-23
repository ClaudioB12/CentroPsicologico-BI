#!/bin/sh
# Registra conectores Debezium en Kafka Connect (se ejecuta una sola vez al iniciar)

CONNECT_URL="http://kafka-connect:8083"

wait_for_connect() {
  echo ">>> Esperando que Kafka Connect esté listo..."
  until curl -sf "${CONNECT_URL}/connectors" > /dev/null 2>&1; do
    echo "    No disponible aún, reintentando en 5s..."
    sleep 5
  done
  echo ">>> Kafka Connect listo!"
}

register() {
  NAME=$1
  FILE=$2
  echo ""
  echo ">>> Registrando conector: ${NAME}"
  RESULT=$(curl -s -o /tmp/resp.json -w "%{http_code}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data @"${FILE}" \
    "${CONNECT_URL}/connectors")
  cat /tmp/resp.json
  echo ""
  if [ "$RESULT" = "201" ] || [ "$RESULT" = "200" ]; then
    echo "    OK (HTTP ${RESULT})"
  else
    echo "    ADVERTENCIA: HTTP ${RESULT} — puede que ya exista o haya un error"
  fi
}

wait_for_connect
register "mysql-source-connector"   "/connectors/mysql-source.json"
sleep 8
register "postgres-sink-connector"  "/connectors/postgres-sink.json"

echo ""
echo ">>> Estado de conectores:"
sleep 5
curl -s "${CONNECT_URL}/connectors?expand=status" | cat
echo ""
echo ">>> Pipeline CDC registrado. MySQL → Kafka → PostgreSQL activo."
