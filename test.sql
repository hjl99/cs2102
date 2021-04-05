/* Sample valid data */
/* one-indexed. Rid increments by 1, Locations are a single capital letter increment by 1, 
seating capacity == rid*/
insert into Rooms(rid, location, seating_capacity) values (1,'A', 1);
insert into Rooms values (2,'room_B', 2);
insert into Rooms values (3,'room_C', 3);
insert into Rooms values (4,'room_D', 4);
insert into Rooms values (5,'room_E', 5);
insert into Rooms values (6,'room_F', 6);
insert into Rooms values (7,'room_G', 7);
insert into Rooms values (8,'room_H', 8);



-- insert INTO Employees VALUES (9), (10), (11);
-- insert into Instructors VALUES (11);
-- insert into Full_time_emp VALUES (9), (10);
-- insert into Administrators VALUES (10);
-- insert into Managers VALUES (9);
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