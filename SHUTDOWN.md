# MariaDB Graceful Shutdown

This MariaDB container includes a robust shutdown script that gracefully stops the database server with proper cleanup and timeout handling.

## Quick Start

### From Host (Docker)
```bash
# Basic graceful shutdown
./mariadb_shutdown --container mariadb-container

# With custom timeout and force fallback
./mariadb_shutdown --container mariadb-container --timeout 120 --force
```

### Inside Container
```bash
# Basic graceful shutdown
docker exec mariadb-container mariadb_shutdown

# With custom timeout and force fallback
docker exec mariadb-container mariadb_shutdown --timeout 120 --force
```

## Features

### 🛡️ **Graceful Shutdown**
- Uses `mariadb-admin shutdown` for clean database closure
- Waits for active transactions to complete
- Ensures proper data consistency and integrity
- Flushes buffers and closes file handles cleanly

### ⏱️ **Configurable Timeout**
- Default 60-second timeout for graceful shutdown
- Customizable via `--timeout` parameter
- Prevents indefinite hanging on stuck connections

### 🔨 **Force Shutdown Fallback**
- Optional `--force` flag for emergency situations
- Attempts SIGTERM then SIGKILL if graceful shutdown fails
- Uses PID file detection and process management
- Last resort for unresponsive database instances

### 🎯 **Dual Usage Mode**
- **Host Mode**: Run from Docker host targeting container
- **Container Mode**: Run inside container directly
- Automatic detection of execution environment

## Command Options

| Option | Description | Default |
|--------|-------------|---------|
| `-t, --timeout <seconds>` | Maximum time to wait for graceful shutdown | 60 |
| `-f, --force` | Force kill if graceful shutdown times out | false |
| `-c, --container <name>` | Target Docker container (host mode only) | none |
| `-h, --help` | Show usage information | - |

## Usage Examples

### Basic Operations
```bash
# Standard graceful shutdown
./mariadb_shutdown --container mariadb-container

# Quick shutdown with 30s timeout
./mariadb_shutdown --container mariadb-container --timeout 30

# Emergency shutdown with force fallback
./mariadb_shutdown --container mariadb-container --force
```

### Production Scenarios
```bash
# Maintenance shutdown with generous timeout
./mariadb_shutdown --container mariadb-container --timeout 300

# Emergency stop for unresponsive database
./mariadb_shutdown --container mariadb-container --timeout 10 --force

# Inside container during automated scripts
docker exec mariadb-container mariadb_shutdown --timeout 180
```

### Integration with Scripts
```bash
#!/bin/bash
# Backup and shutdown routine

echo "Creating backup..."
docker exec mariadb-container mariadb-dump --all-databases > backup.sql

echo "Shutting down database..."
if ./mariadb_shutdown --container mariadb-container --timeout 120; then
    echo "Shutdown successful"
else
    echo "Shutdown failed"
    exit 1
fi
```

## Exit Codes

| Code | Meaning |
|------|---------|
| `0` | Success - MariaDB stopped gracefully |
| `1` | Error - Shutdown failed |
| `2` | Warning - Graceful timeout, but may have succeeded |

## Best Practices

### 🎯 **Production Use**
- Use longer timeouts (120-300s) for production systems
- Always monitor shutdown logs for any warnings
- Consider `--force` only for emergency maintenance
- Test shutdown procedures during maintenance windows

### 🔄 **Automated Operations**
```bash
# Good: Reasonable timeout with force fallback
./mariadb_shutdown --container mariadb-container --timeout 180 --force

# Avoid: Too short timeout without fallback
./mariadb_shutdown --container mariadb-container --timeout 5
```

### 📊 **Monitoring Integration**
```bash
# Log shutdown operations
./mariadb_shutdown --container mariadb-container 2>&1 | tee shutdown.log

# Check exit code for automation
if ! ./mariadb_shutdown --container mariadb-container; then
    send_alert "MariaDB shutdown failed"
fi
```

## Troubleshooting

### Shutdown Hangs
If shutdown consistently hangs, check for:
- Long-running transactions
- Locked tables
- Replication issues
- Slow queries

```bash
# Before shutdown, check active processes
docker exec mariadb-container mariadb -e "SHOW PROCESSLIST;"

# Check for locked tables
docker exec mariadb-container mariadb -e "SHOW OPEN TABLES WHERE In_use > 0;"
```

### Force Shutdown Required
If graceful shutdown consistently fails:
```bash
# Check MariaDB error log
docker logs mariadb-container | tail -50

# Use force shutdown as last resort
./mariadb_shutdown --container mariadb-container --force
```

### Permission Issues
```bash
# Ensure script is executable
chmod +x mariadb_shutdown

# Verify container access
docker exec mariadb-container whoami
```

## Integration with Docker Compose

### docker-compose.yml
```yaml
services:
  mariadb:
    # ... existing configuration ...
    
  shutdown:
    image: mariadb-mariadb:latest
    command: mariadb_shutdown --timeout 180
    depends_on:
      - mariadb
    profiles:
      - shutdown
```

### Usage
```bash
# Shutdown via compose profile
docker-compose --profile shutdown up shutdown
```

This shutdown script provides enterprise-grade database shutdown capabilities with proper error handling, timeouts, and fallback mechanisms for reliable MariaDB operations! 🏆
