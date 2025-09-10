FROM mariadb:lts

# Environment variables will be set by docker-compose or at runtime
# Default database name (non-sensitive)
ENV MYSQL_DATABASE=myapp
ENV MYSQL_USER=appuser

# Create directory for custom configuration
RUN mkdir -p /etc/mysql/conf.d

# Copy custom configuration if it exists
COPY custom.cnf /etc/mysql/conf.d/

# Create directory for initialization scripts
RUN mkdir -p /docker-entrypoint-initdb.d

# Set proper permissions
RUN chown -R mysql:mysql /var/lib/mysql

# Expose MariaDB port
EXPOSE 3306

# Use the default MariaDB entrypoint (let the base image handle it)
