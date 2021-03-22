/* Missing roles, most relationships */

CREATE TABLE Employees (
    eid INTEGER PRIMARY KEY,
    name VARCHAR(256),
    phone INTEGER,
    email VARCHAR(256),
    join_date DATE,
    address TEXT,
    depart_date DATE
);

CREATE TABLE Customers (
    cust_id INTEGER PRIMARY KEY,
    name VARCHAR(256),
    phone INTEGER,
    email VARCHAR(256),
    address TEXT,
);

CREATE TABLE Rooms (
    rid INTEGER PRIMARY KEY,
    location VARCHAR(256),
    seating_capacity INTEGER
);

CREATE TABLE Course_packages (
    package_id INTEGER PRIMARY KEY,
    sale_start_date DATE,
    num_free_registrations INTEGER,
    sale_end_date DATE,
    name VARCHAR(256),
    price FLOAT
);

CREATE TABLE Credit_cards (
    number INTEGER PRIMARY KEY,
    CVV INTEGER,
    expiry_date DATE
)

CREATE TABLE Courses (
    course_id INTEGER PRIMARY KEY,
    duration INTEGER,
    description TEXT,
    title VARCHAR(256)
)

/* dk why is seating_capacity here tbh */
CREATE TABLE Offerings (
    course_id INTEGER REFERENCES Courses,
    launch_date DATE,
    end_date DATE,
    start_date DATE,
    registration_deadline DATE,
    target_number_registrations INTEGER,
    seating_capacity INTEGER,
    fees FLOAT,
    PRIMARY KEY (course_id, launch_date)
);

CREATE TABLE Sessions (
    course_id INTEGER,
    launch_date DATE,
    sid INTEGER,
    date DATE,
    start_time TIME,
    end_time TIME,
    FOREIGN KEY (course_id, launch_date) REFERENCES Offerings,
    PRIMARY KEY (course_id, launch_date, sid)
);

CREATE TABLE Pay_slips (
    eid INTEGER REFERENCES Employees,
    payment_date DATE,
    amount FLOAT,
    num_work_hours INTEGER,
    num_work_days INTEGER
    PRIMARY KEY (eid, payment_date)
);
