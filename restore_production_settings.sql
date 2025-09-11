-- Restore production-safe settings after import
-- Run this script IMMEDIATELY after import completion

-- Restore durability features for production safety
SET GLOBAL innodb_flush_log_at_trx_commit = 2;           -- Safe for production (faster than 1)
SET GLOBAL sync_binlog = 1;                              -- Enable binary log sync
SET sql_log_bin = 1;                                     -- Re-enable binary logging

-- Re-enable constraint and validation checks
SET foreign_key_checks = 1;                             -- Re-enable foreign key validation
SET unique_checks = 1;                                  -- Re-enable unique constraint checks
SET autocommit = 1;                                     -- Re-enable autocommit
SET sql_mode = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION'; -- Restore strict mode

-- Restore InnoDB production settings
SET GLOBAL innodb_doublewrite = 1;                       -- Re-enable doublewrite buffer for safety
SET GLOBAL innodb_buffer_pool_dump_at_shutdown = 1;      -- Re-enable buffer pool dump
SET GLOBAL innodb_change_buffering = 'all';              -- Keep change buffering enabled
SET GLOBAL innodb_stats_on_metadata = 1;                 -- Re-enable stats on metadata access

-- Reset buffer sizes to production values (from custom.cnf)
SET GLOBAL key_buffer_size = 32*1024*1024;               -- 32MB
SET GLOBAL sort_buffer_size = 4*1024*1024;               -- 4MB per connection
SET GLOBAL read_buffer_size = 2*1024*1024;               -- 2MB per connection
SET GLOBAL read_rnd_buffer_size = 4*1024*1024;           -- 4MB per connection
SET GLOBAL bulk_insert_buffer_size = 8*1024*1024;        -- 8MB (production value)
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
SELECT 'Production settings restored (constraints, indexing, and logging re-enabled)' AS Status;
SELECT @@innodb_flush_log_at_trx_commit AS flush_log_at_commit,
       @@sync_binlog AS sync_binlog,
       @@innodb_io_capacity AS io_capacity,
       @@max_allowed_packet AS max_packet;
