FROM mariadb:lts

# Environment variables will be set by docker-compose or at runtime
# Default database name (non-sensitive)
ENV MYSQL_DATABASE=myapp
ENV MYSQL_USER=appuser

# Install MySQLTuner, Fish shell, and required dependencies
RUN apt-get update && apt-get install -y \
    wget \
    perl \
    fish \
    && rm -rf /var/lib/apt/lists/*

# Download and install MySQLTuner
RUN wget https://raw.githubusercontent.com/major/MySQLTuner-perl/master/mysqltuner.pl -O /usr/local/bin/mysqltuner.pl \
    && chmod +x /usr/local/bin/mysqltuner.pl

# Set Fish as the default shell for root
RUN chsh -s /usr/bin/fish root

# Copy custom configuration to a dedicated location (avoid volume mount conflict)
COPY custom.cnf /etc/mysql/conf.d/99-custom.cnf

# Set proper permissions for configuration files
RUN chmod 644 /etc/mysql/conf.d/99-custom.cnf

# Create directory for initialization scripts
RUN mkdir -p /docker-entrypoint-initdb.d

# Set proper permissions
RUN chown -R mysql:mysql /var/lib/mysql

# Expose MariaDB port
EXPOSE 3306

# Use the default MariaDB entrypoint (let the base image handle it)
