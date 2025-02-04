# Oracle Container Management Guide

## 1. Normal Container Operations

### Stop Container
```powershell
docker stop oracle-free
```

### Start Container
```powershell
docker start oracle-free
```

### Check Container Status
```powershell
docker ps -a  # Shows all containers, including stopped ones
docker logs oracle-free  # View container logs
```

## 2. Common Issues and Solutions

### Issue 1: Container Won't Start
If the container fails to start, try these steps in order:

1. Check container status:
```powershell
docker ps -a
```

2. View logs for errors:
```powershell
docker logs oracle-free
```

3. Remove and recreate container if needed:
```powershell
docker stop oracle-free
docker rm oracle-free
docker run -d --name oracle-free -p 1521:1521 -e ORACLE_PWD=YourStrongPassword123 container-registry.oracle.com/database/free:latest
```

### Issue 2: Database Not Accessible
If you can't connect to the database:

1. Check if container is healthy:
```powershell
docker inspect oracle-free | findstr "Status"
```

2. Check if port is accessible:
```powershell
Test-NetConnection -ComputerName localhost -Port 1521
```

3. Verify database status from inside container:
```powershell
docker exec oracle-free sqlplus / as sysdba <<EOF
SELECT status FROM v$instance;
EXIT;
EOF
```

### Issue 3: Data Persistence
To prevent data loss between container restarts:

1. Create a volume:
```powershell
docker volume create oracle_data
```

2. Run container with volume:
```powershell
docker run -d --name oracle-free `
    -p 1521:1521 `
    -e ORACLE_PWD=YourStrongPassword123 `
    -v oracle_data:/opt/oracle/oradata `
    container-registry.oracle.com/database/free:latest
```

## 3. Backup and Recovery

### Create Backup
```powershell
# Create backup directory
mkdir D:\oracle_backups

# Export database
docker exec oracle-free exp system/YourStrongPassword123@//localhost:1521/FREEPDB1 file=/opt/oracle/backup.dmp

# Copy backup file from container
docker cp oracle-free:/opt/oracle/backup.dmp D:\oracle_backups\
```

### Restore Backup
```powershell
# Copy backup file to container
docker cp D:\oracle_backups\backup.dmp oracle-free:/opt/oracle/

# Import database
docker exec oracle-free imp system/YourStrongPassword123@//localhost:1521/FREEPDB1 file=/opt/oracle/backup.dmp
```

## 4. Performance Tuning

### Check Resource Usage
```powershell
docker stats oracle-free
```

### Adjust Container Resources
```powershell
# Restart with more resources
docker update --memory 4g --memory-swap 8g --cpus 2 oracle-free
```

## 5. Troubleshooting Checklist

1. Container Issues:
   - Check container status
   - View logs
   - Verify resource usage
   - Ensure ports are not conflicting

2. Database Issues:
   - Verify listener status
   - Check database status
   - Review alert logs
   - Test connection parameters

3. Data Issues:
   - Check tablespace usage
   - Verify user permissions
   - Review transaction logs

## 6. Quick Reference Commands

### Container Management
```powershell
# Start container and wait for database
docker start oracle-free
Start-Sleep -Seconds 60  # Wait for database initialization

# Stop container gracefully
docker stop oracle-free

# Remove container (caution: data will be lost without volume)
docker rm oracle-free

# View real-time logs
docker logs -f oracle-free
```

### Database Health Check
```powershell
# Check database status
docker exec oracle-free sqlplus -S / as sysdba <<EOF
SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF;
SELECT status FROM v\$instance;
EXIT;
EOF

# Check tablespace usage
docker exec oracle-free sqlplus -S / as sysdba <<EOF
SET LINESIZE 200;
SELECT tablespace_name, 
       ROUND(used_space * 8192 / 1024 / 1024) "Used (MB)",
       ROUND(tablespace_size * 8192 / 1024 / 1024) "Total (MB)"
FROM dba_tablespace_usage_metrics;
EXIT;
EOF
```
