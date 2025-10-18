-- V2__AddTestUser.sql
-- This script adds a temporary user for development and testing purposes.
-- The password is 'password123' and is hashed using BCrypt.
-- You can generate new hashes for different passwords using an online BCrypt generator.

INSERT INTO users (email, display_name, password_hash, role)
VALUES (
    'test@fireshield.com',
    'Test User',
    '$2a$10$E.h6pZ5s/T/8x0b5K3.7h.M8B/o.2a27b/P2e25vV2.o5d/H.p2b6', -- This is a BCrypt hash for 'password123'
    'USER'
)
ON CONFLICT (email) DO NOTHING; -- This ensures the script doesn't fail if the user already exists.
