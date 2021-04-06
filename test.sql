/* Sample valid data */

/* All dates start from this month and increment accordingly. If an 'expired' date is needed
it's march*/
/* one-indexed. Rid increments by 1, Locations are a single capital letter increment by 1, 
seating capacity == rid*/
DELETE FROM Redeems;
DELETE FROM Registers;
DELETE FROM Sessions;
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
DELETE FROM Credit_cards;
DELETE FROM Customers;
DELETE FROM Employees;
DELETE FROM Course_packages;
-- RESETS serial number
TRUNCATE Customers RESTART IDENTITY CASCADE;
TRUNCATE Employees RESTART IDENTITY CASCADE;
TRUNCATE Courses RESTART IDENTITY CASCADE;
TRUNCATE Offerings RESTART IDENTITY CASCADE;
TRUNCATE Course_packages RESTART IDENTITY CASCADE;
insert into Rooms(rid, location, seating_capacity) values (1,'A', 1);
insert into Rooms values (2,'room_B', 2);
insert into Rooms values (3,'room_C', 3);
insert into Rooms values (4,'room_D', 4);
insert into Rooms values (5,'room_E', 5);
insert into Rooms values (6,'room_F', 6);
insert into Rooms values (7,'room_G', 7);
insert into Rooms values (8,'room_H', 8);
/* add course areas and its employee. name prefixed with pti, fti, m or a.*/
CALL add_employee('m_A', 'addr_A', 10000000, 'A@A.com', 100.0, '2021-04-01', 'manager', '{"course_area_A"}');
CALL add_employee('m_B', 'addr_B', 20000000, 'B@B.com', 200.0, '2021-04-02', 'manager', '{"course_area_B"}');
CALL add_employee('m_C', 'addr_C', 30000000, 'C@C.com', 300.0, '2021-04-03', 'manager', '{"course_area_C"}');
CALL add_employee('pti_A', 'addr_A', 10000000, 'A@A.com', 1.0, '2021-04-01', 'part time instructor', '{"course_area_A"}');
CALL add_employee('pti_B', 'addr_B', 20000000, 'B@B.com', 2.0, '2021-04-02', 'part time instructor', '{"course_area_B"}');
CALL add_employee('pti_C', 'addr_C', 30000000, 'C@C.com', 3.0, '2021-04-03', 'part time instructor', '{"course_area_C"}');
CALL add_employee('fti_A', 'addr_A', 10000000, 'A@A.com', 100, '2021-04-01', 'full time instructor', '{"course_area_A"}');
CALL add_employee('fti_B', 'addr_B', 20000000, 'B@B.com', 200, '2021-04-02', 'full time instructor', '{"course_area_B"}');
CALL add_employee('fti_C', 'addr_C', 30000000, 'C@C.com', 300, '2021-04-03', 'full time instructor', '{"course_area_C"}');
CALL add_employee('a_A', 'addr_A', 10000000, 'A@A.com', 100, '2021-04-01', 'administrator', '{}');
CALL add_employee('a_B', 'addr_B', 20000000, 'B@B.com', 200, '2021-04-02', 'administrator', '{}');
CALL add_employee('a_C', 'addr_C', 30000000, 'C@C.com', 300, '2021-04-03', 'administrator', '{}');

CALL add_customer('c_A', 'addr_A', 10000000, 'A@A.com', 1, '2021-04-30', 1);
CALL add_customer('c_B', 'addr_B', 20000000, 'B@B.com', 20, '2021-04-03', 20);
CALL add_customer('c_C', 'addr_C', 30000000, 'C@C.com', 3, '2021-04-30', 3);
CALL add_customer('c_D', 'addr_D', 20000000, 'D@D.com', 4, '2021-04-30', 4);
CALL add_customer('c_E', 'addr_E', 30000000, 'E@E.com', 5, '2021-04-30', 5);

CALL update_credit_card(2, 2, '2021-04-30', 2);

CALL add_course_packages('package_A', 1, '2021-04-01', '2021-04-30', 1.0);

CALL add_course('course_A1', 'course_A1', 'course_area_A',1);
CALL add_course('course_A2', 'course_A2', 'course_area_A',2);

CALL add_course_offering(1,1.0,'2021-03-01','2021-03-01', 2, 10, 
 ('2021-04-01', '09:00:00', 1, 4), ('2021-04-02', '10:00:00', 2, 7));    



CALL register_session(1, 1, '2021-03-01', 1, 'redemption');
-- insert into Course_areas VALUES ('area managed by 9', 9);
-- insert into Courses VALUES (10, 13, 'test', 'title 10', 'area managed by 9');
-- insert into Offerings VALUES (10, 10, '2021-02-01', '2021-02-15', NULL, '2021-02-15', 100,100, 100,10);
-- CALL add_session(10, 1, '2021-02-13', '20:00:00', 11, 1);
-- insert INTO Employees VALUES (20), (21), (22);
-- insert into Instructors VALUES (20), (21), (22);
-- CALL add_session(10, 1, '2021-04-01',
--                     '10:00', 20, 1);
-- CALL add_session(10, 1, '2021-04-01',
--                     '10:00', 21, 1);
-- CALL add_session(10, 2, '2021-04-01',
--                     '15:00', 20, 1);
-- insert into Pay_slips VALUES (10,'2021-04-30', 2000, 3, 0);
-- insert into Pay_slips VALUES (20,'2021-04-30', 2000, 3, 0);
-- insert into Pay_slips VALUES (21,'2021-04-30', 4000, 2, 0);
-- insert into Specializes VALUES (20, 'area managed by 9');
-- insert into Specializes VALUES (21, 'area managed by 9');
-- SELECT add_customer('a', 'addr',123,'email', 123345,'2022-04-01',123);
-- insert into Registers VALUES (123345, 10, '2021-02-01', 1, '2021-03-01', 1, 20);