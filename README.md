# MariaDB Docker Setup

This directory contains a Docker setup for MariaDB using the `mariadb:lts` image with host directory mounting for persistent data storage.

## Files

- `Dockerfile` - Custom MariaDB image configuration
- `docker-compose.yml` - Docker Compose configuration with volume mounts
- `custom.cnf` - Custom MariaDB configuration file
- `README.md` - This file

## Directory Structure

The setup will create the following directories on the host machine:

```
docker/mariadb/
├── Dockerfile
├── docker-compose.yml
├── custom.cnf
├── README.md
├── data/           # MariaDB data files (auto-created)
├── config/         # Additional config files (auto-created)
├── init/           # Initialization SQL scripts (auto-created)
└── backups/        # Database backups (auto-created)
```

## Usage

### Using Docker Compose (Recommended)

1. Navigate to the directory:
   ```bash
   cd docker/mariadb
   ```

2. Start the MariaDB container:
   ```bash
   docker-compose up -d
   ```

3. Connect to MariaDB (from host on port 3307):
   ```bash
   # Connect from inside the container
   docker exec -it mariadb-container mariadb -u root -p
   
   # Or connect from host machine
   mariadb -h 127.0.0.1 -P 3307 -u root -p
   ```

### Using Docker directly

1. Build the image:
   ```bash
   docker build -t custom-mariadb .
   ```

2. Run the container with volume mounts:
   ```bash
   docker run -d \
     --name mariadb-container \
     -p 3307:3306 \
     -v $(pwd)/data:/var/lib/mysql \
     -v $(pwd)/config:/etc/mysql/conf.d \
     -v $(pwd)/init:/docker-entrypoint-initdb.d \
     -v $(pwd)/backups:/backups \
     custom-mariadb
   ```

## Environment Variables

The container supports the following environment variables:

- `MYSQL_ROOT_PASSWORD`: Root password (default: rootpassword)
- `MYSQL_DATABASE`: Initial database name (default: myapp)
- `MYSQL_USER`: Application user (default: appuser)
- `MYSQL_PASSWORD`: Application user password (default: apppassword)

### Using Environment Variables for Security

For better security, you should set passwords using environment variables instead of using the defaults:

#### Method 1: Using .env file (Recommended)

1. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` with your secure passwords:
   ```bash
   nano .env
   ```

3. Start the container:
   ```bash
   docker-compose up -d
   ```

#### Method 2: Export environment variables

```bash
export MYSQL_ROOT_PASSWORD="your_secure_root_password"
export MYSQL_PASSWORD="your_secure_app_password"
docker-compose up -d
```

#### Method 3: Inline environment variables

```bash
MYSQL_ROOT_PASSWORD="your_secure_root_password" MYSQL_PASSWORD="your_secure_app_password" docker-compose up -d
```

## Mounted Directories

- `./data` → `/var/lib/mysql` - Persistent database storage
- `./config` → `/etc/mysql/conf.d` - Custom configuration files
- `./init` → `/docker-entrypoint-initdb.d` - Database initialization scripts
- `./backups` → `/backups` - Database backup storage

## Security Notes

⚠️ **Important Security Recommendations**:

1. **Never use default passwords in production!**
2. **Use the .env file approach** to keep passwords out of your docker-compose.yml
3. **Add `.env` to your `.gitignore`** to prevent accidentally committing passwords
4. **Use strong passwords** with a mix of letters, numbers, and symbols
5. **Consider using Docker secrets** for production deployments
6. **Regularly rotate your database passwords**

### .gitignore Entry

Add this to your `.gitignore` file to prevent committing sensitive environment files:
```
# Environment files with sensitive data
.env
```
