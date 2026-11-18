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