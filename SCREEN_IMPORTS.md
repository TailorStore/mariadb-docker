# Screen-Based Database Imports

This MariaDB container includes `screen` functionality for running long database imports that can survive SSH disconnections and continue running in the background.

## Quick Start

### Start Import in Screen Session
```bash
docker exec -it mariadb-container import_in_screen
```

### List Active Import Sessions
```bash
docker exec -it mariadb-container import_in_screen --list
```

### Attach to Running Import
```bash
docker exec -it mariadb-container import_in_screen --attach
```

## Use Cases

### 1. **Large Database Imports**
For multi-gigabyte database imports that take hours to complete:
```bash
# Start the import in a detached screen session
docker exec -it mariadb-container import_in_screen

# Detach safely using Ctrl+A, D
# The import continues running in the background
```

### 2. **Remote Server Management**
When managing databases over SSH where connections might drop:
```bash
# Start import
ssh user@server "docker exec -it mariadb-container import_in_screen"

# If SSH disconnects, reconnect and attach
ssh user@server "docker exec -it mariadb-container import_in_screen --attach"
```

### 3. **Monitoring Long Operations**
Check progress on long-running imports without interruption:
```bash
# Start import and detach
docker exec -it mariadb-container import_in_screen
# Press Ctrl+A, D to detach

# Later, check progress
docker exec -it mariadb-container import_in_screen --attach
```

## Screen Commands

When attached to a screen session, these keyboard shortcuts are available:

| Command | Action |
|---------|--------|
| `Ctrl+A, D` | **Detach** from session (import continues) |
| `Ctrl+A, K` | **Kill** current session |
| `Ctrl+A, C` | **Create** new window in session |
| `Ctrl+A, N` | **Next** window |
| `Ctrl+A, P` | **Previous** window |
| `Ctrl+A, ?` | **Help** - show all commands |

## Import Script Features

The `import_in_screen` wrapper provides:

- ✅ **Automatic session naming** with timestamps
- ✅ **Session management** (list, attach, kill)
- ✅ **Auto-attach** to new sessions
- ✅ **Progress monitoring** with pv bars
- ✅ **Import optimization** (2-5x faster)
- ✅ **Production-safe restoration** after import

## Examples

### Basic Import
```bash
# Start interactive import in screen
docker exec -it mariadb-container import_in_screen

# Select database file from S3
# Confirm import
# Detach with Ctrl+A, D if needed
```

### Background Management
```bash
# Check what's running
docker exec -it mariadb-container import_in_screen --list

# Output:
# [INFO] Active database import screen sessions:
# There are screens on:
#     12345.db_import_20250911_082710 (Detached)

# Attach to running import
docker exec -it mariadb-container import_in_screen --attach
```

### Cleanup
```bash
# Kill all import sessions if needed
docker exec -it mariadb-container import_in_screen --kill
```

## Benefits

### 🚀 **Performance**
- **2-5x faster imports** with automatic optimization
- **Progress monitoring** with transfer rates and ETA
- **Memory-optimized** settings during import

### 🛡️ **Reliability**  
- **Connection resilience** - survives SSH disconnections
- **Background execution** - imports continue when detached
- **Session recovery** - easily reconnect to running imports

### 🎯 **Production Ready**
- **Safe for production** - automatic setting restoration
- **Non-disruptive** - can run alongside live traffic
- **Comprehensive logging** - full import history preserved

## Troubleshooting

### No Screen Sessions Found
```bash
# If no sessions are listed, the import may have completed
docker exec -it mariadb-container screen -ls

# Check container logs for completed imports
docker logs mariadb-container | tail -50
```

### Session Won't Attach  
```bash
# If attachment fails, try listing all screen sessions
docker exec -it mariadb-container screen -ls

# Attach to specific session by name
docker exec -it mariadb-container screen -r db_import_20250911_082710
```

### Import Stuck
```bash
# Check MariaDB process status
docker exec mariadb-container mariadb -u root -p -e "SHOW PROCESSLIST;"

# Check system resources
docker exec mariadb-container top
```

This screen-based approach makes database imports robust, monitorable, and suitable for production environments with large datasets! 🏆
