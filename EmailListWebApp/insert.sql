CREATE DATABASE ig_clone;
USE ig_clone;

CREATE TABLE users(
    email VARCHAR(255) PRIMARY KEY NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);