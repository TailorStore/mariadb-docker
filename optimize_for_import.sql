-- Production-safe import optimization script
-- These settings can be applied temporarily during imports without restarting MariaDB

-- Disable durability features temporarily (CAUTION: Only during imports!)
SET GLOBAL innodb_flush_log_at_trx_commit = 0;
SET GLOBAL sync_binlog = 0;

-- Disable binary logging during import for maximum speed
SET sql_log_bin = 0;

-- Disable constraint and validation checks for speed
SET foreign_key_checks = 0;
SET unique_checks = 0;
SET autocommit = 0;
SET sql_mode = '';

-- Optimize InnoDB for bulk loading
SET GLOBAL innodb_doublewrite = 0;                       -- Disable doublewrite buffer for speed
SET GLOBAL innodb_buffer_pool_dump_at_shutdown = 0;      -- Skip buffer pool dump
SET GLOBAL innodb_change_buffering = 'all';              -- Buffer all changes
SET GLOBAL innodb_stats_on_metadata = 0;                 -- Disable stats on metadata access

-- Increase buffer sizes that can be changed dynamically
SET GLOBAL innodb_log_buffer_size = 64*1024*1024;        -- 64MB
SET GLOBAL key_buffer_size = 128*1024*1024;              -- 128MB
SET GLOBAL sort_buffer_size = 32*1024*1024;              -- 32MB per connection
SET GLOBAL read_buffer_size = 8*1024*1024;               -- 8MB per connection
SET GLOBAL read_rnd_buffer_size = 16*1024*1024;          -- 16MB per connection
SET GLOBAL bulk_insert_buffer_size = 256*1024*1024;      -- 256MB for bulk inserts
SET GLOBAL join_buffer_size = 16*1024*1024;              -- 16MB per connection

-- Increase I/O settings
SET GLOBAL innodb_io_capacity = 2000;
SET GLOBAL innodb_io_capacity_max = 4000;

-- Optimize for bulk operations
SET GLOBAL innodb_lock_wait_timeout = 300;
SET GLOBAL max_allowed_packet = 1073741824;              -- 1GB

-- Disable query cache during import (if enabled)
SET GLOBAL query_cache_size = 0;

-- Show current settings
SELECT 'Import optimization settings applied' AS Status;
SELECT @@innodb_flush_log_at_trx_commit AS flush_log_at_commit,
       @@sync_binlog AS sync_binlog,
       @@innodb_io_capacity AS io_capacity,
       @@max_allowed_packet AS max_packet;
