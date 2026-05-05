FROM confluentinc/cp-kafka-connect:7.5.0

# Debezium MySQL Source Connector (v2.4.2 - última versión en Confluent Hub)
RUN confluent-hub install --no-prompt debezium/debezium-connector-mysql:2.4.2

# Confluent JDBC Sink Connector (para escribir en PostgreSQL)
RUN confluent-hub install --no-prompt confluentinc/kafka-connect-jdbc:10.9.3

# Driver PostgreSQL JDBC (requerido por el JDBC sink)
RUN curl -fsSL -o /usr/share/confluent-hub-components/confluentinc-kafka-connect-jdbc/lib/postgresql-42.7.4.jar \
    "https://repo1.maven.org/maven2/org/postgresql/postgresql/42.7.4/postgresql-42.7.4.jar"
