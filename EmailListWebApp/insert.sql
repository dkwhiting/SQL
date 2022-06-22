CREATE DATABASE waiting_list;
USE waiting_list;

CREATE TABLE users(
    email VARCHAR(255) PRIMARY KEY NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);
