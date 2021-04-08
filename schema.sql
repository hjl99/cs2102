DROP TABLE IF EXISTS Customers, Rooms, Course_areas,
Course_packages, Credit_cards, Courses, Offerings,
Sessions, Employees, Part_time_emp,
Full_time_emp, Instructors, Part_time_instructors, 
Full_time_instructors, Administrators, Managers, Pay_slips,
Cancels, Buys, Registers, Specializes, Redeems CASCADE;

 --<----------------------- company side ----------------------->
CREATE TABLE Employees (
    eid SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    phone BIGINT,
    email TEXT,
    join_date DATE NOT NULL DEFAULT CURRENT_DATE,
    address TEXT,
    depart_date DATE
);

CREATE TABLE Part_time_emp (
    eid INTEGER PRIMARY KEY REFERENCES Employees ON DELETE CASCADE,
    hourly_rate FLOAT NOT NULL
    CONSTRAINT hourly_rate_non_neg CHECK (hourly_rate >= 0.0)
);

CREATE TABLE Full_time_emp (
    eid INTEGER PRIMARY KEY REFERENCES Employees ON DELETE CASCADE,
    monthly_salary FLOAT NOT NULL
    CONSTRAINT monthly_salary_non_neg CHECK (monthly_salary >= 0.0)
);

CREATE TABLE Instructors (
    eid INTEGER PRIMARY KEY REFERENCES Employees
);

CREATE TABLE Part_time_instructors (
    eid INTEGER PRIMARY KEY REFERENCES Part_time_emp REFERENCES Instructors 
    ON DELETE CASCADE
);

CREATE TABLE Full_time_instructors (
    eid INTEGER PRIMARY KEY REFERENCES Instructors REFERENCES Full_time_emp 
    ON DELETE CASCADE
);

CREATE TABLE Administrators (
    eid INTEGER PRIMARY KEY REFERENCES Full_time_emp ON DELETE CASCADE
);

CREATE TABLE Managers (
    eid INTEGER PRIMARY KEY REFERENCES Full_time_emp ON DELETE CASCADE
);

CREATE TABLE Pay_slips (
    eid INTEGER REFERENCES Employees ON DELETE CASCADE,
    payment_date DATE,
    amt FLOAT NOT NULL,
    num_work_hours INTEGER,
    num_work_days INTEGER,
    PRIMARY KEY (eid, payment_date),
    CONSTRAINT num_work_hours_non_neg CHECK (num_work_hours >= 0),
    CONSTRAINT num_work_days_non_neg CHECK (num_work_days >= 0),
    CONSTRAINT amt_pos CHECK (amt > 0)
);
-- <---------------------- Customer side ---------------------->

CREATE TABLE Customers (
    cust_id SERIAL PRIMARY KEY,
    cust_name TEXT NOT NULL,
    phone BIGINT,
    email TEXT,
    address TEXT
);

CREATE TABLE Rooms (
    rid SERIAL PRIMARY KEY,
    location TEXT NOT NULL,
    seating_capacity INTEGER DEFAULT 0
    CONSTRAINT seating_capacity_pos CHECK (seating_capacity > 0)
);


CREATE TABLE Course_packages (
    package_id SERIAL PRIMARY KEY,
    sale_start_date DATE NOT NULL,
    num_free_registrations INTEGER NOT NULL,
    sale_end_date DATE NOT NULL,
    package_name TEXT,
    price FLOAT NOT NULL
    CONSTRAINT price_non_neg CHECK (price >= 0.0),
    CONSTRAINT sale_date_validity CHECK (sale_start_date <= sale_end_date),
    CONSTRAINT num_free_reg_pos CHECK (num_free_registrations > 0)
);

CREATE TABLE Course_areas (
    course_area_name TEXT PRIMARY KEY,
    eid INTEGER NOT NULL REFERENCES Managers
);

CREATE TABLE Courses (
    course_id SERIAL PRIMARY KEY,
    duration INTEGER NOT NULL DEFAULT 1,
    description TEXT,
    title TEXT UNIQUE NOT NULL,
    course_area_name TEXT NOT NULL REFERENCES Course_areas,
    CONSTRAINT duration_validity CHECK (duration > 0 and duration <= 4)
);

CREATE TABLE Offerings (
    course_id INTEGER REFERENCES Courses ON DELETE CASCADE,
    launch_date DATE,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    reg_deadline DATE NOT NULL,
    num_target_reg INTEGER NOT NULL,
    seating_capacity INTEGER NOT NULL,
    fees FLOAT NOT NULL,
    eid INTEGER NOT NULL REFERENCES Administrators,
    PRIMARY KEY (course_id, launch_date),   
    CONSTRAINT start_end_date_validity CHECK (start_date <= end_date),
    CONSTRAINT registration_deadline_validity CHECK (reg_deadline + INTERVAL '10 DAY' <= start_date),
    CONSTRAINT target_reg_validity CHECK (num_target_reg <= seating_capacity) 
);

CREATE TABLE Sessions (
    sid INTEGER,
    s_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    course_id INTEGER,
    launch_date DATE,
    rid INTEGER NOT NULL REFERENCES Rooms ON DELETE CASCADE deferrable initially immediate,
    eid INTEGER NOT NULL REFERENCES Instructors ON DELETE CASCADE deferrable initially immediate,
    is_ongoing BOOLEAN DEFAULT TRUE,
    CONSTRAINT offerings_fkey FOREIGN KEY (course_id, launch_date) REFERENCES Offerings 
    ON DELETE CASCADE deferrable initially immediate,
    PRIMARY KEY (sid, course_id, launch_date),
    CONSTRAINT start_end_time_validity CHECK 
    (start_time <= end_time and start_time >= '09:00:00' and end_time <= '18:00:00'),
    CONSTRAINT lunch_hour_validatity CHECK 
    ((start_time >= '12:00:00' or end_time <= '12:00:00') and 
    (start_time < '12:00:00' or start_time >= '14:00:00'))
);

-- <----------------------associations----------------------->
CREATE TABLE Cancels (
    c_date DATE NOT NULL DEFAULT CURRENT_DATE,
    refund_amt FLOAT,
    package_credit INTEGER,
    cust_id INTEGER REFERENCES Customers ON DELETE NO ACTION,
    course_id INTEGER,
    launch_date DATE,
    sid INTEGER,
    payment_date DATE NOT NULL,
    FOREIGN KEY (sid, course_id, launch_date) REFERENCES Sessions ON DELETE SET NULL, /* for book keeping purposes */
    PRIMARY KEY (c_date, cust_id, course_id, launch_date, sid),
    CONSTRAINT cancellation_validity CHECK ((refund_amt >= 0.0 and package_credit = NULL) or (package_credit in (0, 1) and refund_amt = NULL))
);
/* Trav: considering making pri key number and cust*/
/* Contains the owns relationship to enforce key and total participation on credit cards */
CREATE TABLE Credit_cards (
    number BIGINT PRIMARY KEY,
    CVV INTEGER NOT NULL,
    expiry_date DATE NOT NULL,
    cust_id INTEGER NOT NULL REFERENCES Customers ON DELETE CASCADE,
    from_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

/* Package might not be offered but customer should be able to finish their remaining redemptions*/
CREATE TABLE Buys (
    package_id INTEGER REFERENCES Course_packages ON DELETE SET NULL, 
    number INTEGER REFERENCES Credit_cards ON DELETE CASCADE,
    b_date DATE DEFAULT CURRENT_DATE,
    num_remaining_redemptions INTEGER NOT NULL,
    PRIMARY KEY (package_id, number, b_date),
    CONSTRAINT num_remaining_redemptions_non_neg CHECK (num_remaining_redemptions >= 0)
);

/* Requires triggers to enforce that each customer can register for at most one sesion of a course offering (added)*/
CREATE TABLE Registers (
    number INTEGER REFERENCES Credit_cards ON DELETE CASCADE,
    course_id INTEGER,
    launch_date DATE,
    sid INTEGER,
    r_date DATE,
    FOREIGN KEY (sid, course_id, launch_date) REFERENCES Sessions ON DELETE NO ACTION, 
    PRIMARY KEY (course_id, launch_date, sid, number, r_date)
);

CREATE TABLE  Specializes (
    eid INTEGER REFERENCES Instructors, /*total participation*/
    course_area_name TEXT REFERENCES Course_areas,
    PRIMARY KEY (eid, course_area_name)
);

CREATE TABLE Redeems ( 
    package_id INTEGER, 
    number INTEGER,
    b_date DATE,
    r_date DATE,
    course_id INTEGER,
    launch_date DATE,
    sid INTEGER,
    FOREIGN KEY (package_id, number, b_date) REFERENCES Buys ON DELETE CASCADE,
    FOREIGN KEY (sid, course_id, launch_date) REFERENCES Sessions ON DELETE NO ACTION,
    PRIMARY KEY (package_id, number, b_date, course_id, launch_date, sid, r_date),
    CONSTRAINT date_validity CHECK (b_date <= r_date)
);


