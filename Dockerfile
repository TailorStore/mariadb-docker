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
