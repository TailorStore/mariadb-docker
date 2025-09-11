# MariaDB Restart Control

This guide explains how to control MariaDB container restart behavior, especially when using the shutdown script for maintenance or testing.

## The Problem

Docker Compose uses `restart: unless-stopped` by default, which means:
- ✅ **Production**: MariaDB automatically restarts if it crashes (good for reliability)
- ❌ **Testing**: MariaDB restarts immediately when you run shutdown scripts (prevents testing)

## Solutions

### 🎯 **Quick Solutions**

#### **Option 1: Use docker-compose stop (Recommended for most cases)**
```bash
# Stop container without triggering restart
docker-compose stop

# Start it back up
docker-compose up -d
```

#### **Option 2: Use the restart control script**
```bash
# Check current restart policy
./restart_control status

# Protected shutdown (disables restart, shuts down, waits for confirmation)
./restart_control shutdown

# Manual control
./restart_control disable    # Disable auto-restart
./restart_control enable     # Re-enable auto-restart
```

#### **Option 3: Manual policy change**
```bash
# Temporarily change restart policy to 'no'
sed -i.bak 's/restart: unless-stopped/restart: no/' docker-compose.yml

# Apply the change
docker-compose up -d --no-build

# Test shutdown script
./mariadb_shutdown --container mariadb-container

# Restore restart policy
sed -i.bak 's/restart: no/restart: unless-stopped/' docker-compose.yml
```

### 🔧 **Advanced Control with restart_control script**

#### **Check Status**
```bash
./restart_control status

# Output:
# [INFO] Current restart policy: unless-stopped
# [SUCCESS] Auto-restart is ENABLED
#   - MariaDB will restart automatically unless manually stopped
#   - Good for: Production, high availability
# [INFO] Container status: RUNNING
```

#### **Protected Shutdown Sequence**
```bash
./restart_control shutdown

# This will:
# 1. Disable auto-restart
# 2. Apply the policy change
# 3. Gracefully shutdown MariaDB
# 4. Wait for confirmation to re-enable restart
```

#### **Manual Policy Control**
```bash
# Disable auto-restart for maintenance
./restart_control disable

# Perform maintenance tasks...
./mariadb_shutdown --container mariadb-container
# Container stops and stays stopped

# Re-enable when done
./restart_control enable
docker-compose up -d
```

## Understanding Restart Policies

| Policy | Behavior | Use Case |
|--------|----------|----------|
| `no` | Never restart automatically | Testing, development, manual control |
| `unless-stopped` | Restart unless manually stopped | **Production (recommended)** |
| `always` | Always restart, even after manual stop | High-availability systems |
| `on-failure` | Only restart on error exit codes | Debug-friendly production |

## Common Scenarios

### 🧪 **Testing Shutdown Scripts**
```bash
# Method 1: Use restart control
./restart_control disable
./mariadb_shutdown --container mariadb-container
# Container stays stopped ✅

# Method 2: Use docker-compose
docker-compose stop
# Container stops and stays stopped ✅
```

### 🔧 **Maintenance Operations**
```bash
#!/bin/bash
# maintenance.sh - Safe maintenance script

echo "Starting maintenance..."

# Disable auto-restart
./restart_control disable

# Apply policy change
docker-compose up -d --no-build

# Perform maintenance shutdown
if ./mariadb_shutdown --container mariadb-container --timeout 180; then
    echo "MariaDB stopped for maintenance"
    
    # Perform maintenance tasks here
    # - Database repairs
    # - Configuration changes
    # - System updates
    
    echo "Maintenance complete"
    
    # Re-enable auto-restart
    ./restart_control enable
    
    # Restart MariaDB
    docker-compose up -d
    echo "MariaDB restarted with auto-restart enabled"
else
    echo "Shutdown failed"
    exit 1
fi
```

### 🚀 **Production Operations**
```bash
# Check status before operations
./restart_control status

# For emergency shutdown (keeps auto-restart disabled)
./restart_control disable
docker-compose up -d --no-build  # Apply policy change
./mariadb_shutdown --container mariadb-container --force

# For planned restart (maintains auto-restart)
docker-compose restart
```

### 📊 **Automated Deployments**
```bash
#!/bin/bash
# deploy.sh - Safe deployment script

# Temporary disable restart for controlled shutdown
./restart_control disable
docker-compose up -d --no-build

# Graceful shutdown for deployment
if ./mariadb_shutdown --container mariadb-container --timeout 300; then
    echo "Database stopped for deployment"
    
    # Deploy new version
    docker-compose build
    
    # Start with auto-restart enabled
    ./restart_control enable
    docker-compose up -d
    
    echo "Deployment complete"
else
    echo "Deployment failed - could not stop database safely"
    ./restart_control enable  # Restore policy
    exit 1
fi
```

## Best Practices

### 🎯 **Production Environment**
- **Keep `restart: unless-stopped`** for high availability
- **Use `docker-compose stop/start`** for planned restarts
- **Monitor restart events** in container logs
- **Test shutdown procedures** in staging first

### 🧪 **Development/Testing**
- **Use `restart: no`** for testing shutdown scripts
- **Switch policies** as needed with restart_control
- **Document restart behavior** in your testing procedures

### 🔄 **CI/CD Pipelines**
```yaml
# Example GitHub Actions workflow
steps:
  - name: Deploy with controlled restart
    run: |
      ./restart_control disable
      docker-compose up -d --no-build
      ./mariadb_shutdown --container mariadb-container --timeout 180
      docker-compose build
      ./restart_control enable
      docker-compose up -d
```

## Troubleshooting

### Container Keeps Restarting
```bash
# Check restart policy
./restart_control status

# Disable if needed
./restart_control disable
docker-compose up -d --no-build

# Check why it's restarting
docker logs mariadb-container
```

### Shutdown Script Not Working
```bash
# Ensure container is not auto-restarting
./restart_control status

# If auto-restart is enabled, use protected shutdown
./restart_control shutdown
```

### Policy Changes Not Applied
```bash
# Recreate container with new policy
docker-compose up -d --no-build

# Or force recreate
docker-compose down
docker-compose up -d
```

## File Locations

- **Restart Control Script**: `./restart_control`
- **Shutdown Script**: `./mariadb_shutdown`  
- **Docker Compose**: `./docker-compose.yml`
- **Backup**: `./docker-compose.yml.bak` (created by restart_control)

This restart control system gives you **precise control** over MariaDB container lifecycle management for both production reliability and development flexibility! 🎯
