# VMMS Backend - Deployment Guide

## Table of Contents
1. [Pre-Deployment Checklist](#pre-deployment-checklist)
2. [Production Environment Setup](#production-environment-setup)
3. [Database Setup](#database-setup)
4. [Deployment Methods](#deployment-methods)
5. [Monitoring & Maintenance](#monitoring--maintenance)
6. [Troubleshooting](#troubleshooting)
7. [Rollback Procedures](#rollback-procedures)

---

## Pre-Deployment Checklist

- [ ] All environment variables configured in `.env`
- [ ] Database migrated successfully
- [ ] npm dependencies installed
- [ ] TLS certificate obtained (for HTTPS)
- [ ] Firewall rules configured for port 5000
- [ ] Database backup strategy in place
- [ ] Uptime monitoring configured
- [ ] Log aggregation setup complete
- [ ] SMS provider credentials configured
- [ ] File upload paths have adequate disk space

---

## Production Environment Setup

### System Requirements

**Minimum:**
- CPU: 2+ cores
- RAM: 4 GB
- Storage: 50 GB SSD (depends on access log volume)
- OS: Ubuntu 20.04+ / CentOS 8+ / Windows Server 2019+

**Recommended:**
- CPU: 4+ cores
- RAM: 8+ GB
- Storage: 200 GB SSD
- Load Balancer: NGINX/HAProxy

### OS-Specific Setup

#### Ubuntu/Debian

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Node.js 18+
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Install PostgreSQL
sudo apt install -y postgresql postgresql-contrib

# Install Redis (optional)
sudo apt install -y redis-server

# Install PM2 globally
sudo npm install -g pm2

# Create application user
sudo useradd -m -s /bin/bash vmms_app

# Create application directory
sudo mkdir -p /opt/vmms_backend
sudo chown vmms_app:vmms_app /opt/vmms_backend
```

#### Windows Server

```powershell
# Using Chocolatey (install from https://chocolatey.org/install)
choco install nodejs postgresql redis -y

# Create application directory
New-Item -ItemType Directory -Path "C:\vmms_backend"

# Install Windows Service for Node
npm install -g nssm
```

#### CentOS/RHEL

```bash
# Update system
sudo yum update -y

# Install Node.js 18+
curl -sL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs

# Install PostgreSQL
sudo yum install -y postgresql-server postgresql-contrib

# Initialize database
sudo postgresql-setup initdb
sudo systemctl start postgresql
```

---

## Database Setup

### PostgreSQL Configuration

```bash
# Connect to PostgreSQL
sudo -u postgres psql

# Create database and user
CREATE DATABASE vmms_db;
CREATE USER vmms_user WITH ENCRYPTED PASSWORD 'strong_password_here';
GRANT ALL PRIVILEGES ON DATABASE vmms_db TO vmms_user;
GRANT CONNECT ON DATABASE vmms_db TO vmms_user;

# Alter default schema access
ALTER ROLE vmms_user SET search_path TO public;

# Exit psql
\q

# Test connection
psql -U vmms_user -d vmms_db -h localhost
```

### Apply Schema Migration

```bash
# From project root
psql -U vmms_user -d vmms_db -h localhost -f migrations/001_init_schema.sql

# Verify tables created
psql -U vmms_user -d vmms_db -c "
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' ORDER BY table_name;
"

# Should return 16 tables
```

### PostgreSQL Tuning for Production

Edit `/etc/postgresql/*/main/postgresql.conf`:

```ini
# Maximum connections
max_connections = 100

# Shared buffers (25% of RAM, up to 40GB)
shared_buffers = 2GB

# Effective cache size (50-75% of RAM)
effective_cache_size = 4GB

# Work memory
work_mem = 20MB

# Maintenance work memory
maintenance_work_mem = 256MB

# WAL level for replication
wal_level = replica

# Checkpoint settings
checkpoint_timeout = 15min
checkpoint_completion_target = 0.9

# Logging
logging_collector = on
log_directory = 'log'
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
log_statement = 'all'
```

Restart PostgreSQL:
```bash
sudo systemctl restart postgresql
```

### Database Backup Strategy

```bash
# Create backup directory
sudo mkdir -p /backups/vmms_db
sudo chown vmms_app:vmms_app /backups/vmms_db

# Create backup script
sudo tee /usr/local/bin/backup_vmms_db.sh > /dev/null <<EOF
#!/bin/bash
BACKUP_DIR="/backups/vmms_db"
TIMESTAMP=\$(date +%Y%m%d_%H%M%S)
pg_dump -U vmms_user -d vmms_db -h localhost > \$BACKUP_DIR/vmms_db_\$TIMESTAMP.sql
gzip \$BACKUP_DIR/vmms_db_\$TIMESTAMP.sql

# Keep only last 30 days of backups
find \$BACKUP_DIR -mtime +30 -delete
EOF

sudo chmod +x /usr/local/bin/backup_vmms_db.sh

# Schedule daily backup via crontab
sudo crontab -e

# Add line:
# 0 2 * * * /usr/local/bin/backup_vmms_db.sh
```

---

## Deployment Methods

### Method 1: PM2 (Recommended for Single Server)

```bash
# Clone and setup
cd /opt/vmms_backend
git clone <repo-url> .
npm install --production

# Copy environment file
cp .env.example .env
nano .env  # Edit with production values

# Start with PM2
pm2 start src/server.js --name vmms-backend --instances max --max-memory-restart 500M

# Configure auto-start on reboot
pm2 startup systemd -u vmms_app --hp /home/vmms_app
pm2 save

# Monitor
pm2 monit
pm2 logs vmms-backend

# Update deployment
pm2 delete vmms-backend
git pull origin main
npm install --production
pm2 start src/server.js --name vmms-backend
```

### Method 2: Docker (Recommended for Microservices)

#### Create Dockerfile

```dockerfile
FROM node:18-alpine

WORKDIR /app

# Install build dependencies
RUN apk add --no-cache python3 make g++

# Copy package files
COPY package*.json ./

# Install production dependencies
RUN npm ci --only=production

# Copy application code
COPY . .

# Create required directories
RUN mkdir -p uploads/documents uploads/biometrics uploads/photos exports

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:5000/health', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})"

# Expose port
EXPOSE 5000

# Start application
CMD ["node", "src/server.js"]
```

#### Create docker-compose.yml

```yaml
version: '3.8'

services:
  vmms-backend:
    build: .
    container_name: vmms-backend
    restart: unless-stopped
    ports:
      - "5000:5000"
    environment:
      - NODE_ENV=production
      - DB_HOST=postgres
      - DB_USER=vmms_user
      - DB_PASSWORD=${DB_PASSWORD}
      - DB_NAME=vmms_db
      - REDIS_HOST=redis
      - JWT_SECRET=${JWT_SECRET}
      - ENCRYPTION_KEY=${ENCRYPTION_KEY}
      - SMS_PROVIDER=${SMS_PROVIDER}
    volumes:
      - ./uploads:/app/uploads
      - ./exports:/app/exports
      - ./logs:/app/logs
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    networks:
      - vmms-network

  postgres:
    image: postgres:15-alpine
    container_name: vmms-postgres
    restart: unless-stopped
    environment:
      - POSTGRES_USER=vmms_user
      - POSTGRES_PASSWORD=${DB_PASSWORD}
      - POSTGRES_DB=vmms_db
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./migrations:/docker-entrypoint-initdb.d
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U vmms_user -d vmms_db"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - vmms-network

  redis:
    image: redis:7-alpine
    container_name: vmms-redis
    restart: unless-stopped
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - vmms-network

volumes:
  postgres_data:
  redis_data:

networks:
  vmms-network:
    driver: bridge
```

#### Deploy with Docker Compose

```bash
# Create .env file
cp .env.example .env
nano .env

# Deploy
docker-compose up -d

# Monitor
docker-compose logs -f vmms-backend

# Update
docker-compose down
git pull origin main
docker-compose build --no-cache
docker-compose up -d

# Backup database
docker-compose exec postgres pg_dump -U vmms_user vmms_db | gzip > backup_$(date +%Y%m%d).sql.gz
```

### Method 3: Kubernetes (For Enterprise Scale)

Create `k8s-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vmms-backend
  labels:
    app: vmms-backend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: vmms-backend
  template:
    metadata:
      labels:
        app: vmms-backend
    spec:
      containers:
      - name: vmms-backend
        image: vmms/backend:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 5000
        env:
        - name: NODE_ENV
          value: "production"
        - name: DB_HOST
          value: "postgres-service"
        - name: DB_USER
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: username
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: password
        - name: JWT_SECRET
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: jwt_secret
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 5000
          initialDelaySeconds: 10
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 5000
          initialDelaySeconds: 5
          periodSeconds: 5

---
apiVersion: v1
kind: Service
metadata:
  name: vmms-backend-service
spec:
  selector:
    app: vmms-backend
  ports:
  - port: 80
    targetPort: 5000
  type: LoadBalancer
```

Deploy:
```bash
kubectl apply -f k8s-deployment.yaml
kubectl get pods
kubectl logs deployment/vmms-backend
```

---

## Monitoring & Maintenance

### Application Monitoring with PM2+

```bash
# Install PM2+ account
pm2 install pm2-auto-pull

# Connect to PM2+
pm2 web  # access at localhost:9615

# Monitor with external service
pm2 connect
```

### Log Aggregation with Winston

Logs are stored in structured format. Integrate with ELK Stack:

```javascript
// Already configured in logger.util.js
// Logs include: timestamp, level, service, message, metadata
```

### Database Monitoring

```bash
# Check database size
sudo -u postgres psql -d vmms_db -c "
SELECT 
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables
WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
"

# Check slow queries
# Enable in postgresql.conf:
# log_min_duration_statement = 1000  # log queries taking > 1s

# Monitor active connections
psql -U vmms_user -d vmms_db -c "
SELECT datname, usename, count(*) 
FROM pg_stat_activity 
GROUP BY datname, usename;
"
```

### Uptime Monitoring

Using Uptime Kuma (self-hosted):

```bash
# Create docker-compose entry for Uptime Kuma
docker run -d \
  --name uptime-kuma \
  -p 3001:3001 \
  -v uptime_kuma_data:/app/data \
  louislam/uptime-kuma:latest

# Access at http://localhost:3001
# Add monitoring target: http://localhost:5000/health
```

### Performance Metrics Dashboards

Using Prometheus + Grafana:

```bash
# Already logging metrics via Winston
# Can export to Prometheus endpoint
# Setup Grafana with Prometheus data source
# Create dashboard showing:
# - Response times
# - Error rates
# - Database connection pool usage
# - Memory and CPU usage
```

---

## Troubleshooting

### High Memory Usage

```bash
# Identify process
ps aux | grep node

# Monitor memory growth
top -p <PID>

# If leak suspected:
# 1. Enable heap snapshots
# 2. Compare snapshots between requests
# 3. Look for unreleased references

# Restart with memory limit
pm2 start src/server.js --max-memory-restart 512M
```

### Database Connection Issues

```bash
# Test connection
psql -U vmms_user -h localhost -d vmms_db -c "SELECT NOW();"

# Check connection pool
psql -U vmms_user -d vmms_db -c "
SELECT application_name, count(*) 
FROM pg_stat_activity 
GROUP BY application_name;
"

# Increase pool size if needed
# DB_POOL_MAX=20 in .env
```

### Slow Queries

```bash
# Enable query logging
ALTER SYSTEM SET log_statement = 'all';
ALTER SYSTEM SET log_min_duration_statement = 500;  -- log queries > 500ms
SELECT pg_reload_conf();

# View slow queries
sudo tail -f /var/log/postgresql/postgresql.log | grep duration
```

### Certificate Issues (HTTPS)

```bash
# Using Let's Encrypt
sudo apt install -y certbot

# Obtain certificate
sudo certbot certonly --standalone -d yourdomain.com

# Update .env
SSL_CERT_PATH=/etc/letsencrypt/live/yourdomain.com/fullchain.pem
SSL_KEY_PATH=/etc/letsencrypt/live/yourdomain.com/privkey.pem

# Create renewal cron job
echo "0 0 1 * * certbot renew --quiet" | sudo crontab -
```

### Gate Disconnections

```bash
# Check gate health status
curl -X GET http://localhost:5000/api/admin/gates \
  -H "Authorization: Bearer YOUR_TOKEN" | jq '.data[] | select(.status=="OFFLINE")'

# Check logs for last heartbeat
psql -U vmms_user -d vmms_db -c "
SELECT gate_id, status, last_heartbeat 
FROM gate_health 
WHERE status = 'OFFLINE' 
ORDER BY last_heartbeat DESC LIMIT 5;
"

# Notify gate admin to reconnect/restart gate device
```

---

## Rollback Procedures

### Rollback to Previous Version

```bash
# Using Git
git log --oneline | head -10
git revert <commit-hash>
npm install
pm2 restart vmms-backend

# Or full rollback
git checkout <previous-tag>
npm install --production
pm2 delete vmms-backend
pm2 start src/server.js --name vmms-backend
```

### Rollback Database Schema

```bash
# Keep backward-compatible migrations
# Don't drop columns, mark as unused instead

# Manual rollback example:
psql -U vmms_user -d vmms_db

-- Remove problematic tables/columns
ALTER TABLE visitors DROP COLUMN IF EXISTS new_field;

-- Verify consistency
SELECT COUNT(*) FROM visitors;
```

### Disaster Recovery

```bash
# If database corrupted:

# 1. Restore from backup
psql -U vmms_user -d vmms_db_new < /backups/vmms_db/vmms_db_20240115.sql

# 2. Point application to new database
# Update DB_NAME=vmms_db_new in .env
# Restart application

# 3. When confident, rename databases
psql -U postgres

DROP DATABASE vmms_db_backup;
ALTER DATABASE vmms_db RENAME TO vmms_db_backup;
ALTER DATABASE vmms_db_new RENAME TO vmms_db;
```

---

## Performance Optimization Tips

1. **Database Indexing**: Already configured in migrations
2. **Connection Pooling**: Adjust DB_POOL_MIN/MAX in .env
3. **Caching**: Enable Redis via REDIS_HOST in .env
4. **Query Optimization**: Use EXPLAIN ANALYZE for slow queries
5. **Compression**: Enable GZIP in server.js
6. **CDN**: Serve static files via CDN if possible
7. **Load Balancing**: Use NGINX/HAProxy for multiple instances

---

## Security Hardening

```bash
# 1. Enable HTTPS
# Configure SSL_CERT_PATH, SSL_KEY_PATH in .env

# 2. Enable CORS restrictions
CORS_ORIGIN=https://yourdomain.com

# 3. Enable security headers
# Already implemented via Helmet middleware

# 4. Rate limiting
RATE_LIMIT_MAX_REQUESTS=100
RATE_LIMIT_WINDOW=15

# 5. Database user permissions (least privilege)
# Create read-only user for analytics
CREATE USER vmms_readonly WITH PASSWORD 'read_only_pass';
GRANT SELECT ON ALL TABLES IN SCHEMA public TO vmms_readonly;

# 6. Firewall rules (restrict to known IPs)
sudo ufw allow from 203.0.113.0/24 to any port 5000
```

---

## Maintenance Schedule

| Task | Frequency | Duration |
|------|-----------|----------|
| Database backup | Daily | 5-10 min |
| Log rotation | Weekly | 1-2 min |
| Certificate renewal | Every 60 days | <1 min |
| Security updates | As needed | 15-30 min |
| Performance audit | Monthly | 30-60 min |
| Disaster recovery test | Quarterly | 1-2 hours |

---

## Support & Escalation

1. **Dev Team**: Development issues, code bugs
2. **DevOps Team**: Deployment, infrastructure, monitoring
3. **Database Admin**: Schema changes, backup/restore
4. **Security Team**: Vulnerability reports, access control

---

**Last Updated**: January 2024
**Version**: 1.0
