-- =====================================================================
-- CoreFlux Demo/Tutorial - Simplified TimescaleDB Schema
-- =====================================================================
--
-- Purpose: Simple time-series storage for CoreFlux LOT demo
-- Database: TimescaleDB (PostgreSQL extension)
--
-- Design: Minimal demo schema with just 2 tables
--   1. numeric_timeseries - All numeric metrics (CPU, memory, etc.)
--   2. alerts - Alert history

-- =====================================================================

-- Enable TimescaleDB extension
CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;

-- Create dedicated schema for metrics
CREATE SCHEMA IF NOT EXISTS metrics;

-- Set search path for convenience
SET search_path TO metrics, public;

-- =====================================================================
-- TABLE 1: Numeric Timeseries Data
-- =====================================================================

CREATE TABLE IF NOT EXISTS metrics.numeric_timeseries (
    event_time          TIMESTAMPTZ NOT NULL,
    ingestion_time      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    hostname            TEXT NOT NULL,
    metric_name         TEXT NOT NULL,
    value               DOUBLE PRECISION NOT NULL,
    unit                TEXT NOT NULL
);

-- Create hypertable with 1-day chunks
SELECT create_hypertable(
    'metrics.numeric_timeseries',
    'event_time',
    chunk_time_interval => INTERVAL '1 day',
    if_not_exists => TRUE
);

-- Simple index for querying by hostname and metric
CREATE INDEX IF NOT EXISTS idx_numeric_host_metric_time
    ON metrics.numeric_timeseries (hostname, metric_name, event_time DESC);

COMMENT ON TABLE metrics.numeric_timeseries IS
'Simple timeseries storage for all numeric metrics (CPU, memory, load, etc.)';

-- =====================================================================
-- TABLE 2: Alerts
-- =====================================================================

CREATE TABLE IF NOT EXISTS metrics.alerts (
    id                  SERIAL NOT NULL,
    event_time          TIMESTAMPTZ NOT NULL,
    ingestion_time      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    severity            TEXT NOT NULL,
    hostname            TEXT NOT NULL,
    metric              TEXT NOT NULL,
    current_value       DOUBLE PRECISION NOT NULL,
    threshold           DOUBLE PRECISION NOT NULL,
    message             TEXT NOT NULL,
    alert_id            TEXT NOT NULL,
    PRIMARY KEY (id, event_time)
);

-- Create hypertable
SELECT create_hypertable(
    'metrics.alerts',
    'event_time',
    chunk_time_interval => INTERVAL '1 day',
    if_not_exists => TRUE
);

-- Index for querying alerts by severity and time
CREATE INDEX IF NOT EXISTS idx_alerts_severity_time
    ON metrics.alerts (severity, event_time DESC);

-- Index for querying alerts by hostname
CREATE INDEX IF NOT EXISTS idx_alerts_hostname_time
    ON metrics.alerts (hostname, event_time DESC);

COMMENT ON TABLE metrics.alerts IS
'Alert history for CPU, memory, and other system threshold violations';

-- =====================================================================
-- INITIALIZATION COMPLETE
-- =====================================================================

-- Display initialization summary
DO $$
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'CoreFlux Demo Schema Initialized';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Tables: 2 hypertables';
    RAISE NOTICE '  - numeric_timeseries';
    RAISE NOTICE '  - alerts';
    RAISE NOTICE '========================================';
END $$;
