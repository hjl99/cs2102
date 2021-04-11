-- Adding a manager
CALL add_employee('M1', 'maddress 1', 10000001, 'm1@mail.com', 15000, '2020-08-31', 'manager', ARRAY['A1']);

-- Adding an instructor
CALL add_employee('Pti1', 'ptiaddress 1', 20000001, 'pti1@mail.com', 80, '2021-01-01', 'part time instructor', ARRAY ['A1']);

-- Adding an administrator
CALL add_employee('A1', 'aaddress 1', 40000001, 'a1@mail.com', 2000, '2021-01-01', 'administrator');

-- Adding courses
CALL add_course('C11', 'C11', 'A1', 1);
CALL add_course('C12', 'C12', 'A1', 3);
CALL add_course('C13', 'C13', 'A1', 4);

-- Correct cases :
-- The instructor can be assigned
SELECT find_instructors(1, '2021-05-03', '09:00');

-- Adding rooms
INSERT INTO Rooms(location, seating_capacity) VALUES ('A1', 3);

-- Add course offerings
CALL add_course_offering(1, 100, '2021-04-01', '2021-04-20', 3, 3, VARIADIC ARRAY[('2021-05-03', '09:00', 1)]::Session[]);

-- Correct case :
-- Returned an empty table (Instructor cannot be assigned to consecutive sessions)
SELECT find_instructors(1, '2021-05-03', '10:00');
-- Returned the instructor (One hour interval)
SELECT find_instructors(1, '2021-05-03', '11:00');

-- Add course offerings
CALL add_course_offering(2, 100, '2021-04-01', '2021-04-20', 3, 3, 
VARIADIC ARRAY[('2021-05-04', '09:00', 1), ('2021-05-05', '09:00', 1), ('2021-05-06', '09:00', 1), ('2021-05-07', '09:00', 1)]::Session[]);
CALL add_course_offering(3, 100, '2021-04-01', '2021-04-20', 3, 3, 
VARIADIC ARRAY[('2021-05-04', '14:00', 1), ('2021-05-05', '14:00', 1), ('2021-05-06', '14:00', 1), ('2021-05-07', '14:00', 1)]::Session[]);

-- Correct case :
-- Returned an empty table (Part time instructor cannot be teaching more than 30 hours in a month)
SELECT find_instructors(2, '2021-05-10', '09:00');