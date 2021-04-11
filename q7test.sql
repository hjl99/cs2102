-- Adding a manager
CALL add_employee('M1', 'maddress 1', 10000001, 'm1@mail.com', 15000, '2020-08-31', 'manager', ARRAY['A1']);

-- Adding an instructor
CALL add_employee('Pti1', 'ptiaddress 1', 20000001, 'pti1@mail.com', 80, '2021-01-01', 'part time instructor', ARRAY ['A1']);
CALL add_employee('Fti1', 'ftiaddress 1', 30000001, 'fti1@mail.com', 2000, '2021-01-01', 'full time instructor', ARRAY ['A1']);

-- Adding an administrator
CALL add_employee('A1', 'aaddress 1', 40000001, 'a1@mail.com', 2000, '2021-01-01', 'administrator');

-- Adding courses
CALL add_course('C11', 'C11', 'A1', 1);

-- Adding rooms
INSERT INTO Rooms(location, seating_capacity) VALUES ('A1', 3);

-- Correct cases :
-- No assignment for every instructor
SELECT get_available_instructors(1, '2021-05-03', '2021-05-05');

-- Adding offerings
-- Assign some session to the instructor
CALL add_course_offering(1, 100, '2021-04-01', '2021-04-20', 3, 4, VARIADIC ARRAY[('2021-05-03', '09:00', 1), ('2021-05-03', '15:00', 1)]::Session[]);

-- Correct case :
-- First instructor is assigned to two sessions that starts at 09:00 and 15:00
SELECT get_available_instructors(1, '2021-05-03', '2021-05-03');