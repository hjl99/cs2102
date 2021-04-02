/* Missing roles, most relationships */

-- <---------------------- Customer side ---------------------->

CREATE TABLE Customers (
    cust_id INTEGER PRIMARY KEY,
    name TEXT,
    phone INTEGER,
    email TEXT,
    address TEXT
);

CREATE TABLE Rooms (
    rid INTEGER PRIMARY KEY,
    location TEXT,
    seating_capacity INTEGER
);


CREATE TABLE Course_areas (
    name TEXT PRIMARY KEY,
    eid INTEGER NOT NULL REFERENCES Managers
)


CREATE TABLE Course_packages (
    package_id INTEGER PRIMARY KEY,
    sale_start_date DATE,
    num_free_registrations INTEGER,
    sale_end_date DATE,
    name TEXT,
    price FLOAT
);

/* Contains the owns relationship to enforce key and total participation on credit cards */
CREATE TABLE Credit_cards (
    number INTEGER PRIMARY KEY,
    CVV INTEGER,
    expiry_date DATE,
    cust_id INTEGER NOT NULL REFERENCES Customers ON DELETE CASCADE, /* will require triggers to enforce total participation on customers*/
    from_date DATE DEFAULT CURRENT_DATE
);

CREATE TABLE Courses (
    course_id INTEGER PRIMARY KEY,
    duration FLOAT,
    description TEXT,
    title TEXT,
    name TEXT NOT NULL REFERENCES Course_areas
)

/* dk why is seating_capacity here tbh */
CREATE TABLE Offerings (
    course_id INTEGER REFERENCES Courses ON DELETE CASCADE,
    launch_date DATE,
    end_date DATE,
    start_date DATE,
    registration_deadline DATE,
    target_number_registrations INTEGER,
    seating_capacity INTEGER,
    fees FLOAT,
    eid INTEGER NOT NULL REFERENCES Administrators,
    PRIMARY KEY (course_id, launch_date)
);

CREATE TABLE Sessions (
    course_id INTEGER,
    launch_date DATE,
    sid INTEGER,
    date DATE,
    start_time TIME,
    end_time TIME,
    rid INTEGER NOT NULL REFERENCES Rooms ON DELETE CASCADE,
    FOREIGN KEY (course_id, launch_date) REFERENCES Offerings
    ON DELETE CASCADE,
    PRIMARY KEY (course_id, launch_date, sid) 
);
 --<----------------------- company side ----------------------->
CREATE TABLE Employees (
    eid INTEGER PRIMARY KEY,
    name TEXT,
    phone INTEGER,
    email TEXT,
    join_date DATE,
    address TEXT,
    depart_date DATE
);

CREATE TABLE Part_time_emp (
    eid INTEGER PRIMARY KEY REFERENCES Employees ON DELETE CASCADE,
    hourly_rate FLOAT
)

CREATE TABLE Full_time_emp (
    eid INTEGER PRIMARY KEY REFERENCES Employees ON DELETE CASCADE,
    monthly_salary FLOAT
)

CREATE TABLE Instructors (
    eid INTEGER PRIMARY KEY REFERENCES Employees ON DELETE CASCADE
)

CREATE TABLE Part_time_instructors (
    eid INTEGER PRIMARY KEY REFERENCES Part_time_emp REFERENCES Full_time_emp 
    ON DELETE CASCADE
)

CREATE TABLE Full_time_instructors (
    eid INTEGER PRIMARY KEY REFERENCES Instructors REFERENCES Full_time_emp 
    ON DELETE CASCADE
)

CREATE TABLE Administrators (
    eid INTEGER PRIMARY KEY REFERENCES Full_time_emp ON DELETE CASCADE
)

CREATE TABLE Managers (
    eid INTEGER PRIMARY KEY REFERENCES Full_time_emp ON DELETE CASCADE
)

CREATE TABLE Pay_slips (
    eid INTEGER REFERENCES Employees ON DELETE CASCADE,
    payment_date DATE,
    amount FLOAT,
    num_work_hours INTEGER,
    num_work_days INTEGER
    PRIMARY KEY (eid, payment_date)
);



-- <----------------------associations----------------------->
CREATE TABLE Cancels (
    date DATE PRIMARY KEY,
    refund_amt INTEGER,
    package_credit INTEGER,
    cust_id INTEGER REFERENCES Customers ON DELETE NO ACTION,
    course_id INTEGER,
    launch_date DATE,
    sid INTEGER,
    FOREIGN KEY (course_id, launch_date, sid) REFERENCES Sessions ON DELETE SET NULL, /* for book keeping purposes */
    PRIMARY KEY (cust_id, course_id, launch_date, sid, rid)
);

/* Package might not be offered but customer should be able to finish their remaining redemptions*/
CREATE TABLE Buys (
    package_id INTEGER REFERENCES Course_packages ON DELETE SET NULL, 
    number INTEGER REFERENCES Credit_card ON DELETE CASCADE,
    b_date DATE,
    num_remaining_redemptions INTEGER,
    PRIMARY KEY (package_id, number, date)
);

/* Requires triggers to enforce that each customer can register for at most one sesion of a course */
CREATE TABLE Registers (
    number INTEGER REFERENCES Credit_cards ON DELETE CASCADE,
    course_id INTEGER,
    launch_date DATE,
    sid INTEGER,
    date DATE,
    FOREIGN KEY (course_id, launch_date, sid) REFERENCES Sessions ON DELETE NO ACTION, 
    PRIMARY KEY (course_id, launch_date, sid, number, date)
);

CREATE TABLE  Specializes (
    eid INTEGER REFERENCES Instructors, /*total participation*/
    name TEXT REFERENCES Course_areas,
    PRIMARY KEY (eid, name)
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
    FOREIGN KEY (course_id, launch_date, sid) REFERENCES Sessions ON DELETE NO ACTION,
    PRIMARY KEY (package_id, number, b_date, course_id, launch_date, sid, r_date)
);

CREATE TABLE Conducts (
    rid INTEGER REFERENCES Rooms,
    eid INTEGER REFERENCES Instructors,
    course_id INTEGER,
    launch_date DATE,
    sid INTEGER,
    FOREIGN KEY (course_id, launch_date, sid) REFERENCES Sessions,
    PRIMARY KEY (rid, eid, course_id, launch_date, sid)
)
