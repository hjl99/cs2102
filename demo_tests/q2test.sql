-- Adding employees
CALL add_employee('M1', 'maddress 1', 10000001, 'm1@mail.com', 15000, '2020-08-31', 'manager', ARRAY['A1']);
CALL add_employee('Pti1', 'ptiaddress 1', 20000001, 'pti1@mail.com', 80, '2021-01-01', 'part time instructor', ARRAY ['A1']);
CALL add_employee('Fti1', 'ftiaddress 1', 30000001, 'fti1@mail.com', 2000, '2021-01-01', 'full time instructor', ARRAY ['A1']);
CALL add_employee('A1', 'aaddress 1', 40000001, 'a1@mail.com', 2000, '2021-01-01', 'administrator');
CALL add_employee('Manager_remove', 'maddress 1', 10000001, 'm1@mail.com', 15000, '2020-08-31', 'manager', ARRAY['TBD']);
CALL add_employee('Part_time_instructor_remove', 'ptiaddress 1', 20000001, 'pti1@mail.com', 80, '2021-01-01', 'part time instructor', ARRAY ['A1']);
CALL add_employee('Full_time_instructor_remove', 'ftiaddress 1', 30000001, 'fti1@mail.com', 2000, '2021-01-01', 'full time instructor', ARRAY ['A1']);
CALL add_employee('Administrator_remove', 'aaddress 1', 40000001, 'a1@mail.com', 2000, '2021-01-01', 'administrator');

UPDATE Course_areas SET eid = 1 WHERE course_area_name = 'TBD';

-- Correct cases :
CALL remove_employee(5, '2021-05-01');
CALL remove_employee(6, '2021-05-01');
CALL remove_employee(7, '2021-05-01');
CALL remove_employee(8, '2021-05-01');
CALL remove_employee(2, '2021-05-01');

-- Adding courses
CALL add_course('C11', 'C11', 'A1', 1);
CALL add_course('C12', 'C12', 'A1', 2);

-- Adding rooms
INSERT INTO Rooms(location, seating_capacity) VALUES ('A1', 3);

-- Adding course offerings
CALL add_course_offering(1, 100, '2021-04-10', '2021-04-20', 3, 4, VARIADIC ARRAY[('2021-05-03', '09:00', 1)]::Session[]);

-- Fail cases :
-- Administrator handling some course offering
CALL remove_employee(4, '2021-04-19');

-- Instructor is teaching some session that starts after his depart date
CALL remove_employee(3, '2021-04-30');

-- Manager is managing some area
CALL remove_employee(1, '2021-04-30');