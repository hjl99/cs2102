DELETE FROM Redeems;
DELETE FROM Registers;
DELETE FROM Cancels;
DELETE FROM Sessions;
DELETE FROM Offerings;
DELETE FROM Rooms;
DELETE FROM Specializes;
DELETE FROM Offerings;
DELETE FROM Courses;
DELETE FROM Course_areas;
DELETE FROM Managers;
DELETE FROM Administrators;
DELETE FROM Part_time_instructors;
DELETE FROM Full_time_instructors;
DELETE FROM Instructors;
DELETE FROM Part_time_emp;
DELETE FROM Full_time_emp;
DELETE FROM Buys;
DELETE FROM Credit_cards;
DELETE FROM Customers;
DELETE FROM Pay_slips;
DELETE FROM Employees;
DELETE FROM Course_packages;
-- RESETS serial number
TRUNCATE Customers RESTART IDENTITY CASCADE;
TRUNCATE Employees RESTART IDENTITY CASCADE;
TRUNCATE Courses RESTART IDENTITY CASCADE;
TRUNCATE Offerings RESTART IDENTITY CASCADE;
TRUNCATE Course_packages RESTART IDENTITY CASCADE;
TRUNCATE Rooms RESTART IDENTITY CASCADE;

CALL add_customer('Customer_01', 'caddress 1', 00000001, 'c1@mail.com', 12345678234231209, '2023-01-01', 123);
CALL add_customer('Customer_02', 'caddress 2', 00000002, 'c2@mail.com', 98420312340987434, '2023-05-01', 456);
CALL add_customer('Customer_03', 'caddress 3', 00000003, 'c3@mail.com', 87429845720984534, '2025-09-08', 436);
CALL add_customer('Customer_04', 'caddress 4', 00000004, 'c4@mail.com', 87428943002375534, '2025-06-21', 785);
CALL add_customer('Customer_05', 'caddress 5', 00000005, 'c5@mail.com', 78932034950184575, '2021-09-30', 890);
CALL add_customer('Customer_06', 'caddress 6', 00000006, 'c6@mail.com', 89888201283256534, '2024-05-07', 430);
CALL add_customer('Customer_07', 'caddress 7', 00000007, 'c7@mail.com', 52381238752784534, '2023-09-08', 196);
CALL add_customer('Customer_08', 'caddress 8', 00000008, 'c8@mail.com', 09827350877734581, '2022-08-18', 672);
CALL add_customer('Customer_09', 'caddress 9', 00000009, 'c9@mail.com', 56783297340984534, '2022-04-01', 013);
CALL add_customer('Customer_10', 'caddress 10', 00000010, 'c10@mail.com', 98723401293812234, '2025-09-08', 806);


-- Managers (indexed 1-10)
CALL add_employee('Manager_01', 'maddress 1', 10000001, 'm1@mail.com', 15000, '2020-08-31', 'manager', ARRAY['CS']);
CALL add_employee('Manager_02', 'maddress 2', 10000002, 'm2@mail.com', 5000, '2020-11-31', 'manager', ARRAY['Science']);
CALL add_employee('Manager_03', 'maddress 3', 10000003, 'm3@mail.com', 6000, '2021-01-01', 'manager', ARRAY['Medicine']);
CALL add_employee('Manager_04', 'maddress 4', 10000004, 'm4@mail.com', 8000, '2021-04-30', 'manager', ARRAY['Mathematics']);
CALL add_employee('Manager_05', 'maddress 5', 10000005, 'm5@mail.com', 6000, '2008-05-24', 'manager', ARRAY['Economics']);
CALL add_employee('Manager_06', 'maddress 6', 10000006, 'm6@mail.com', 6000, '2000-03-04', 'manager', ARRAY['Business']);
CALL add_employee('Manager_07', 'maddress 7', 10000007, 'm7@mail.com', 10000, '1996-09-21', 'manager', ARRAY['Engineering']);
CALL add_employee('Manager_08', 'maddress 8', 10000008, 'm8@mail.com', 7000, '2016-04-30', 'manager', ARRAY['Architecture']);
CALL add_employee('Manager_09', 'maddress 9', 10000009, 'm9@mail.com', 12000, '1985-08-16', 'manager', ARRAY['Law']);
CALL add_employee('Manager_10', 'maddress 10', 10000010, 'm10@mail.com', 9500, '2001-09-11', 'manager', ARRAY['Politics']);

-- Part time instructors (indexed 2-20)
CALL add_employee('Part_time_instructor_01', 'ptiaddress 1', 20000001, 'pti1@mail.com', 80, '2021-01-01', 'part time instructor', ARRAY ['CS']);
CALL add_employee('Part_time_instructor_02', 'ptiaddress 2', 20000002, 'pti2@mail.com', 80, '2021-03-15', 'part time instructor', ARRAY ['CS', 'Science']);
CALL add_employee('Part_time_instructor_03', 'ptiaddress 3', 20000003, 'pti3@mail.com', 80, '2019-06-25', 'part time instructor', ARRAY ['Medicine', 'Science']);
CALL add_employee('Part_time_instructor_04', 'ptiaddress 4', 20000004, 'pti4@mail.com', 80, '2020-07-28', 'part time instructor', ARRAY ['Mathematics', 'CS']);
CALL add_employee('Part_time_instructor_05', 'ptiaddress 5', 20000005, 'pti5@mail.com', 80, '2018-06-13', 'part time instructor', ARRAY ['Law', 'Economics']);
CALL add_employee('Part_time_instructor_06', 'ptiaddress 6', 20000006, 'pti6@mail.com', 80, '2013-07-23', 'part time instructor', ARRAY ['Economics']);
CALL add_employee('Part_time_instructor_07', 'ptiaddress 7', 20000007, 'pti7@mail.com', 80, '2020-11-13', 'part time instructor', ARRAY ['CS']);
CALL add_employee('Part_time_instructor_08', 'ptiaddress 8', 20000008, 'pti8@mail.com', 80, '2019-10-08', 'part time instructor', ARRAY ['Business', 'Politics']);
CALL add_employee('Part_time_instructor_09', 'ptiaddress 9', 20000009, 'pti9@mail.com', 80, '2018-05-23', 'part time instructor', ARRAY ['Architecture']);
CALL add_employee('Part_time_instructor_10', 'ptiaddress 10', 20000010, 'pti10@mail.com', 80, '2017-12-25', 'part time instructor', ARRAY ['Politics']);

-- Full time instructors (indexed 3-30)
CALL add_employee('Full_time_instructor_01', 'ftiaddress 1', 30000001, 'fti1@mail.com', 2000, '2021-01-01', 'full time instructor', ARRAY ['CS']);
CALL add_employee('Full_time_instructor_02', 'ftiaddress 2', 30000002, 'fti2@mail.com', 2000, '2021-02-01', 'full time instructor', ARRAY ['Science']);
CALL add_employee('Full_time_instructor_03', 'ftiaddress 3', 30000003, 'fti3@mail.com', 3500, '2020-03-14', 'full time instructor', ARRAY ['Medicine', 'Science']);
CALL add_employee('Full_time_instructor_04', 'ftiaddress 4', 30000004, 'fti4@mail.com', 4400, '2018-08-26', 'full time instructor', ARRAY ['Mathematics', 'Science']);
CALL add_employee('Full_time_instructor_05', 'ftiaddress 5', 30000005, 'fti5@mail.com', 3800, '2014-06-11', 'full time instructor', ARRAY ['Business', 'Economics']);
CALL add_employee('Full_time_instructor_06', 'ftiaddress 6', 30000006, 'fti6@mail.com', 5000, '2009-04-17', 'full time instructor', ARRAY ['Politics']);
CALL add_employee('Full_time_instructor_07', 'ftiaddress 7', 30000007, 'fti7@mail.com', 4500, '2020-07-24', 'full time instructor', ARRAY ['Medicine']);
CALL add_employee('Full_time_instructor_08', 'ftiaddress 8', 30000008, 'fti8@mail.com', 2900, '2020-03-14', 'full time instructor', ARRAY ['Architecture']);
CALL add_employee('Full_time_instructor_09', 'ftiaddress 9', 30000009, 'fti9@mail.com', 3500, '2020-04-24', 'full time instructor', ARRAY ['CS', 'Mathematics']);
CALL add_employee('Full_time_instructor_10', 'ftiaddress 10', 30000010, 'fti10@mail.com', 4500, '2019-09-26', 'full time instructor', ARRAY ['Economics', 'Law']);

-- Administrators (indexed 4-40)
CALL add_employee('Administrator_01', 'aaddress 1', 40000001, 'a1@mail.com', 2000, '2021-01-01', 'administrator');
CALL add_employee('Administrator_02', 'aaddress 2', 40000002, 'a2@mail.com', 2500, '2021-01-01', 'administrator');
CALL add_employee('Administrator_03', 'aaddress 3', 40000003, 'a3@mail.com', 3000, '2020-08-01', 'administrator');
CALL add_employee('Administrator_04', 'aaddress 4', 40000004, 'a4@mail.com', 3000, '2019-02-13', 'administrator');
CALL add_employee('Administrator_05', 'aaddress 5', 40000005, 'a5@mail.com', 2800, '2016-02-28', 'administrator');
CALL add_employee('Administrator_06', 'aaddress 6', 40000006, 'a6@mail.com', 3700, '2020-07-23', 'administrator');
CALL add_employee('Administrator_07', 'aaddress 7', 40000007, 'a7@mail.com', 3200, '2020-11-13', 'administrator');
CALL add_employee('Administrator_08', 'aaddress 8', 40000008, 'a8@mail.com', 3000, '2019-02-13', 'administrator');
CALL add_employee('Administrator_09', 'aaddress 9', 40000009, 'a9@mail.com', 2950, '2019-10-19', 'administrator');
CALL add_employee('Administrator_10', 'aaddress 10', 40000010, 'a10@mail.com', 3200, '2019-02-13', 'administrator');

-- Courses
CALL add_course('CS1000', 'Intro to CS', 'CS', 1);
CALL add_course('CS2000', 'CS level 2', 'CS', 2);
CALL add_course('CS3000', 'CS level 3', 'CS', 2);
CALL add_course('CS4000', 'CS level 4', 'CS', 3);
CALL add_course('CS5000', 'CS level 5', 'CS', 3);
CALL add_course('MD1000', 'Intro to Medicine', 'Medicine', 2);
CALL add_course('MD2000', 'Medicine level 2', 'Medicine', 2);
CALL add_course('MD3000', 'Medicine level 3', 'Medicine', 3);
CALL add_course('MD4000', 'Medicine level 4', 'Medicine', 3);
CALL add_course('MD5000', 'Medicine level 5', 'Medicine', 4);

-- Rooms
INSERT INTO Rooms(location, seating_capacity) VALUES ('SOC', 10);
INSERT INTO Rooms(location, seating_capacity) VALUES ('SOC', 20);
INSERT INTO Rooms(location, seating_capacity) VALUES ('SOC', 50);
INSERT INTO Rooms(location, seating_capacity) VALUES ('SOC', 50);
INSERT INTO Rooms(location, seating_capacity) VALUES ('MD', 20);
INSERT INTO Rooms(location, seating_capacity) VALUES ('MD', 50);
INSERT INTO Rooms(location, seating_capacity) VALUES ('MD', 30);
INSERT INTO Rooms(location, seating_capacity) VALUES ('BIZ', 80);
INSERT INTO Rooms(location, seating_capacity) VALUES ('BIZ', 30);
INSERT INTO Rooms(location, seating_capacity) VALUES ('ENGIN', 60);
INSERT INTO Rooms(location, seating_capacity) VALUES ('ENGIN', 40);

-- this procedure will trigger the each course offering must have one or more sessions trigger
CALL add_course_offering(1, 100::FLOAT, '2021-05-01'::DATE, '2021-04-20'::DATE, 10, 4, VARIADIC ARRAY[('2021-05-01', '08:00', 1), ('2021-05-03', '13:00', 1)]::Session[]);