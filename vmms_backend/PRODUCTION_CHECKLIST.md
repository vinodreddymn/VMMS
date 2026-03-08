# VMMS Backend - Pre-Production Checklist

## Phase 1: Development Validation ✓ COMPLETE

- [x] All code files created and reviewed
- [x] Database schema designed with 16+ tables
- [x] API endpoints defined (40+ endpoints)
- [x] RBAC system implemented with 4 roles
- [x] Encryption and security measures in place
- [x] Error handling and logging configured
- [x] Middleware chain properly organized
- [x] Cron jobs defined for background tasks
- [x] Documentation completed (README, API, Deployment)

---

## Phase 2: Environment Setup (Before Deployment)

### Database Setup
- [ ] PostgreSQL 12+ installed and running
- [ ] Create database: `vmms_db`
- [ ] Create user: `vmms_user` with password
- [ ] Verify connection:
  ```bash
  psql -U vmms_user -d vmms_db -h localhost -c "SELECT NOW();"
  ```
- [ ] Run migration:
  ```bash
  psql -U vmms_user -d vmms_db -f migrations/001_init_schema.sql
  ```
- [ ] Verify all 16 tables created:
  ```bash
  psql -U vmms_user -d vmms_db -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='public';"
  ```
- [ ] Test with data seed queries

### Node.js Setup
- [ ] Node.js 18+ installed
- [ ] npm version updated: `npm install -g npm@latest`
- [ ] Install project dependencies:
  ```bash
  npm install --production
  ```
- [ ] Verify installation:
  ```bash
  npm list | grep -E "express|pg|pdfkit|exceljs"
  ```

### Environment Configuration
- [ ] Copy `.env.example` to `.env`
- [ ] Generate JWT_SECRET:
  ```bash
  node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
  ```
- [ ] Generate ENCRYPTION_KEY (32-byte hex):
  ```bash
  node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
  ```
- [ ] Set database credentials
- [ ] Set SMS_PROVIDER (console for testing, twilio/aws for production)
- [ ] Set CORS_ORIGIN to match frontend domain
- [ ] Verify all required variables are filled

### Directory Setup
- [ ] Create upload directories:
  ```bash
  mkdir -p uploads/documents uploads/biometrics uploads/photos
  mkdir -p exports logs
  chmod 755 uploads exports logs
  ```
- [ ] Verify write permissions

---

## Phase 3: Pre-Launch Testing

### API Connectivity Tests
- [ ] Server starts without errors:
  ```bash
  npm start
  ```
- [ ] Health endpoint responds:
  ```bash
  curl http://localhost:5000/health
  ```
- [ ] Server logs show "PostgreSQL connected successfully"

### Database Tests
- [ ] Connect via psql and verify tables
- [ ] Run sample data queries:
  ```sql
  SELECT COUNT(*) FROM users;
  SELECT COUNT(*) FROM roles;
  SELECT COUNT(*) FROM projects;
  ```

### Authentication Tests
- [ ] Create admin user (via direct DB insert)
- [ ] Test login endpoint:
  ```bash
  curl -X POST http://localhost:5000/api/auth/login \
    -H "Content-Type: application/json" \
    -d '{"username":"admin","password":"Admin@123"}'
  ```
- [ ] Verify JWT token is returned
- [ ] Test protected endpoint with token:
  ```bash
  curl -X GET http://localhost:5000/api/visitors \
    -H "Authorization: Bearer <TOKEN>"
  ```

### Business Logic Tests
- [ ] Create test visitor (check blacklist integration)
- [ ] Create test project and gate
- [ ] Test gate authentication (RFID simulation):
  ```bash
  curl -X POST http://localhost:5000/api/gate/authenticate \
    -H "Content-Type: application/json" \
    -d '{"card_uid":"test-uid","gate_id":1}'
  ```
- [ ] Test material transaction
- [ ] Test blacklist checking
- [ ] Generate test report

### Migration Tests
- [ ] Verify all seed data exists:
  ```sql
  SELECT * FROM roles;
  SELECT * FROM visitor_types;
  SELECT * FROM entrances;
  ```

### Error Handling Tests
- [ ] Test with invalid JWT token (should get 401)
- [ ] Test with insufficient permissions (should get 403)
- [ ] Test with missing required fields (should get 400)
- [ ] Test with non-existent resource (should get 404)

---

## Phase 4: Security Validation

### Encryption Verification
- [ ] Verify Aadhaar is encrypted:
  ```sql
  SELECT aadhaar_encrypted, aadhaar_last4 FROM visitors LIMIT 1;
  ```
- [ ] Verify biometric hashes are stored (not raw data):
  ```sql
  SELECT biometric_hash FROM biometric_data LIMIT 1;
  ```
- [ ] Attempt to decrypt Aadhaar with code (should work)

### Authentication & Authorization
- [ ] JWT tokens contain role and user_id
- [ ] Non-admin cannot view sensitive endpoints
- [ ] SECURITY_HEAD cannot export Excel
- [ ] ENROLLMENT_STAFF cannot manage users
- [ ] RBAC middleware blocks unauthorized access

### Password Security
- [ ] Admin password is bcrypt hashed
- [ ] Test wrong password rejected:
  ```bash
  curl -X POST http://localhost:5000/api/auth/login \
    -H "Content-Type: application/json" \
    -d '{"username":"admin","password":"WrongPassword"}'
  ```
  Should return 401 or 403

### CORS Security
- [ ] CORS_ORIGIN correctly set in .env
- [ ] Cross-origin requests blocked if not in whitelist
- [ ] Preflight requests handled correctly

### Input Validation
- [ ] SQL injection attempts blocked (use Joi validation)
- [ ] XSS attempts in text fields escaped
- [ ] File uploads validated for type and size
- [ ] Date inputs validated (ISO format)

---

## Phase 5: Performance & Load Testing

### Response Time Tests
- [ ] Simple queries respond in <500ms
- [ ] Complex reports respond in <10 seconds
- [ ] File uploads complete within reasonable time

### Database Performance
- [ ] Connection pool properly sized
- [ ] Queries use indexes (check EXPLAIN ANALYZE)
- [ ] No N+1 query issues
- [ ] Access logs partitioned correctly:
  ```bash
  psql -U vmms_user -d vmms_db -c "SELECT schemaname, tablename FROM pg_tables WHERE tablename LIKE '%access_logs%';"
  ```

### Load Simulation
- [ ] 10 concurrent login attempts succeed
- [ ] 50 simultaneous gate authentications process
- [ ] Large visitor list pagination works correctly
- [ ] Report generation doesn't timeout with 10K+ records

---

## Phase 6: Integration Testing

### Visitor Enrollment Flow
- [ ] Create visitor → Check blacklist pre-check
- [ ] Upload documents → Files stored in uploads/documents
- [ ] Enroll biometric → Hash stored, no raw data
- [ ] Issue RFID card → QR code generated, whitelist updated
- [ ] Verify master whitelist contains new entry

### Gate Authentication Flow
- [ ] Submit RFID tap (no auth required)
- [ ] Direction toggles correctly (IN if last was OUT)
- [ ] Blacklist check triggers alerts
- [ ] Live photo captured and stored
- [ ] Access log created with correct metadata

### Labour Management Flow
- [ ] Register labour under supervisor
- [ ] Create manifest with multiple labours
- [ ] Generate PDF with supervisor photo
- [ ] Sign manifest and store PDF
- [ ] No-show detection runs every 10 minutes
- [ ] SMS sent for no-shows (console log if SMS_PROVIDER=console)

### Material Management Flow
- [ ] Create material master data
- [ ] Record OUT transaction
- [ ] Balance calculated correctly
- [ ] Alert sent when exiting with pending returns
- [ ] Return transaction updates balance

### Reporting Flow
- [ ] Live muster shows correct count
- [ ] Daily stats calculated correctly
- [ ] Gate load breakdown accurate
- [ ] Advanced search filters work
- [ ] PDF export generates without error
- [ ] Excel export (SUPER_ADMIN only) creates workbook

### Offline Sync Flow
- [ ] Gate requests whitelist (returns 250+ entries)
- [ ] Gate submits offline queue
- [ ] Server de-duplicates entries
- [ ] Access logs correctly recorded
- [ ] Whitelist broadcasts to all gates

---

## Phase 7: Deployment Preparation

### Code Quality
- [ ] No console.log statements in production code (use logger)
- [ ] No hardcoded credentials in code
- [ ] Error messages don't expose sensitive info
- [ ] HTTP status codes are appropriate

### Documentation Review
- [ ] README.md is complete and accurate
- [ ] API.md documents all 40+ endpoints
- [ ] DEPLOYMENT.md covers all methods
- [ ] QUICKSTART.md has working instructions
- [ ] Comments explain complex logic

### Deployment Files
- [ ] Dockerfile created (if using Docker)
- [ ] docker-compose.yml configured
- [ ] .env.example has all required variables
- [ ] package.json has correct versions locked
- [ ] .gitignore includes .env, node_modules, uploads, logs

### Monitoring Setup
- [ ] Winston logging configured
- [ ] Health check endpoint available
- [ ] Cron jobs tested and working
- [ ] Error alerts configured (if available)
- [ ] Log rotation configured

### Backup & Recovery
- [ ] Database backup script created
- [ ] Backup tested and verified:
  ```bash
  pg_dump -U vmms_user -d vmms_db > backup_test.sql
  # Verify file size is reasonable
  ```
- [ ] Restore procedure tested
- [ ] Backup schedule set (daily at 2 AM)

---

## Phase 8: Production Deployment

### Pre-Deployment
- [ ] Database backup taken
- [ ] Notification sent to stakeholders
- [ ] Deployment window scheduled (off-hours if possible)
- [ ] Rollback plan documented

### Deployment Steps (Choose Method)

#### Option A: PM2 Deployment
```bash
# [ ] Verify PM2 installed globally
# [ ] Navigate to project directory
# [ ] PM2 start application
# [ ] Set auto-start on reboot
# [ ] Verify running: pm2 list
# [ ] Check logs: pm2 logs vmms-backend
```

#### Option B: Docker Deployment
```bash
# [ ] Build image
# [ ] Push to registry
# [ ] Pull on production server
# [ ] Run docker-compose up
# [ ] Verify all services healthy
# [ ] Check logs: docker-compose logs -f
```

#### Option C: Traditional Setup
```bash
# [ ] Create system user
# [ ] Set directory ownership
# [ ] Install Node.js globally
# [ ] Install dependencies
# [ ] Configure systemd service
# [ ] Start service
# [ ] Verify status
```

### Post-Deployment
- [ ] Health endpoint returns success
- [ ] Database connectivity verified
- [ ] Logs show no errors
- [ ] Test login endpoint
- [ ] Test core functionality (create visitor, gate auth)
- [ ] Monitor error logs for 1 hour
- [ ] Notify stakeholders of successful deployment

---

## Phase 9: Go-Live Support

### Day 1 - Launch Day
- [ ] DevOps team available for issues
- [ ] Database backups happening automatically
- [ ] Monitor error logs every 15 minutes
- [ ] Check application performance metrics
- [ ] Verify PDF/Excel exports work
- [ ] Test SMS alerts (if configured)
- [ ] Monitor database size and growth

### First Week
- [ ] Review error logs daily
- [ ] Check cron job execution (no-show, material alerts)
- [ ] Verify offline sync working from gate devices
- [ ] Test visitor enrollment with real data
- [ ] Test gate authentication with real RFID device
- [ ] Monitor database performance
- [ ] Collect user feedback

### First Month
- [ ] Analyze performance metrics and optimize if needed
- [ ] Review and adjust SMS alert timing
- [ ] Verify backup/restore procedures
- [ ] Train additional operators on system
- [ ] Document any issues and resolutions
- [ ] Plan for enhancements/expansions

---

## Phase 10: Ongoing Maintenance

### Weekly Tasks
- [ ] Review error logs
- [ ] Check disk space on server
- [ ] Monitor database size
- [ ] Verify backups completed successfully

### Monthly Tasks
- [ ] Database maintenance (VACUUM, ANALYZE)
- [ ] Review performance metrics
- [ ] Update security patches
- [ ] Test disaster recovery procedure
- [ ] Archive old access logs (if policy defined)

### Quarterly Tasks
- [ ] Full security audit
- [ ] Review and update RBAC permissions
- [ ] Capacity planning (disk, CPU, memory)
- [ ] Major version updates testing

### Annually Tasks
- [ ] Complete system audit
- [ ] Disaster recovery test
- [ ] Security penetration testing
- [ ] Performance optimization review

---

## Critical Contacts

**System Admin**
- Name: _________________
- Phone: _________________
- Email: _________________

**Database Admin**
- Name: _________________
- Phone: _________________
- Email: _________________

**Development Lead**
- Name: _________________
- Phone: _________________
- Email: _________________

**Project Manager**
- Name: _________________
- Phone: _________________
- Email: _________________

---

## Rollback Procedure (If Needed)

1. **Immediate**: Stop the application
   ```bash
   pm2 stop vmms-backend
   # OR
   docker-compose down
   ```

2. **Restore Database** (if schema changed)
   ```bash
   psql -U vmms_user -d vmms_db < /backups/vmms_db/vmms_db_YYYYMMDD.sql
   ```

3. **Rollback Code** (if bug introduced)
   ```bash
   git revert <commit-hash>
   npm install
   pm2 restart vmms-backend
   ```

4. **Verify**: Test critical functionality
   - Login
   - Visitor creation
   - Gate authentication
   - Report generation

5. **Notify**: Alert stakeholders of rollback

---

## Sign-Off

**Prepared By**: _____________________ Date: _________

**Reviewed By**: _____________________ Date: _________

**Approved By**: _____________________ Date: _________

**Deployed By**: _____________________ Date: _________ Time: _________

**Verified By**: _____________________ Date: _________ Time: _________

---

**Notes/Comments**:
```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

---

**VMMS Backend is ready for production deployment!**

All documentation, code, and infrastructure are in place.
Follow this checklist step-by-step for a smooth launch.

Last Updated: January 2024
