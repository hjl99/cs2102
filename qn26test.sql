-- RESETS serial number
TRUNCATE Customers RESTART IDENTITY CASCADE;
TRUNCATE Employees RESTART IDENTITY CASCADE;
TRUNCATE Courses RESTART IDENTITY CASCADE;
TRUNCATE Offerings RESTART IDENTITY CASCADE;
TRUNCATE Course_packages RESTART IDENTITY CASCADE;
TRUNCATE Rooms RESTART IDENTITY CASCADE;
INSERT INTO Rooms(location, seating_capacity) VALUES ('SOC', 10);
INSERT INTO Rooms(location, seating_capacity) VALUES ('SOC', 20);
CALL add_employee('Manager_01', 'maddress 1', 10000001, 'm1@mail.com', 15000, '2020-08-31', 'manager', ARRAY['CS']);
CALL add_employee('Full_time_instructor_01', 'ftiaddress 1', 30000001, 'fti1@mail.com', 2000, '2021-01-01', 'full time instructor', ARRAY ['CS']);
CALL add_employee('Administrator_01', 'aaddress 1', 40000001, 'a1@mail.com', 2000, '2021-01-01', 'administrator');

CALL add_course('CS1000', 'CS level 1', 'CS', 1);
CALL add_course('CS2000', 'CS level 2', 'CS', 2);
CALL add_course_packages('Package 1', 3, '2020-04-05', '2021-04-30', 199);

-- old course offerings
CALL add_course_offering(1, 100, '2020-05-01', '2021-05-20', 10, 3,
 VARIADIC ARRAY[('2021-06-01', '09:00', 1), ('2021-06-02', '15:00', 1)]::Session[]);
CALL add_course_offering(1, 100, '2020-05-02', '2021-05-21', 10, 3, 
VARIADIC ARRAY[('2021-06-01', '15:00', 2)]::Session[]);

-- new course offerings
CALL add_course_offering(2, 100, '2021-05-01', '2021-05-20', 10, 3,
 VARIADIC ARRAY[('2021-06-03', '09:00', 1), ('2021-06-07', '15:00', 1)]::Session[]);
CALL add_course_offering(2, 100, '2021-05-02', '2021-05-21', 10, 3, 
VARIADIC ARRAY[('2021-06-04', '15:00', 2)]::Session[]);

-- active customer with 1 new course offering and 1 old offering
CALL add_customer('Customer_01', 'caddress 1', 00000001, 'c1@mail.com', 12345678234231201, '2023-01-01', 123);
CALL buy_course_package(1, 1);
CALL register_session(1, 2, '2021-05-01', 1, 'redemption');
CALL register_session26(1, 1, '2020-05-01', 1, 'payment');

-- non active customers with 2 old offerings
CALL add_customer('Customer_02', 'caddress 1', 00000001, 'c1@mail.com', 12345678234231202, '2023-01-01', 123);
CALL buy_course_package(2, 1);
CALL register_session26(2, 1, '2020-05-01', 1, 'payment');
CALL register_session26(2, 1, '2020-05-02', 1, 'payment');

CALL add_customer('Customer_03', 'caddress 1', 00000001, 'c1@mail.com', 12345678234231203, '2023-01-01', 123);
CALL register_session26(3, 1, '2020-05-01', 1, 'payment');
CALL register_session26(3, 1, '2020-05-02', 1, 'payment');

-- active customer with 2 new offerings
CALL add_customer('Customer_04', 'caddress 1', 00000001, 'c1@mail.com', 12345678234231204, '2023-01-01', 123);
CALL register_session(4, 2, '2021-05-01', 1, 'payment');
CALL register_session(4, 2, '2021-05-02', 1, 'payment');


-- expected: 
SELECT * FROM promote_courses();

