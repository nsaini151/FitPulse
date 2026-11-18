USE fitpulse;

SET FOREIGN_KEY_CHECKS = 0;
SET UNIQUE_CHECKS = 0;

TRUNCATE TABLE attendance;
TRUNCATE TABLE bookings;
TRUNCATE TABLE classes;
TRUNCATE TABLE rooms;
TRUNCATE TABLE class_types;
TRUNCATE TABLE trainers;
TRUNCATE TABLE memberships;
TRUNCATE TABLE members;
TRUNCATE TABLE plans;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/plans.csv'
INTO TABLE plans
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(plan_id, plan_name, duration_months, price);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/members.csv'
INTO TABLE members
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(member_id, first_name, last_name, email, phone, gender, date_of_birth, city, registered_on);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/memberships.csv'
INTO TABLE memberships
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(membership_id, member_id, plan_id, start_date, end_date, price_paid, status, @renewed_from_id)
SET renewed_from_id = NULLIF(TRIM(@renewed_from_id), '');

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/trainers.csv'
INTO TABLE trainers
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(trainer_id, full_name, email, phone, specialization, hire_date);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/class_types.csv'
INTO TABLE class_types
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(class_type_id, class_name, category, duration_min);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/rooms.csv'
INTO TABLE rooms
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(room_id, room_name, capacity);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/classes.csv'
INTO TABLE classes
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(class_id, class_type_id, trainer_id, room_id, start_ts, end_ts);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/bookings.csv'
INTO TABLE bookings
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(booking_id, member_id, class_id, booked_at, status);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/attendance.csv'
INTO TABLE attendance
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(attendance_id, member_id, @booking_id, check_in_ts, @check_out_ts)
SET booking_id   = NULLIF(TRIM(@booking_id), ''),
    check_out_ts = NULLIF(TRIM(@check_out_ts), '');

SET UNIQUE_CHECKS = 1;
SET FOREIGN_KEY_CHECKS = 1;

SELECT 'plans' AS tbl, COUNT(*) AS row_count FROM plans
UNION ALL SELECT 'members',     COUNT(*) FROM members
UNION ALL SELECT 'memberships', COUNT(*) FROM memberships
UNION ALL SELECT 'trainers',    COUNT(*) FROM trainers
UNION ALL SELECT 'class_types', COUNT(*) FROM class_types
UNION ALL SELECT 'rooms',       COUNT(*) FROM rooms
UNION ALL SELECT 'classes',     COUNT(*) FROM classes
UNION ALL SELECT 'bookings',    COUNT(*) FROM bookings
UNION ALL SELECT 'attendance',  COUNT(*) FROM attendance;