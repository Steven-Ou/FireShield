-- V3__Add_Test_Device_And_Samples.sql

-- First, declare a variable to hold the UUID of our test user.
DO $$
DECLARE
    test_user_id UUID;
BEGIN
    -- Find the UUID of our test user and store it.
    SELECT id INTO test_user_id FROM users WHERE email = 'test@fireshield.com';

    -- If the user was found, proceed to add a device and sample data.
    IF test_user_id IS NOT NULL THEN
        -- Declare a variable for the new device's UUID.
        DECLARE
            test_device_id UUID;
        BEGIN
            -- Insert a new device linked to our test user and get its new UUID.
            INSERT INTO devices (name, device_key, owner_id)
            VALUES ('Station 1 Sensor', 'TEST-DEVICE-001', test_user_id)
            ON CONFLICT (device_key) DO NOTHING; -- Don't error if it already exists

            SELECT id INTO test_device_id FROM devices WHERE device_key = 'TEST-DEVICE-001';

            -- Now, insert a series of realistic sensor data points for this device.
            -- This simulates VOC readings over the last 24 hours.
            IF test_device_id IS NOT NULL THEN
                INSERT INTO samples (device_id, ts, tvoc_ppb, formaldehyde_ppm, benzene_ppm)
                VALUES
                    (test_device_id, NOW() - INTERVAL '23 hours', 350, 0.04, 0.02),
                    (test_device_id, NOW() - INTERVAL '22 hours', 410, 0.05, 0.02),
                    (test_device_id, NOW() - INTERVAL '21 hours', 550, 0.06, 0.03), -- Elevated
                    (test_device_id, NOW() - INTERVAL '18 hours', 980, 0.11, 0.05), -- Critical Spike
                    (test_device_id, NOW() - INTERVAL '17 hours', 750, 0.09, 0.04), -- Elevated
                    (test_device_id, NOW() - INTERVAL '15 hours', 480, 0.05, 0.02),
                    (test_device_id, NOW() - INTERVAL '12 hours', 320, 0.03, 0.01),
                    (test_device_id, NOW() - INTERVAL '9 hours', 280, 0.02, 0.01),
                    (test_device_id, NOW() - INTERVAL '6 hours', 420, 0.04, 0.02),
                    (test_device_id, NOW() - INTERVAL '3 hours', 610, 0.07, 0.03), -- Elevated
                    (test_device_id, NOW() - INTERVAL '1 hour', 530, 0.06, 0.02);
            END IF;
        END;
    END IF;
END $$;