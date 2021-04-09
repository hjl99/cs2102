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

CALL add_employee('Manager_01', 'maddress 1', 10000001, 'm1@mail.com', 5000, '2020-08-31', 'manager', ARRAY ['CS']);
CALL add_employee('Part_time_instructor_01', 'ptiaddress 1', 10000002, 'pti1@mail.com', 40, '2021-01-01', 'part time instructor', ARRAY ['CS']);
CALL add_employee('Full_time_instructor_01', 'ftiaddress 1', 10000003, 'fti1@mail.com', 2000, '2021-01-01', 'full time instructor', ARRAY ['CS']);
CALL add_employee('Administrator_01', 'aaddress 1', 10000004, 'a1@mail.com', 2000, '2021-01-01', 'administrator');

CALL add_course('CS1000', 'Introduction to CS', 'CS', 2);

INSERT INTO Rooms(location, seating_capacity) VALUES ('SOC', 20);

-- this procedure will trigger the each course offering must have one or more sessions trigger
CALL add_course_offering(1, 100::FLOAT, '2021-05-01'::DATE, '2021-04-20'::DATE, 10, 4, VARIADIC ARRAY[('2021-05-01', '08:00', 1), ('2021-05-03', '13:00', 1)]::Session[]);