# Database Troubleshooting Guide

This guide provides comprehensive commands, techniques, and solutions for troubleshooting common database issues across various database systems including MySQL, PostgreSQL, MongoDB, and Redis.

## Table of Contents

- [MySQL Troubleshooting](#mysql-troubleshooting)
- [PostgreSQL Troubleshooting](#postgresql-troubleshooting)
- [MongoDB Troubleshooting](#mongodb-troubleshooting)
- [Redis Troubleshooting](#redis-troubleshooting)
- [General Database Performance](#general-database-performance)
- [Connection Issues](#connection-issues)
- [Backup and Recovery](#backup-and-recovery)
- [Common Scenarios](#common-scenarios)

## MySQL Troubleshooting

### Server Status and Information

```bash
# Check if MySQL is running
sudo systemctl status mysql

# Get MySQL server version
mysql -V

# Connect to MySQL server
mysql -u username -p -h hostname

# Show MySQL server status
mysqladmin -u username -p status

# Get detailed server status
mysqladmin -u username -p extended-status

# Check MySQL process list
mysql -u username -p -e "SHOW PROCESSLIST"

# Check MySQL server variables
mysql -u username -p -e "SHOW VARIABLES"
```

### Performance and Slow Queries

```bash
# Enable slow query log (add to my.cnf)
slow_query_log = 1
slow_query_log_file = /var/log/mysql/mysql-slow.log
long_query_time = 2

# Check if slow query log is enabled
mysql -u username -p -e "SHOW VARIABLES LIKE 'slow_query%'"

# Analyze slow query log
mysqldumpslow /var/log/mysql/mysql-slow.log

# Use the MySQL performance schema
mysql -u username -p -e "SELECT * FROM performance_schema.events_statements_summary_by_digest ORDER BY sum_timer_wait DESC LIMIT 10"

# Check table statistics
mysql -u username -p -e "SHOW TABLE STATUS FROM database_name"

# Show InnoDB status
mysql -u username -p -e "SHOW ENGINE INNODB STATUS\G"
```

### Resource Utilization

```bash
# Check max connections and current connections
mysql -u username -p -e "SHOW VARIABLES LIKE 'max_connections'"
mysql -u username -p -e "SHOW STATUS LIKE 'Max_used_connections'"

# Check buffer and cache sizes
mysql -u username -p -e "SHOW VARIABLES LIKE '%buffer%'"
mysql -u username -p -e "SHOW VARIABLES LIKE '%cache%'"

# Check memory usage
mysql -u username -p -e "SELECT * FROM performance_schema.memory_summary_global_by_event_name ORDER BY current_alloc DESC LIMIT 10"
```

### Database and Table Maintenance

```bash
# Check and repair tables
mysqlcheck -u username -p --check database_name
mysqlcheck -u username -p --repair database_name

# Optimize tables
mysqlcheck -u username -p --optimize database_name

# Analyze tables
mysqlcheck -u username -p --analyze database_name

# Show table index statistics
mysql -u username -p -e "SHOW INDEX FROM database_name.table_name"

# Check for fragmented tables
mysql -u username -p -e "SELECT table_name, data_free, engine FROM information_schema.tables WHERE table_schema='database_name' AND data_free > 0"
```

## PostgreSQL Troubleshooting

### Server Status and Information

```bash
# Check if PostgreSQL is running
sudo systemctl status postgresql

# Get PostgreSQL version
psql --version

# Connect to PostgreSQL server
psql -U username -h hostname -d database_name

# Show PostgreSQL server status
pg_ctl status -D /path/to/data/directory

# Check PostgreSQL configuration
sudo cat /etc/postgresql/version/main/postgresql.conf

# List PostgreSQL databases
psql -U username -c "\l"

# List PostgreSQL users
psql -U username -c "\du"
```

### Performance and Slow Queries

```bash
# Enable query logging (add to postgresql.conf)
log_min_duration_statement = 200  # ms

# Check currently running queries
psql -U username -c "SELECT pid, age(clock_timestamp(), query_start), usename, query FROM pg_stat_activity WHERE query != '<IDLE>' AND query NOT ILIKE '%pg_stat_activity%' ORDER BY query_start desc;"

# Kill a long-running query
psql -U username -c "SELECT pg_cancel_backend(pid);"

# Find the slowest queries
psql -U username -c "SELECT substring(query, 1, 50) AS short_query, round(total_exec_time::numeric, 2) AS total_exec_time, calls, round(mean_exec_time::numeric, 2) AS mean, round((100 * total_exec_time / sum(total_exec_time::numeric) OVER ())::numeric, 2) AS percentage FROM pg_stat_statements ORDER BY total_exec_time DESC LIMIT 10;"

# Show table statistics
psql -U username -c "SELECT * FROM pg_stat_user_tables;"

# Show index usage statistics
psql -U username -c "SELECT * FROM pg_stat_user_indexes;"
```

### Resource Utilization

```bash
# Check database size
psql -U username -c "SELECT pg_size_pretty(pg_database_size('database_name'));"

# Check table sizes
psql -U username -d database_name -c "SELECT table_name, pg_size_pretty(pg_total_relation_size(quote_ident(table_name))) AS total_size FROM information_schema.tables WHERE table_schema = 'public' ORDER BY pg_total_relation_size(quote_ident(table_name)) DESC;"

# Check index sizes
psql -U username -d database_name -c "SELECT indexname, pg_size_pretty(pg_relation_size(indexname::text)) AS index_size FROM pg_indexes WHERE schemaname = 'public' ORDER BY pg_relation_size(indexname::text) DESC;"

# Monitor connections
psql -U username -c "SELECT count(*), datname, usename, client_addr FROM pg_stat_activity GROUP BY datname, usename, client_addr;"

# Check connection limits
psql -U username -c "SHOW max_connections;"
psql -U username -c "SELECT count(*) FROM pg_stat_activity;"
```

### Database and Table Maintenance

```bash
# Vacuum a database
vacuumdb -U username database_name

# Vacuum analyze a specific table
psql -U username -d database_name -c "VACUUM ANALYZE table_name;"

# Full vacuum
psql -U username -d database_name -c "VACUUM FULL table_name;"

# Reindex a table
psql -U username -d database_name -c "REINDEX TABLE table_name;"

# Reindex a database
reindexdb -U username database_name

# Check for bloat
psql -U username -d database_name -c "SELECT schemaname, tablename, pg_size_pretty(bloat_size) as bloat_size, pg_size_pretty(table_size) as actual_size, bloat_ratio FROM (SELECT *, table_size-bloat_size AS actual_table_size, round(bloat_size*100/table_size) AS bloat_ratio FROM (SELECT schemaname, tablename, pg_total_relation_size(schemaname || '.' || tablename) AS table_size, ((record_count+CASE WHEN current_setting('block_size')::numeric > 8192 THEN 1 ELSE 0 END)/((bs-page_hdr)/tpl_size)-(sub_pages+CASE WHEN page_hdr>sub_page_hdr THEN 1 ELSE 0 END)) AS bloat_size FROM (SELECT heap.nspname AS schemaname, heap.relname AS tablename, bs, tpl_data_size, tpl_hdr_size, index_tuple_hdr_size, block_size, ma-4 AS page_hdr, block_size-ma - CASE WHEN version >= 80000 THEN block_size/32 ELSE 0 END AS sub_page_hdr, heap.n_tuples AS record_count, count(heap.n_tuples) / (ma/block_size::float) AS sub_pages, ceil(heap.reltuples/floor((block_size-page_hdr-1)/max(index_tuple_hdr_size, tpl_hdr_size+tpl_data_size))) + ceil(heap.reltuples/floor((block_size-page_hdr-1)/(tpl_hdr_size+1))) AS totalpages, block_size, block_size - 24 - ma - CASE WHEN 8 < block_size/10 THEN 8 ELSE block_size/10 END AS tpl_size FROM (SELECT heap.nspname, heap.relname, heap.reltuples, heap.relpages, heap.relkind, bs, tpl_data_size, tpl_hdr_size, index_tuple_hdr_size, block_size, version, ma, setting FROM (SELECT ns.nspname, rel.relname, rel.reltuples, rel.relpages, rel.relkind, (datawidth + (hdr_width + ma - (case when hdr_width % ma = 0 THEN ma ELSE hdr_width % ma END))) + nullhdr2 AS tpl_data_size, 32 AS tpl_hdr_size, 8 AS index_tuple_hdr_size FROM (SELECT hdr + ma-case when hdr%ma=0 THEN ma ELSE hdr%ma END + CASE WHEN oou.attlen > 0 THEN ma-case when ma%oou.attlen=0 THEN ma ELSE ma%oou.attlen END ELSE 0 END AS datawidth, hdr, ma, ns.nspname, rel.relname, reltuples, relpages, relkind FROM (SELECT ma, sum((1-case when attnotnull THEN 0 ELSE 1 END)*ma) AS hdr, ns.nspname, rel.relname, rel.reltuples, rel.relpages, rel.relkind, sum((CASE WHEN atttypid in (ARRAY[1042, 1043]) THEN atttypmod-4 WHEN atttypid in (ARRAY[16, 17, 18, 19, 20, 21, 23, 26, 700, 701, 704, 869, 1082, 1083, 1266, 1700]) THEN getwidth(atttypid) ELSE getwidth(CASE WHEN atttypid IN(ARRAY[1700]) THEN 842 ELSE atttypid END)*(CASE WHEN attlen > 0 THEN attlen ELSE 10 END) END)*(attnotnull+0)) FROM pg_catalog.pg_attribute att JOIN pg_catalog.pg_type typ ON att.atttypid = typ.oid JOIN pg_catalog.pg_class rel ON att.attrelid = rel.oid JOIN pg_catalog.pg_namespace ns ON rel.relnamespace = ns.oid JOIN (SELECT attrelid, max(attnum) as attnum FROM pg_catalog.pg_attribute GROUP BY attrelid) aa ON att.attrelid=aa.attrelid AND att.attnum<=aa.attnum WHERE ns.nspname NOT IN ('pg_catalog','information_schema') AND rel.relkind in ('r','t') AND att.attnum > 0 GROUP BY ma, ns.nspname, rel.relname, rel.reltuples, rel.relpages, rel.relkind ORDER BY ns.nspname, rel.relname, ma) sp JOIN pg_catalog.pg_attribute oou ON sp.relname=oou.attrelid::regclass::text AND oou.attnum = 1) oou, (SELECT current_setting('block_size')::numeric BS) bs) rel, (SELECT count(*) bloat, ma, bs FROM pg_catalog.pg_attribute GROUP BY 2,3) ma_table, (SELECT current_setting('block_size')::numeric BS) bs, version()) AS subq) as heap, (SELECT current_setting('block_size')::numeric BS) bs WHERE schemaname='public') AS tables WHERE bloat_ratio >= 30 AND table_size > 1024 * 1024 * 10 ORDER BY bloat_size DESC LIMIT 10;"
```

## MongoDB Troubleshooting

### Server Status and Information

```bash
# Check if MongoDB is running
sudo systemctl status mongod

# Get MongoDB version
mongod --version

# Connect to MongoDB server
mongo --host hostname

# Check MongoDB server status
mongo --eval "db.serverStatus()"

# Show MongoDB databases
mongo --eval "show dbs"

# Show MongoDB collections
mongo database_name --eval "show collections"

# Check MongoDB replica set status
mongo --eval "rs.status()"
```

### Performance and Slow Queries

```bash
# Enable profiling for slow queries
mongo --eval "db.setProfilingLevel(1, 100)" # Profile queries slower than 100ms

# Check profiling status
mongo --eval "db.getProfilingStatus()"

# View slow queries
mongo --eval "db.system.profile.find().pretty()"

# Get current operations
mongo --eval "db.currentOp()"

# Kill a specific operation
mongo --eval "db.killOp(opid)"

# View database statistics
mongo --eval "db.stats()"

# View collection statistics
mongo --eval "db.collection_name.stats()"
```

### Index Management

```bash
# Show collection indexes
mongo --eval "db.collection_name.getIndexes()"

# Create an index
mongo --eval "db.collection_name.createIndex({field_name: 1})"

# Explain a query
mongo --eval "db.collection_name.find({query}).explain('executionStats')"

# Check index usage
mongo --eval "db.collection_name.aggregate([{$indexStats: {}}])"

# Remove an index
mongo --eval "db.collection_name.dropIndex('index_name')"
```

### Resource Utilization

```bash
# Check memory usage
mongo --eval "db.serverStatus().mem"

# Check connections
mongo --eval "db.serverStatus().connections"

# Check network traffic
mongo --eval "db.serverStatus().network"

# Check operation counters
mongo --eval "db.serverStatus().opcounters"

# Check lock information
mongo --eval "db.serverStatus().locks"
```

## Redis Troubleshooting

### Server Status and Information

```bash
# Check if Redis is running
sudo systemctl status redis

# Get Redis version
redis-cli --version

# Connect to Redis server
redis-cli -h hostname -p port -a password

# Check Redis server info
redis-cli info

# Monitor Redis commands in real-time
redis-cli monitor

# Check Redis memory usage
redis-cli info memory

# Check Redis clients
redis-cli info clients
```

### Performance Monitoring

```bash
# Check slow log
redis-cli slowlog get 10

# Get statistics about keys
redis-cli --stat

# Check command statistics
redis-cli info commandstats

# Scan for big keys
redis-cli --bigkeys

# Check latency
redis-cli --latency

# Run Redis benchmark
redis-benchmark -h hostname -p port -c 50 -n 10000 -q
```

### Memory Management

```bash
# Check memory usage breakdown
redis-cli memory stats

# Find memory usage of a key
redis-cli memory usage key_name

# Check if Redis is swapping
redis-cli info stats | grep process_id
cat /proc/$(redis-cli info stats | grep process_id | cut -d: -f2)/smaps | grep -i swap

# Check maxmemory policy
redis-cli config get maxmemory-policy

# Set maxmemory policy
redis-cli config set maxmemory-policy allkeys-lru

# Flush all data (use with caution)
redis-cli flushall
```

### Replication and Cluster

```bash
# Check replication status
redis-cli info replication

# Check cluster status
redis-cli cluster info

# List cluster nodes
redis-cli cluster nodes

# Check for cluster errors
redis-cli cluster check hostname:port

# Manually failover
redis-cli -h master_host -p master_port cluster failover
```

## General Database Performance

### Query Optimization Tips

1. **Proper Indexing**
   - Create indexes on frequently queried columns
   - Avoid over-indexing (indexes consume space and slow down writes)
   - Use composite indexes for multi-column queries

2. **Query Structure**
   - Use specific column names instead of SELECT *
   - Limit result sets
   - Use appropriate JOIN types
   - Avoid unnecessary subqueries

3. **Connection Pooling**
   - Implement connection pooling to reduce connection overhead
   - Monitor connection usage and optimize pool size

4. **Caching Strategies**
   - Use query caching where appropriate
   - Implement application-level caching for frequent queries
   - Consider Redis or Memcached for caching layers

5. **Regular Maintenance**
   - Schedule regular vacuum/analyze operations
   - Monitor and manage database growth
   - Purge old data or archive to secondary storage

## Connection Issues

### Common Connection Problems

```bash
# Check network connectivity
telnet hostname port

# Verify firewall settings
sudo iptables -L

# Check listening ports
sudo netstat -tulpn | grep LISTEN

# Test DNS resolution
nslookup hostname

# Check SSL/TLS certificates
openssl s_client -connect hostname:port

# Check database logs for connection errors
tail -f /var/log/mysql/error.log    # MySQL
tail -f /var/log/postgresql/postgresql-version-main.log    # PostgreSQL
tail -f /var/log/mongodb/mongod.log    # MongoDB
tail -f /var/log/redis/redis-server.log    # Redis
```

### Authentication Issues

```bash
# Reset MySQL root password
sudo systemctl stop mysql
sudo mysqld_safe --skip-grant-tables &
mysql -u root
mysql> USE mysql;
mysql> UPDATE user SET authentication_string=PASSWORD('new_password') WHERE User='root';
mysql> FLUSH PRIVILEGES;
mysql> quit;
sudo systemctl start mysql

# Reset PostgreSQL password
sudo -u postgres psql
postgres=# ALTER USER username WITH PASSWORD 'new_password';

# Check MongoDB authentication
mongo --eval "db.getUsers()"

# Reset Redis password
redis-cli config set requirepass "new_password"
```

## Backup and Recovery

### Backup Commands

```bash
# MySQL backup
mysqldump -u username -p database_name > backup.sql
mysqldump -u username -p --all-databases > full_backup.sql

# PostgreSQL backup
pg_dump -U username database_name > backup.sql
pg_dumpall -U username > full_backup.sql

# MongoDB backup
mongodump --host hostname --db database_name --out backup_directory
mongodump --host hostname --out backup_directory

# Redis backup
redis-cli save    # Synchronous save
redis-cli bgsave    # Asynchronous save
```

### Recovery Commands

```bash
# MySQL recovery
mysql -u username -p database_name < backup.sql

# PostgreSQL recovery
psql -U username database_name < backup.sql

# MongoDB recovery
mongorestore --host hostname --db database_name backup_directory/database_name

# Redis recovery
# Redis automatically loads the dump.rdb file on restart
```

### Point-in-Time Recovery

```bash
# MySQL binary log recovery
mysqlbinlog binlog.000001 | mysql -u username -p

# PostgreSQL WAL recovery
# Edit recovery.conf:
restore_command = 'cp /path/to/archive/%f %p'
recovery_target_time = '2023-01-01 12:00:00'

# MongoDB oplog replay
mongorestore --host hostname --oplogReplay
```

## Common Scenarios

### Scenario 1: MySQL High CPU Usage

**Symptoms:**
- High server load
- Slow query responses
- Many running processes

**Diagnosis:**
```bash
# Check current processes
mysql -u username -p -e "SHOW PROCESSLIST" | grep -v Sleep

# Find slow queries
tail -f /var/log/mysql/mysql-slow.log

# Check query cache hit rate
mysql -u username -p -e "SHOW GLOBAL STATUS LIKE 'Qcache%'"
```

**Solution:**
1. Optimize problematic queries
   ```bash
   EXPLAIN SELECT * FROM large_table WHERE non_indexed_column = 'value';
   # Add appropriate indexes based on EXPLAIN output
   ALTER TABLE large_table ADD INDEX (non_indexed_column);
   ```
   
2. Adjust MySQL configuration
   ```ini
   # Add to my.cnf
   innodb_buffer_pool_size = 4G  # Adjust based on server memory
   query_cache_type = 1
   query_cache_size = 128M
   ```
   
3. Implement connection pooling at application level

### Scenario 2: PostgreSQL Database Bloat

**Symptoms:**
- Increasing disk usage
- Slower query performance over time
- High I/O activity during queries

**Diagnosis:**
```bash
# Check table and index sizes
psql -U username -d database_name -c "SELECT pg_size_pretty(pg_total_relation_size('table_name'));"

# Check for bloat
psql -U username -d database_name -c "SELECT schemaname, tablename, pg_size_pretty(bloat_size) AS bloat_size, pg_size_pretty(table_size) AS actual_size, bloat_ratio FROM (SELECT *, table_size-bloat_size AS actual_table_size, round(bloat_size*100/table_size) AS bloat_ratio FROM (SELECT schemaname, tablename, pg_total_relation_size(schemaname || '.' || tablename) AS table_size, ((record_count+CASE WHEN current_setting('block_size')::numeric > 8192 THEN 1 ELSE 0 END)/((bs-page_hdr)/tpl_size)-(sub_pages+CASE WHEN page_hdr>sub_page_hdr THEN 1 ELSE 0 END)) AS bloat_size FROM (SELECT heap.nspname AS schemaname, heap.relname AS tablename, bs, tpl_data_size, tpl_hdr_size, index_tuple_hdr_size, block_size, ma-4 AS page_hdr, block_size-ma - CASE WHEN version >= 80000 THEN block_size/32 ELSE 0 END AS sub_page_hdr, heap.n_tuples AS record_count, count(heap.n_tuples) / (ma/block_size::float) AS sub_pages, ceil(heap.reltuples/floor((block_size-page_hdr-1)/max(index_tuple_hdr_size, tpl_hdr_size+tpl_data_size))) + ceil(heap.reltuples/floor((block_size-page_hdr-1)/(tpl_hdr_size+1))) AS totalpages, block_size, block_size - 24 - ma - CASE WHEN 8 < block_size/10 THEN 8 ELSE block_size/10 END AS tpl_size FROM (SELECT heap.nspname, heap.relname, heap.reltuples, heap.relpages, heap.relkind, bs, tpl_data_size, tpl_hdr_size, index_tuple_hdr_size, block_size, version, ma, setting FROM (SELECT ns.nspname, rel.relname, rel.reltuples, rel.relpages, rel.relkind, (datawidth + (hdr_width + ma - (case when hdr_width % ma = 0 THEN ma ELSE hdr_width % ma END))) + nullhdr2 AS tpl_data_size, 32 AS tpl_hdr_size, 8 AS index_tuple_hdr_size FROM (SELECT hdr + ma-case when hdr%ma=0 THEN ma ELSE hdr%ma END + CASE WHEN oou.attlen > 0 THEN ma-case when ma%oou.attlen=0 THEN ma ELSE ma%oou.attlen END ELSE 0 END AS datawidth, hdr, ma, ns.nspname, rel.relname, reltuples, relpages, relkind FROM (SELECT ma, sum((1-case when attnotnull THEN 0 ELSE 1 END)*ma) AS hdr, ns.nspname, rel.relname, rel.reltuples, rel.relpages, rel.relkind, sum((CASE WHEN atttypid in (ARRAY[1042, 1043]) THEN atttypmod-4 WHEN atttypid in (ARRAY[16, 17, 18, 19, 20, 21, 23, 26, 700, 701, 704, 869, 1082, 1083, 1266, 1700]) THEN getwidth(atttypid) ELSE getwidth(CASE WHEN atttypid IN(ARRAY[1700]) THEN 842 ELSE atttypid END)*(CASE WHEN attlen > 0 THEN attlen ELSE 10 END) END)*(attnotnull+0)) FROM pg_catalog.pg_attribute att JOIN pg_catalog.pg_type typ ON att.atttypid = typ.oid JOIN pg_catalog.pg_class rel ON att.attrelid = rel.oid JOIN pg_catalog.pg_namespace ns ON rel.relnamespace = ns.oid JOIN (SELECT attrelid, max(attnum) as attnum FROM pg_catalog.pg_attribute GROUP BY attrelid) aa ON att.attrelid=aa.attrelid AND att.attnum<=aa.attnum WHERE ns.nspname NOT IN ('pg_catalog','information_schema') AND rel.relkind in ('r','t') AND att.attnum > 0 GROUP BY ma, ns.nspname, rel.relname, rel.reltuples, rel.relpages, rel.relkind ORDER BY ns.nspname, rel.relname, ma) sp JOIN pg_catalog.pg_attribute oou ON sp.relname=oou.attrelid::regclass::text AND oou.attnum = 1) oou, (SELECT current_setting('block_size')::numeric BS) bs) rel, (SELECT count(*) bloat, ma, bs FROM pg_catalog.pg_attribute GROUP BY 2,3) ma_table, (SELECT current_setting('block_size')::numeric BS) bs, version()) AS subq) as heap, (SELECT current_setting('block_size')::numeric BS) bs WHERE schemaname='public') AS tables WHERE bloat_ratio >= 30 AND table_size > 1024 * 1024 ORDER BY bloat_size DESC LIMIT 10;"
```

**Solution:**
1. Perform regular vacuum operations
   ```bash
   # Regular vacuum (can run while system is online)
   VACUUM ANALYZE table_name;
   
   # Full vacuum (exclusive lock, reclaims more space)
   VACUUM FULL table_name;
   ```
   
2. Adjust autovacuum settings
   ```ini
   # Add to postgresql.conf
   autovacuum = on
   autovacuum_vacuum_threshold = 50
   autovacuum_analyze_threshold = 50
   autovacuum_vacuum_scale_factor = 0.1
   autovacuum_analyze_scale_factor = 0.05
   ```
   
3. Reindex tables
   ```bash
   REINDEX TABLE table_name;
   ```

### Scenario 3: MongoDB High Memory Usage

**Symptoms:**
- MongoDB using excessive RAM
- Slow query performance
- High read/write latency

**Diagnosis:**
```bash
# Check current memory usage
mongo --eval "db.serverStatus().mem"

# Check working set size
mongo --eval "db.serverStatus().wiredTiger.cache['bytes currently in the cache']"

# Identify largest collections
mongo --eval "db.stats()" database_name

# Check index sizes
mongo --eval "db.collection_name.stats().indexSizes"
```

**Solution:**
1. Limit MongoDB cache size
   ```bash
   # Add to mongod.conf
   wiredTiger:
     engineConfig:
       cacheSizeGB: 2  # Set appropriate value based on server memory
   ```
   
2. Optimize or remove unnecessary indexes
   ```bash
   # Find unused indexes
   mongo --eval "db.collection_name.aggregate([{$indexStats: {}}])"
   
   # Remove unused indexes
   mongo --eval "db.collection_name.dropIndex('unused_index_name')"
   ```
   
3. Consider sharding for very large datasets
   ```bash
   # Enable sharding for a database
   mongo --eval "sh.enableSharding('database_name')"
   
   # Shard a collection
   mongo --eval "sh.shardCollection('database_name.collection_name', {shard_key: 1})"
   ```

### Scenario 4: Redis Connection Overload

**Symptoms:**
- "Max number of clients reached" errors
- Slow response times
- Connection timeouts

**Diagnosis:**
```bash
# Check current connections
redis-cli info clients

# Check max clients setting
redis-cli config get maxclients

# Monitor client connections in real-time
redis-cli --stat
```

**Solution:**
1. Increase maximum clients
   ```bash
   # Temporarily
   redis-cli config set maxclients 10000
   
   # Permanently in redis.conf
   maxclients 10000
   ```
   
2. Implement proper connection pooling in application
   ```python
   # Example in Python using redis-py with connection pooling
   import redis
   
   pool = redis.ConnectionPool(host='hostname', port=6379, db=0, max_connections=100)
   r = redis.Redis(connection_pool=pool)
   ```
   
3. Identify and fix clients that aren't properly closing connections
   ```bash
   # List client connections and their idle times
   redis-cli client list
   
   # Set timeout for idle connections in redis.conf
   timeout 300
   ```

---

Remember to always back up your database before making significant changes, especially in production environments. The commands and techniques in this guide should be tested in a development environment first before applying to production systems.