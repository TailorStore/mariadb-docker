-- Restore production-safe settings after import
-- Run this script IMMEDIATELY after import completion

-- Restore durability features for production safety
SET GLOBAL innodb_flush_log_at_trx_commit = 2;           -- Safe for production (faster than 1)
SET GLOBAL sync_binlog = 1;                              -- Enable binary log sync
SET sql_log_bin = 1;                                     -- Re-enable binary logging

-- Reset buffer sizes to production values (from custom.cnf)
SET GLOBAL key_buffer_size = 32*1024*1024;               -- 32MB
SET GLOBAL sort_buffer_size = 4*1024*1024;               -- 4MB per connection
SET GLOBAL read_buffer_size = 2*1024*1024;               -- 2MB per connection
SET GLOBAL read_rnd_buffer_size = 4*1024*1024;           -- 4MB per connection
SET GLOBAL join_buffer_size = 4*1024*1024;               -- 4MB per connection

-- Restore I/O settings to production values
SET GLOBAL innodb_io_capacity = 200;
SET GLOBAL innodb_io_capacity_max = 400;

-- Restore production timeouts
SET GLOBAL innodb_lock_wait_timeout = 50;
SET GLOBAL max_allowed_packet = 64*1024*1024;            -- 64MB

-- Re-enable query cache (if desired)
SET GLOBAL query_cache_size = 128*1024*1024;             -- 128MB

-- Force a checkpoint to ensure all changes are written to disk
SET GLOBAL innodb_fast_shutdown = 0;

-- Show restored settings
SELECT 'Production settings restored (binary logging re-enabled)' AS Status;
SELECT @@innodb_flush_log_at_trx_commit AS flush_log_at_commit,
       @@sync_binlog AS sync_binlog,
       @@innodb_io_capacity AS io_capacity,
       @@max_allowed_packet AS max_packet;
