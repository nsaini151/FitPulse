CREATE DATABASE fitpulse;
USE fitpulse;

-- schema.sql
CREATE DATABASE IF NOT EXISTS fitpulse CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE fitpulse;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS attendance;
DROP TABLE IF EXISTS bookings;
DROP TABLE IF EXISTS classes;
DROP TABLE IF EXISTS rooms;
DROP TABLE IF EXISTS class_types;
DROP TABLE IF EXISTS trainers;
DROP TABLE IF EXISTS memberships;
DROP TABLE IF EXISTS members;
DROP TABLE IF EXISTS plans;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE plans (
    plan_id          INT           NOT NULL,
    plan_name        VARCHAR(30)   NOT NULL,
    duration_months  INT           NOT NULL,
    price            DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (plan_id),
    UNIQUE KEY uq_plans_name (plan_name)
) ENGINE=InnoDB;

CREATE TABLE members (
    member_id     INT          NOT NULL,
    first_name    VARCHAR(50)  NOT NULL,
    last_name     VARCHAR(50)  NOT NULL,
    email         VARCHAR(120) NOT NULL,
    phone         VARCHAR(25),
    gender        VARCHAR(10),
    date_of_birth DATE,
    city          VARCHAR(50),
    registered_on DATE         NOT NULL,
    PRIMARY KEY (member_id),
    UNIQUE KEY uq_members_email (email)
) ENGINE=InnoDB;

CREATE TABLE memberships (
    membership_id   INT           NOT NULL,
    member_id       INT           NOT NULL,
    plan_id         INT           NOT NULL,
    start_date      DATE          NOT NULL,
    end_date        DATE          NOT NULL,
    price_paid      DECIMAL(10,2) NOT NULL,
    status          VARCHAR(10)   NOT NULL,
    renewed_from_id INT           NULL,
    PRIMARY KEY (membership_id),
    KEY idx_memberships_member (member_id),
    KEY idx_memberships_plan (plan_id),
    KEY idx_memberships_renewed_from (renewed_from_id),
    CONSTRAINT fk_memberships_member
        FOREIGN KEY (member_id) REFERENCES members (member_id),
    CONSTRAINT fk_memberships_plan
        FOREIGN KEY (plan_id) REFERENCES plans (plan_id),
    CONSTRAINT fk_memberships_renewed_from
        FOREIGN KEY (renewed_from_id) REFERENCES memberships (membership_id)
) ENGINE=InnoDB;

CREATE TABLE trainers (
    trainer_id     INT          NOT NULL,
    full_name      VARCHAR(100) NOT NULL,
    email          VARCHAR(120) NOT NULL,
    phone          VARCHAR(25),
    specialization VARCHAR(50)  NOT NULL,
    hire_date      DATE         NOT NULL,
    PRIMARY KEY (trainer_id),
    UNIQUE KEY uq_trainers_email (email)
) ENGINE=InnoDB;

CREATE TABLE class_types (
    class_type_id INT         NOT NULL,
    class_name    VARCHAR(50) NOT NULL,
    category      VARCHAR(30) NOT NULL,
    duration_min  INT         NOT NULL,
    PRIMARY KEY (class_type_id),
    UNIQUE KEY uq_class_types_name (class_name)
) ENGINE=InnoDB;

CREATE TABLE rooms (
    room_id   INT         NOT NULL,
    room_name VARCHAR(40) NOT NULL,
    capacity  INT         NOT NULL,
    PRIMARY KEY (room_id),
    UNIQUE KEY uq_rooms_name (room_name)
) ENGINE=InnoDB;

CREATE TABLE classes (
    class_id      INT      NOT NULL,
    class_type_id INT      NOT NULL,
    trainer_id    INT      NOT NULL,
    room_id       INT      NOT NULL,
    start_ts      DATETIME NOT NULL,
    end_ts        DATETIME NOT NULL,
    PRIMARY KEY (class_id),
    KEY idx_classes_type (class_type_id),
    KEY idx_classes_trainer (trainer_id),
    KEY idx_classes_room (room_id),
    KEY idx_classes_start (start_ts),
    CONSTRAINT fk_classes_type
        FOREIGN KEY (class_type_id) REFERENCES class_types (class_type_id),
    CONSTRAINT fk_classes_trainer
        FOREIGN KEY (trainer_id) REFERENCES trainers (trainer_id),
    CONSTRAINT fk_classes_room
        FOREIGN KEY (room_id) REFERENCES rooms (room_id)
) ENGINE=InnoDB;

CREATE TABLE bookings (
    booking_id INT         NOT NULL,
    member_id  INT         NOT NULL,
    class_id   INT         NOT NULL,
    booked_at  DATETIME    NOT NULL,
    status     VARCHAR(10) NOT NULL,
    PRIMARY KEY (booking_id),
    UNIQUE KEY uq_bookings_member_class (member_id, class_id),
    UNIQUE KEY uq_bookings_id_member (booking_id, member_id),
    KEY idx_bookings_class (class_id),
    CONSTRAINT fk_bookings_member
        FOREIGN KEY (member_id) REFERENCES members (member_id),
    CONSTRAINT fk_bookings_class
        FOREIGN KEY (class_id) REFERENCES classes (class_id)
) ENGINE=InnoDB;

CREATE TABLE attendance (
    attendance_id INT      NOT NULL,
    member_id     INT      NOT NULL,
    booking_id    INT      NULL,
    check_in_ts   DATETIME NOT NULL,
    check_out_ts  DATETIME NULL,
    PRIMARY KEY (attendance_id),
    UNIQUE KEY uq_attendance_booking (booking_id),
    KEY idx_attendance_member (member_id),
    KEY idx_attendance_checkin (check_in_ts),
    CONSTRAINT fk_attendance_member
        FOREIGN KEY (member_id) REFERENCES members (member_id),
    CONSTRAINT fk_attendance_booking_member
        FOREIGN KEY (booking_id, member_id) REFERENCES bookings (booking_id, member_id)
) ENGINE=InnoDB;

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

-- queries.sql
USE fitpulse;

-- =========================================================
-- A. CONSTRAINTS (completes Phase 2 schema requirements)
-- =========================================================
ALTER TABLE plans
    ADD CONSTRAINT chk_plans_price    CHECK (price > 0),
    ADD CONSTRAINT chk_plans_duration CHECK (duration_months > 0);

ALTER TABLE memberships
    ADD CONSTRAINT chk_memberships_price  CHECK (price_paid >= 0),
    ADD CONSTRAINT chk_memberships_dates  CHECK (end_date >= start_date),
    ADD CONSTRAINT chk_memberships_status CHECK (status IN ('Active','Expired'));

ALTER TABLE rooms
    ADD CONSTRAINT chk_rooms_capacity CHECK (capacity > 0);

ALTER TABLE class_types
    ADD CONSTRAINT chk_class_types_duration CHECK (duration_min > 0);

ALTER TABLE classes
    ADD CONSTRAINT chk_classes_times CHECK (end_ts > start_ts);

ALTER TABLE bookings
    ADD CONSTRAINT chk_bookings_status CHECK (status IN ('Confirmed','Cancelled'));

ALTER TABLE attendance
    ADD CONSTRAINT chk_attendance_times CHECK (check_out_ts IS NULL OR check_out_ts >= check_in_ts);

-- =========================================================
-- B. TRIGGERS
-- =========================================================
DELIMITER $$

-- Flag expired memberships on insert
CREATE TRIGGER trg_memberships_flag_expired_bi
BEFORE INSERT ON memberships
FOR EACH ROW
BEGIN
    IF NEW.end_date < CURDATE() THEN
        SET NEW.status = 'Expired';
    END IF;
END$$

-- Flag expired memberships on update; reactivate if end_date is extended
CREATE TRIGGER trg_memberships_flag_expired_bu
BEFORE UPDATE ON memberships
FOR EACH ROW
BEGIN
    IF NEW.end_date < CURDATE() THEN
        SET NEW.status = 'Expired';
    ELSEIF OLD.status = 'Expired' AND NEW.end_date >= CURDATE() THEN
        SET NEW.status = 'Active';
    END IF;
END$$

-- Block overlapping room/trainer schedules on insert
CREATE TRIGGER trg_classes_no_overlap_bi
BEFORE INSERT ON classes
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM classes c
               WHERE (c.room_id = NEW.room_id OR c.trainer_id = NEW.trainer_id)
                 AND NEW.start_ts < c.end_ts AND NEW.end_ts > c.start_ts) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Room or trainer schedule overlap';
    END IF;
END$$

-- Block overlapping room/trainer schedules on update
CREATE TRIGGER trg_classes_no_overlap_bu
BEFORE UPDATE ON classes
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM classes c
               WHERE c.class_id <> NEW.class_id
                 AND (c.room_id = NEW.room_id OR c.trainer_id = NEW.trainer_id)
                 AND NEW.start_ts < c.end_ts AND NEW.end_ts > c.start_ts) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Room or trainer schedule overlap';
    END IF;
END$$

DELIMITER ;

-- Scheduled sweep: triggers fire only on DML, so an event flags memberships whose end date has passed
-- SET GLOBAL event_scheduler = ON;
CREATE EVENT IF NOT EXISTS evt_flag_expired_memberships
ON SCHEDULE EVERY 1 DAY
STARTS (CURRENT_DATE + INTERVAL 1 DAY + INTERVAL 1 MINUTE)
DO
    UPDATE memberships
       SET status = 'Expired'
     WHERE status <> 'Expired'
       AND end_date < CURDATE();

-- One-time backfill
UPDATE memberships
   SET status = 'Expired'
 WHERE status <> 'Expired'
   AND end_date < CURDATE();

-- =========================================================
-- C. VIEW: comprehensive member profile
-- =========================================================
CREATE OR REPLACE VIEW v_member_profile AS
SELECT
    m.member_id,
    CONCAT(m.first_name, ' ', m.last_name)  AS member_name,
    m.email,
    m.city,
    m.registered_on,
    ms.membership_id                        AS latest_membership_id,
    p.plan_name,
    ms.start_date,
    ms.end_date,
    ms.status                               AS membership_status,
    COALESCE(a.total_visits, 0)             AS total_visits,
    a.last_visit,
    COALESCE(b.confirmed_bookings, 0)       AS confirmed_bookings,
    COALESCE(b.cancelled_bookings, 0)       AS cancelled_bookings
FROM members m
LEFT JOIN memberships ms
       ON ms.membership_id = (SELECT x.membership_id
                              FROM memberships x
                              WHERE x.member_id = m.member_id
                              ORDER BY x.start_date DESC, x.membership_id DESC
                              LIMIT 1)
LEFT JOIN plans p ON p.plan_id = ms.plan_id
LEFT JOIN (SELECT member_id, COUNT(*) AS total_visits, MAX(check_in_ts) AS last_visit
           FROM attendance
           GROUP BY member_id) a ON a.member_id = m.member_id
LEFT JOIN (SELECT member_id,
                  SUM(status = 'Confirmed') AS confirmed_bookings,
                  SUM(status = 'Cancelled') AS cancelled_bookings
           FROM bookings
           GROUP BY member_id) b ON b.member_id = m.member_id;

-- =========================================================
-- D. ANALYTICAL QUERIES
-- =========================================================
-- Reference date = last date present in the data (dataset snapshot), not CURDATE()
SET @ref_date = (SELECT DATE(MAX(check_in_ts)) FROM attendance);

-- Q1a. Attendance by day of week and hour
SELECT
    WEEKDAY(check_in_ts)                                              AS dow_num,
    DAYNAME(check_in_ts)                                              AS day_name,
    HOUR(check_in_ts)                                                 AS hour_of_day,
    COUNT(*)                                                          AS check_ins,
    COUNT(DISTINCT member_id)                                         AS unique_members,
    ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM attendance), 2)      AS pct_of_total
FROM attendance
GROUP BY WEEKDAY(check_in_ts), DAYNAME(check_in_ts), HOUR(check_in_ts)
ORDER BY dow_num, hour_of_day;

-- Q1b. Ten busiest day-hour slots
SELECT
    DAYNAME(check_in_ts) AS day_name,
    HOUR(check_in_ts)    AS hour_of_day,
    COUNT(*)             AS check_ins
FROM attendance
GROUP BY DAYNAME(check_in_ts), HOUR(check_in_ts)
ORDER BY check_ins DESC
LIMIT 10;

-- Q2a. Class fill rate by class type (confirmed bookings / room capacity)
SELECT
    ct.class_name,
    ct.category,
    COUNT(c.class_id)                                                  AS sessions,
    SUM(COALESCE(cb.confirmed, 0))                                     AS confirmed_bookings,
    SUM(r.capacity)                                                    AS total_capacity,
    ROUND(100 * SUM(COALESCE(cb.confirmed, 0)) / SUM(r.capacity), 2)   AS fill_rate_pct,
    ROUND(100 * SUM(COALESCE(cb.attended, 0))
              / NULLIF(SUM(COALESCE(cb.confirmed, 0)), 0), 2)          AS show_rate_pct
FROM classes c
JOIN class_types ct ON ct.class_type_id = c.class_type_id
JOIN rooms r        ON r.room_id = c.room_id
LEFT JOIN (SELECT b.class_id,
                  COUNT(*)           AS confirmed,
                  COUNT(a.attendance_id) AS attended
           FROM bookings b
           LEFT JOIN attendance a ON a.booking_id = b.booking_id
           WHERE b.status = 'Confirmed'
           GROUP BY b.class_id) cb ON cb.class_id = c.class_id
GROUP BY ct.class_type_id, ct.class_name, ct.category
ORDER BY fill_rate_pct DESC;

-- Q2b. Under-filled individual classes (fill rate below 50%)
SELECT
    c.class_id,
    ct.class_name,
    c.start_ts,
    r.room_name,
    r.capacity,
    COALESCE(cb.confirmed, 0)                                AS confirmed_bookings,
    ROUND(100 * COALESCE(cb.confirmed, 0) / r.capacity, 2)   AS fill_rate_pct
FROM classes c
JOIN class_types ct ON ct.class_type_id = c.class_type_id
JOIN rooms r        ON r.room_id = c.room_id
LEFT JOIN (SELECT class_id, COUNT(*) AS confirmed
           FROM bookings
           WHERE status = 'Confirmed'
           GROUP BY class_id) cb ON cb.class_id = c.class_id
GROUP BY c.class_id, ct.class_name, c.start_ts, r.room_name, r.capacity, cb.confirmed
HAVING fill_rate_pct < 50
ORDER BY fill_rate_pct ASC, c.start_ts
LIMIT 50;

-- Q3. Inactive members: active membership at @ref_date, no visit in the 30 days before it
SELECT
    m.member_id,
    CONCAT(m.first_name, ' ', m.last_name)               AS member_name,
    m.email,
    p.plan_name,
    ms.end_date                                          AS membership_end,
    la.last_visit,
    DATEDIFF(@ref_date, DATE(la.last_visit))             AS days_since_last_visit
FROM members m
JOIN memberships ms ON ms.member_id = m.member_id
                   AND @ref_date BETWEEN ms.start_date AND ms.end_date
JOIN plans p        ON p.plan_id = ms.plan_id
LEFT JOIN (SELECT member_id, MAX(check_in_ts) AS last_visit
           FROM attendance
           GROUP BY member_id) la ON la.member_id = m.member_id
WHERE NOT EXISTS (SELECT 1
                  FROM attendance att
                  WHERE att.member_id = m.member_id
                    AND att.check_in_ts > DATE_SUB(@ref_date, INTERVAL 30 DAY))
ORDER BY days_since_last_visit DESC;

-- Q4. Renewal rate by plan
-- Eligible = memberships ended at least 7 days before @ref_date (renewal grace window)
SELECT
    p.plan_name,
    COUNT(*)                                                                    AS eligible_memberships,
    SUM(CASE WHEN EXISTS (SELECT 1 FROM memberships n
                          WHERE n.renewed_from_id = ms.membership_id)
             THEN 1 ELSE 0 END)                                                 AS renewed,
    ROUND(100 * SUM(CASE WHEN EXISTS (SELECT 1 FROM memberships n
                                      WHERE n.renewed_from_id = ms.membership_id)
                         THEN 1 ELSE 0 END) / COUNT(*), 2)                      AS renewal_rate_pct
FROM memberships ms
JOIN plans p ON p.plan_id = ms.plan_id
WHERE ms.end_date <= DATE_SUB(@ref_date, INTERVAL 7 DAY)
GROUP BY p.plan_id, p.plan_name
ORDER BY renewal_rate_pct DESC;

-- Fix for Q2b: Under-filled individual classes (past classes only, fill rate below 50%)
SELECT
    c.class_id,
    ct.class_name,
    c.start_ts,
    r.room_name,
    r.capacity,
    COALESCE(cb.confirmed, 0)                                AS confirmed_bookings,
    ROUND(100 * COALESCE(cb.confirmed, 0) / r.capacity, 2)   AS fill_rate_pct
FROM classes c
JOIN class_types ct ON ct.class_type_id = c.class_type_id
JOIN rooms r        ON r.room_id = c.room_id
LEFT JOIN (SELECT class_id, COUNT(*) AS confirmed
           FROM bookings
           WHERE status = 'Confirmed'
           GROUP BY class_id) cb ON cb.class_id = c.class_id
WHERE c.start_ts <= (SELECT MAX(check_in_ts) FROM attendance)
GROUP BY c.class_id, ct.class_name, c.start_ts, r.room_name, r.capacity, cb.confirmed
HAVING fill_rate_pct < 50
ORDER BY fill_rate_pct ASC, c.start_ts
LIMIT 50;

-- Fix for Q3: Inactive members based on actual attendance history
SELECT
    m.member_id,
    CONCAT(m.first_name, ' ', m.last_name)               AS member_name,
    m.email,
    p.plan_name,
    ms.end_date                                          AS membership_end,
    la.last_visit,
    DATEDIFF((SELECT MAX(DATE(check_in_ts)) FROM attendance), DATE(la.last_visit)) AS days_since_last_visit
FROM members m
JOIN memberships ms ON ms.member_id = m.member_id
JOIN plans p        ON p.plan_id = ms.plan_id
JOIN (SELECT member_id, MAX(check_in_ts) AS last_visit
      FROM attendance
      GROUP BY member_id) la ON la.member_id = m.member_id
WHERE la.last_visit < DATE_SUB((SELECT MAX(check_in_ts) FROM attendance), INTERVAL 30 DAY)
ORDER BY days_since_last_visit DESC
LIMIT 50;