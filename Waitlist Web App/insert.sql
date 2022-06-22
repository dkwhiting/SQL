CREATE DATABASE wait_list;
USE wait_list;

CREATE TABLE users(
    email VARCHAR(255) PRIMARY KEY NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);