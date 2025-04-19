# 🛠️ Database Troubleshooting Guide (Scenario-Based)

This guide provides CLI and SQL-based troubleshooting examples for **PostgreSQL**, **MySQL**, and **general database issues** in DevOps and production environments.

---

## 📋 Table of Contents

- [🔥 Scenario 1: Database Connection Timeout](#-scenario-1-database-connection-timeout)
- [🐢 Scenario 2: Slow Query Performance](#-scenario-2-slow-query-performance)
- [🔄 Scenario 3: High Replication Lag (PostgreSQL)](#-scenario-3-high-replication-lag-postgresql)
- [📦 Scenario 4: Disk Space Issues on Database Server](#-scenario-4-disk-space-issues-on-database-server)
- [🔐 Scenario 5: User Authentication Failures](#-scenario-5-user-authentication-failures)
- [🧹 Scenario 6: Bloated Tables or Indexes (PostgreSQL)](#-scenario-6-bloated-tables-or-indexes-postgresql)
- [📎 Useful SQL and CLI Commands](#-useful-sql-and-cli-commands)

---

## 🔥 Scenario 1: Database Connection Timeout

**Symptoms:**
- Application can't connect to DB
- `timeout` or `could not connect` error

**Checklist & Fix:**
```bash
# Check port is open
nc -zv db-host 5432   # PostgreSQL
nc -zv db-host 3306   # MySQL

# Verify DB is listening
netstat -tuln | grep 5432

# Check firewall/security groups (cloud)
iptables -L
ufw status
```

---

## 🐢 Scenario 2: Slow Query Performance

**Symptoms:**
- Queries taking too long
- App latency increased

**Checklist & Fix:**
```sql
-- PostgreSQL
EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'example@test.com';

-- MySQL
EXPLAIN SELECT * FROM users WHERE email = 'example@test.com';

-- Check active queries
SELECT pid, now() - query_start AS duration, query FROM pg_stat_activity WHERE state='active';

-- Longest running queries
SELECT * FROM pg_stat_activity ORDER BY query_start LIMIT 5;
```

---

## 🔄 Scenario 3: High Replication Lag (PostgreSQL)

**Symptoms:**
- Replica lags behind master
- Data not syncing timely

**Checklist & Fix:**
```sql
-- On replica
SELECT now() - pg_last_xact_replay_timestamp() AS replication_lag;

-- Check replication slots
SELECT * FROM pg_replication_slots;

-- Disk I/O or network issues might cause lag
iotop -ao
ping master-db-host
```

---

## 📦 Scenario 4: Disk Space Issues on Database Server

**Symptoms:**
- Inserts fail
- Disk 100% usage

**Checklist & Fix:**
```bash
df -h
du -sh /var/lib/postgresql
journalctl --disk-usage

# Vacuum & clean up space
psql -c 'VACUUM FULL;'
```

---

## 🔐 Scenario 5: User Authentication Failures

**Symptoms:**
- App errors like "access denied", "authentication failed"

**Checklist & Fix:**
```sql
-- PostgreSQL
\du                  -- List users
SELECT * FROM pg_hba_file_rules;

-- MySQL
SELECT user, host FROM mysql.user;

-- Check if password expired or host mismatch
```

---

## 🧹 Scenario 6: Bloated Tables or Indexes (PostgreSQL)

**Symptoms:**
- Large tables, slow writes
- High disk usage

**Checklist & Fix:**
```sql
-- Check table bloat
SELECT * FROM pgstattuple('your_table');

-- Rebuild index
REINDEX TABLE your_table;

-- Vacuum tables
VACUUM FULL your_table;
```

---

## 📎 Useful SQL and CLI Commands

### PostgreSQL

```sql
-- Show running queries
SELECT * FROM pg_stat_activity;

-- Show locks
SELECT * FROM pg_locks;

-- Show connections
SELECT count(*) FROM pg_stat_activity;

-- Force kill a connection
SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE state = 'idle';
```

### MySQL

```sql
-- Show running processes
SHOW FULL PROCESSLIST;

-- Show current connections
SHOW STATUS LIKE 'Threads_connected';

-- Kill slow query
KILL <process_id>;
```

---

📌 **Pro Tip**: Always test recovery operations in a staging environment and backup your data before running `VACUUM FULL`, `REINDEX`, or `DROP`.

---

⭐ Found this useful? Star this repo and share with your data engineering or DevOps team!