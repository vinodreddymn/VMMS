# VMMS Backend - Quick Start Guide

## Prerequisites

- Node.js 18+ and npm
- PostgreSQL 12+
- Redis 6+ (optional, for caching)
- Git

## Step 1: Clone & Install

```bash
# Clone the repository
git clone <your-repo-url> vmms_backend
cd vmms_backend

# Install dependencies
npm install

# Create required directories
mkdir -p uploads exports uploads/documents uploads/biometrics uploads/photos

# Verify installation
npm list
```

## Step 2: Configure Database

### Option A: PostgreSQL on Local Machine

```bash
# Create database
createdb vmms_db

# Create user (optional, if using default postgres user)
createuser vmms_user -P

# Initialize schema (from project root)
psql -U postgres -d vmms_db -f migrations/001_init_schema.sql

# Verify tables created
psql -U postgres -d vmms_db -c "\dt"
```

### Option B: PostgreSQL in Docker

```bash
# Create and run PostgreSQL container
docker run --name vmms-postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=vmms_db \
  -p 5432:5432 \
  -v postgres_data:/var/lib/postgresql/data \
  -d postgres:15

# Wait 10 seconds for initialization
sleep 10

# Initialize schema
docker exec -i vmms-postgres psql -U postgres -d vmms_db < migrations/001_init_schema.sql

# Verify (should show 16 tables)
docker exec vmms-postgres psql -U postgres -d vmms_db -c "\dt"
```

## Step 3: Environment Setup

```bash
# Copy example environment file
cp .env.example .env

# Edit .env with your configuration
nano .env  # or use your preferred editor
```

**Critical Variables to Update:**

```env
# Database
DB_PASSWORD=your_actual_password
DB_USER=postgres  # or your username

# Generate secrets (run in Node REPL or bash)
JWT_SECRET=<run: node -e "console.log(require('crypto').randomBytes(32).toString('hex'))">
ENCRYPTION_KEY=<run: node -e "console.log(require('crypto').randomBytes(32).toString('hex'))">

# SMS (optional)
SMS_PROVIDER=console  # keeps logs, doesn't send SMS
```

**Generate Secrets:**

```bash
# In your terminal (any OS)
node -e "console.log('JWT_SECRET=' + require('crypto').randomBytes(32).toString('hex'))"
node -e "console.log('ENCRYPTION_KEY=' + require('crypto').randomBytes(32).toString('hex'))"
```

## Step 4: Verify Configuration

```bash
# Test database connection
npm run test:db

# Expected output:
# ✓ PostgreSQL connected successfully
# ✓ Tables initialized: users, visitors, labour, gates, etc.
```

## Step 5: Start the Server

### Development Mode (with auto-restart)

```bash
npm run dev

# Expected output:
# 🚀 VMMS Backend Server running on port 5000
# 📊 PostgreSQL connected successfully
# ✅ All systems operational
```

### Production Mode

```bash
npm start

# Use PM2 for production
npm install -g pm2
pm2 start src/server.js --name vmms-backend
pm2 save
pm2 startup
pm2 logs vmms-backend
```

## Step 6: Test the API

### Health Check

```bash
curl -X GET http://localhost:5000/health

# Expected Response:
# { "status": "ok", "timestamp": "2024-01-15T10:30:00Z" }
```

### Admin User Setup (First Time)

```bash
# Create initial SUPER_ADMIN user via direct DB insert (first time only)
psql -U postgres -d vmms_db -c "
INSERT INTO users (
  username, email, password_hash, role_id, created_by, updated_by
) VALUES (
  'admin', 
  'admin@vmms.com',
  '\$2b\$10\$N9qo8uLOickgx2ZMRZoMyeIjZAgcg7b3XeKeUxWdeS86E36P4/DJm', -- password: 'Admin@123'
  1, -- SUPER_ADMIN role_id
  1, 1
);
"
```

### Login Test

```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "Admin@123"
  }'

# Expected Response:
# {
#   "success": true,
#   "user": {
#     "id": 1,
#     "username": "admin",
#     "email": "admin@vmms.com",
#     "role": "SUPER_ADMIN"
#   },
#   "token": "eyJhbGciOiJIUzI1NiIs...",
#   "expiresIn": "8h"
# }
```

### Create Test Project

```bash
curl -X POST http://localhost:5000/api/admin/projects \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "project_name": "Test Construction Site",
    "project_code": "TCS-001",
    "location": "Test Location",
    "city": "Test City",
    "state": "TS"
  }'
```

### Create Test Gate

```bash
curl -X POST http://localhost:5000/api/admin/gates \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "gate_name": "Main Entrance",
    "gate_code": "GATE-001",
    "entrance_id": 1,
    "project_id": 1,
    "ip_address": "192.168.1.100",
    "is_active": true
  }'
```

### Enroll a Test Visitor

```bash
curl -X POST http://localhost:5000/api/visitors \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "first_name": "John",
    "last_name": "Doe",
    "aadhaar": "123456789012",
    "mobile_number": "9876543210",
    "project_id": 1,
    "visitor_type_id": 2,
    "can_carry_smartphone": true,
    "can_carry_laptop": false,
    "can_access_operations_area": true,
    "remarks": "Regular visitor"
  }'

# Expected Response includes: visitor_id, pass_no, encrypted_aadhaar
```

## Step 7: Next Steps

1. **Set up Gate Hardware**: Configure gate devices with IP addresses from admin panel
2. **Test Offline Mode**: Configure offline SQLite buffer on gate mini-PCs
3. **SMS Integration**: Update SMS_PROVIDER in .env to Twilio/AWS SNS
4. **Front-end Setup**: Deploy VMMS Web UI (enrollment, analytics, management)
5. **Monitoring**: Set up PM2+ or other monitoring for production

## Troubleshooting

### Port Already in Use

```bash
# Change port in .env
PORT=5001

# Or kill existing process
lsof -ti:5000 | xargs kill -9  # macOS/Linux
netstat -ano | findstr :5000   # Windows (find PID)
taskkill /PID <PID> /F         # Windows (kill)
```

### Database Connection Failed

```bash
# Check PostgreSQL is running
psql -U postgres -d vmms_db -c "SELECT NOW();"

# If failed, start PostgreSQL:
# macOS: brew services start postgresql@15
# Linux: sudo service postgresql start
# Windows: Services app → PostgreSQL → Start
```

### JWT Token Errors

```
Error: "invalid token" or "jwt malformed"

Solution:
1. Verify JWT_SECRET is set in .env
2. Check token wasn't modified in transit
3. Ensure token wasn't expired (8-hour limit)
4. Re-login to get new token
```

### CORS Issues

```
Error: "Access to XMLHttpRequest blocked by CORS policy"

Solution:
1. Update CORS_ORIGIN in .env to match your frontend URL
2. Restart server: npm run dev
```

### Out of Memory

```bash
# Increase Node memory limit
NODE_OPTIONS=--max-old-space-size=4096 npm start

# Or in .env
# NODE_MAX_MEMORY=4096
```

## Monitoring & Health

```bash
# View logs
npm run logs

# Check gate sync status
curl -X GET http://localhost:5000/api/sync/queue \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"

# View active gates
curl -X GET http://localhost:5000/api/admin/gates \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"

# Check system health
curl -X GET http://localhost:5000/health
```

## Performance Optimization

1. **Enable Redis Caching**: Install Redis and uncomment in config/redis.js
2. **Database Indexes**: Already configured in 001_init_schema.sql
3. **Connection Pooling**: DB_POOL_MIN=2, DB_POOL_MAX=10 in .env
4. **Log Archival**: Old access logs auto-delete (configurable via AUTO_DELETE_LOGS_DAYS)

## Production Deployment

### Using PM2

```bash
npm install -g pm2

# Start
pm2 start src/server.js --name vmms-backend --instances max

# Save for restart on reboot
pm2 save
pm2 startup
pm2 monit
```

### Using Docker

```bash
# Build image
docker build -t vmms-backend:latest .

# Run container
docker run -d \
  --name vmms-backend \
  -p 5000:5000 \
  -e DATABASE_URL=postgres://user:pass@db:5432/vmms_db \
  -e JWT_SECRET=your_secret \
  vmms-backend:latest

# View logs
docker logs -f vmms-backend
```

### Using Nginx (Reverse Proxy)

```nginx
upstream vmms_backend {
    server localhost:5000;
}

server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://vmms_backend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## Support & Documentation

- Full API Documentation: See [API.md](./docs/API.md)
- Database Schema: See [migrations/001_init_schema.sql](./migrations/001_init_schema.sql)
- Deployment Guide: See [DEPLOYMENT.md](./docs/DEPLOYMENT.md)
- Troubleshooting: See [TROUBLESHOOTING.md](./docs/TROUBLESHOOTING.md)

## License

ISC License - See LICENSE file

---

**Happy Deploying! 🚀**

For issues or questions, contact the development team.
