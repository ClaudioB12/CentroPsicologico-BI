# Usar una imagen oficial de MySQL
FROM mysql:8.0

# Establecer el nombre de la base de datos
ENV MYSQL_DATABASE=dm_centro_psicologico

# Copiar el archivo de inicialización SQL
COPY init.sql /docker-entrypoint-initdb.d/

# Exponer el puerto por donde se conecta MySQL
EXPOSE 3306