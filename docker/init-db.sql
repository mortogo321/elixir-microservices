-- Initialize PostgreSQL databases
-- This script runs on first container start

-- Create extensions if needed
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create auth database for auth gRPC service
CREATE DATABASE auth_dev;
GRANT ALL PRIVILEGES ON DATABASE auth_dev TO postgres;

-- Grant privileges to api database
GRANT ALL PRIVILEGES ON DATABASE api_dev TO postgres;
