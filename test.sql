/* Sample valid data */

/* All dates start from this month and increment accordingly. If an 'expired' date is needed
it's march*/
/* one-indexed. Rid increments by 1, Locations are a single capital letter increment by 1, 
seating capacity == rid*/
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

/* add course areas and the employees specialised in it.
(name TEXT, address TEXT, phone INTEGER, email TEXT, 
             salary_or_hourly_rate FLOAT, join_date DATE, category TEXT, 
             course_areas)
*/
CALL add_employee('m_A', 'addr_A', 10000000, 'A@A.com', 100.0, '2021-04-01', 'manager', '{"course_area_A"}');
CALL add_employee('m_B', 'addr_B', 20000000, 'B@B.com', 200.0, '2021-04-02', 'manager', '{"course_area_B"}');
CALL add_employee('m_C', 'addr_C', 30000000, 'C@C.com', 300.0, '2021-04-03', 'manager', '{"course_area_C"}');
CALL add_employee('m_D', 'addr_D', 30000000, 'D@D.com', 300.0, '2021-04-03', 'manager', '{"course_area_qn10"}');
CALL add_employee('pti_A', 'addr_A', 10000000, 'A@A.com', 1.0, '2021-04-01', 'part time instructor', '{"course_area_A"}');
CALL add_employee('pti_B', 'addr_B', 20000000, 'B@B.com', 2.0, '2021-04-02', 'part time instructor', '{"course_area_B"}');
CALL add_employee('pti_C', 'addr_C', 30000000, 'C@C.com', 3.0, '2021-04-03', 'part time instructor', '{"course_area_C"}');
CALL add_employee('pti_D', 'addr_D', 10000000, 'D@D.com', 1.0, '2021-04-01', 'part time instructor', '{"course_area_qn10"}');
CALL add_employee('pti_D2', 'addr_D2', 10000000, 'D2@D.com', 1.0, '2021-04-01', 'part time instructor', '{"course_area_qn10"}');
CALL add_employee('fti_A', 'addr_A', 10000000, 'A@A.com', 100, '2021-04-01', 'full time instructor', '{"course_area_A"}');
--10
CALL add_employee('fti_B', 'addr_B', 20000000, 'B@B.com', 200, '2021-04-02', 'full time instructor', '{"course_area_B"}');
CALL add_employee('fti_C', 'addr_C', 30000000, 'C@C.com', 300, '2021-04-03', 'full time instructor', '{"course_area_C"}');
CALL add_employee('a_A', 'addr_A', 10000000, 'A@A.com', 100, '2021-04-01', 'administrator', '{}');
CALL add_employee('a_B', 'addr_B', 20000000, 'B@B.com', 200, '2021-04-02', 'administrator', '{}');
CALL add_employee('a_C', 'addr_C', 30000000, 'C@C.com', 300, '2021-04-03', 'administrator', '{}');
CALL add_employee('a_C', 'addr_C', 30000000, 'C@C.com', 300, '2021-04-03', 'administrator', '{}');

/* function 4 (cname TEXT, caddress TEXT, cphone INTEGER,
                        cemail TEXT, cnumber INTEGER, cexpiry_date DATE, ccvv INTEGER) */
CALL add_customer('c_A', 'addr_A', 10000000, 'A@A.com', 1, '2021-04-30', 1);
CALL add_customer('c_B', 'addr_B', 20000000, 'B@B.com', 20, '2021-04-03', 20);
CALL add_customer('c_C', 'addr_C', 30000000, 'C@C.com', 3, '2021-04-30', 3);
CALL add_customer('c_D', 'addr_D', 20000000, 'D@D.com', 4, '2021-04-30', 4);
CALL add_customer('c_E', 'addr_E', 30000000, 'E@E.com', 5, '2021-04-30', 5);
CALL add_customer('Yovonnda Tansley', '53 Clarendon Center', 3242191859, 'ytansley0@a8.net', 344267768685828, '2021-04-27', 1);
CALL add_customer('Jeromy Pheby', '70 Service Center', 7855504927, 'jpheby1@wp.com', 5602229854693161302, '2021-04-19', 2);
CALL add_customer('Joye Ruhben', '1 John Wall Drive', 6088271635, 'jruhben2@ning.com', 3547422918201252, '2021-04-28', 3);
CALL add_customer('Ardith Devitt', '9 Summerview Terrace', 5127410507, 'adevitt3@delicious.com', 3569438402279243, '2021-04-25', 4);
CALL add_customer('Florie Taveriner', '9 Hoard Plaza', 6069690410, 'ftaveriner4@whitehouse.gov', 5602239525272626, '2021-04-29', 5);
CALL add_customer('Brietta Geeves', '24536 Stone Corner Crossing', 5984087453, 'bgeeves5@baidu.com', 5018409688988259038, '2021-04-21', 6);
CALL add_customer('Berte Allchin', '6857 Acker Parkway', 222964574, 'ballchin6@theglobeandmail.com', 36415363588839, '2021-04-20', 7);
CALL add_customer('Irvin Rubery', null, null, 'irubery7@census.gov', 5602258766714886994, '2021-04-26', 8);
CALL add_customer('Tina Studart', '62 Pleasure Crossing', 6533937489, 'tstudart8@ucla.edu', 4026190542040895, '2021-04-23', 9);
CALL add_customer('Tedd Pask', '23 Northport Way', 027804309, 'tpask9@purevolume.com', 5602231888838036, '2021-04-21', 10);
CALL add_customer('Joleen McCudden', '11917 Hoepker Street', 4637454164, 'jmccuddena@sakura.ne.jp', 5602214444768042822, '2021-04-21', 11);
CALL add_customer('Eunice Harcus', '74 Riverside Avenue', 3306850956, 'eharcusb@bizjournals.com', 3556634209887452, '2021-04-20', 12);
CALL add_customer('Alene Cobello', '78 Ronald Regan Point', 5818818089, 'acobelloc@bizjournals.com', 3538964902455247, '2021-04-19', 13);
CALL add_customer('Codi Pinchback', '14 Lake View Alley', 2473123922, 'cpinchbackd@tripod.com', 3543908893407629, '2021-04-19', 14);
CALL add_customer('Zilvia Burk', '33 Anniversary Crossing', 3123391652, 'zburke@thetimes.co.uk', 4017956647721, '2021-04-27', 15);
CALL add_customer('Ned Ainger', '23485 Grover Junction', 3572863446, 'naingerf@illinois.edu', 20151700074512, '2021-04-26', 16);
CALL add_customer('Garrett MacEllen', '183 Mariners Cove Plaza', 3196643525, 'gmacelleng@simplemachines.org', 3532690287109259, '2021-04-27', 17);
CALL add_customer('Audre O'' Liddy', '36 Anniversary Lane', 3972558194, 'aoh@wunderground.com', 63338088312685266, '2021-04-26', 18);
CALL add_customer('Cathie Wikey', '3578 Hallows Street', 3722316457, 'cwikeyi@marketwatch.com', 3583113677867087, '2021-04-19', 19);
CALL add_customer('Debbie Rochell', '4 Lyons Pass', 3382313848, 'drochellj@opera.com', 3574355548880754, '2021-04-24', 20);
CALL add_customer('Ricki Alves', '1854 Brentwood Avenue', 5546007580, 'ralvesk@opensource.org', 337941444751662, '2021-04-28', 21);
CALL add_customer('Rochelle Runge', '4604 Pearson Alley', 3907221463, 'rrungel@elegantthemes.com', 5048376885624855, '2021-04-20', 22);
CALL add_customer('Sven Degoey', null, null, 'sdegoeym@storify.com', 3561042532205652, '2021-04-22', 23);
CALL add_customer('Reinhard Wollers', '530 Russell Trail', 902246212, 'rwollersn@about.com', 4436143781286, '2021-04-22', 24);
CALL add_customer('Sollie Wince', '48 Butterfield Terrace', 6768290297, 'swinceo@ucsd.edu', 5566571491798778, '2021-04-24', 25);
CALL add_customer('Jone Whyteman', '56 Larry Circle', 9871180216, 'jwhytemanp@joomla.org', 3531259960127458, '2021-04-25', 26);
CALL add_customer('Oswald Sprulls', '2965 Saint Paul Avenue', 3963069363, 'osprullsq@baidu.com', 5038665389599810445, '2021-04-27', 27);
CALL add_customer('Raviv Monnoyer', '39124 Kedzie Hill', 1214667434, 'rmonnoyerr@ucoz.com', 376248979077121, '2021-04-24', 28);
CALL add_customer('Gery Treherne', '63 Helena Hill', 7356863081, 'gtrehernes@youtu.be', 201692602078413, '2021-04-28', 29);
CALL add_customer('Reinald Foran', '1 Randy Plaza', 4461726008, 'rforant@usatoday.com', 3535832034640601, '2021-04-26', 30);
CALL add_customer('Phaidra Pilbury', '2631 Charing Cross Place', 2088745513, 'ppilburyu@craigslist.org', 3531840083584558, '2021-04-21', 31);
CALL add_customer('Tove Pitcaithley', '2482 Basil Plaza', 767660871, 'tpitcaithleyv@squidoo.com', 5539381006301033, '2021-04-27', 32);
CALL add_customer('Cobbie Loverock', '0030 Tennessee Drive', 9782306188, 'cloverockw@marriott.com', 3558357778950539, '2021-04-24', 33);
CALL add_customer('Reider Kopje', '07420 Granby Crossing', 2058915770, 'rkopjex@deliciousdays.com', 30343291101861, '2021-04-20', 34);
CALL add_customer('Elaina Vinten', '59956 Mosinee Street', '6064393551', 'evinteny@gizmodo.com', 3556242352130975, '2021-04-23', 35);
CALL add_customer('Janaya Bateman', '45 South Way', 6677999883, null, 560225419693967295, '2021-04-27', 36);
CALL add_customer('Bale Calderhead', '3 Farmco Road', 915107510, 'bcalderhead10@umich.edu', 5204664107194223, '2021-04-26', 37);
CALL add_customer('Harriet Povah', null, null, 'hpovah11@mlb.com', 30014477178383, '2021-04-21', 38);
CALL add_customer('Rainer Bour', '59235 Sunbrook Center', 4511198252, 'rbour12@bizjournals.com', 3529844710949717, '2021-04-26', 39);
CALL add_customer('Lenette Ouldcott', '2 Northridge Way', 6399016765, 'louldcott13@newsvine.com', 3564093988919293, '2021-04-26', 40);

/*  function 4 (cid INTEGER, cnumber INTEGER, cexpiry_date DATE, cvv INTEGER)*/
CALL update_credit_card(2, 2, '2021-04-30', 2);

/* function 5 (title TEXT, description TEXT, area TEXT, duration INTEGER) */
CALL add_course('course_A1', 'course_A1', 'course_area_A',1);
CALL add_course('course_D2', 'course_D2', 'course_area_qn10',4);  
CALL add_course('course_D', 'course_D', 'course_area_qn10',1);   

/* function 11 (p_name TEXT, num_free INTEGER,
                start_date DATE, end_date DATE, p_price FLOAT)*/
CALL add_course_packages('Home Ing', 1, '2021-04-04', '2021-04-29', 61.61);
CALL add_course_packages('Greenlam', 2, '2021-04-02', '2021-04-27', 82.97);
CALL add_course_packages('Namfix', 3, '2021-04-03', '2021-04-24', 7.08);
CALL add_course_packages('Matsoft', 4, '2021-04-04', '2021-04-25', 38.12);
CALL add_course_packages('Toughjoyfax', 5, '2021-04-02', '2021-04-24', 43.63);
CALL add_course_packages('Fix San', 6, '2021-04-02', '2021-04-22', 14.54);
CALL add_course_packages('Domainer', 7, '2021-04-04', '2021-04-28', 88.39);
CALL add_course_packages('Lotlux', 8, '2021-04-01', '2021-04-29', 4.91);
CALL add_course_packages('Temp', 9, '2021-04-02', '2021-04-20', 17.54);
CALL add_course_packages('Kanlam', 10, '2021-04-04', '2021-04-18', 29.7);
CALL add_course_packages('Transcof', 11, '2021-04-01', '2021-04-24', 95.06);
CALL add_course_packages('Hatity', 12, '2021-04-03', '2021-04-25', 73.2);
CALL add_course_packages('Regrant', 13, '2021-04-03', '2021-04-26', 5.17);
CALL add_course_packages('Fintone', 14, '2021-04-01', '2021-04-24', 2.06);
CALL add_course_packages('Home Ing', 15, '2021-04-04', '2021-04-26', 70.93);
CALL add_course_packages('Gembucket', 16, '2021-04-03', '2021-04-26', 68.38);
CALL add_course_packages('Job', 17, '2021-04-03', '2021-04-23', 55.69);
CALL add_course_packages('Viva', 18, '2021-04-03', '2021-04-25', 73.84);
CALL add_course_packages('Cardify', 19, '2021-04-01', '2021-04-21', 8.87);
CALL add_course_packages('Cardguard', 20, '2021-04-04', '2021-04-21', 70.74);
CALL add_course_packages('Ronstring', 21, '2021-04-01', '2021-04-19', 94.54);
CALL add_course_packages('Stim', 22, '2021-04-03', '2021-04-23', 47.94);
CALL add_course_packages('Toughjoyfax', 23, '2021-04-03', '2021-04-25', 74.98);
CALL add_course_packages('Cookley', 24, '2021-04-04', '2021-04-27', 61.97);
CALL add_course_packages('Otcom', 25, '2021-04-02', '2021-04-18', 14.9);
CALL add_course_packages('Stronghold', 26, '2021-04-02', '2021-04-24', 75.4);
CALL add_course_packages('Lotlux', 27, '2021-04-03', '2021-04-25', 88.8);
CALL add_course_packages('Ronstring', 28, '2021-04-03', '2021-04-22', 50.74);
CALL add_course_packages('Rank', 29, '2021-04-01', '2021-04-28', 56.25);
CALL add_course_packages('Sonair', 30, '2021-04-01', '2021-04-22', 94.5);
CALL add_course_packages('Holdlamis', 31, '2021-04-01', '2021-04-24', 70.66);
CALL add_course_packages('Bigtax', 32, '2021-04-03', '2021-04-22', 33.67);
CALL add_course_packages('Lotstring', 33, '2021-04-04', '2021-04-24', 52.37);
CALL add_course_packages('Redhold', 34, '2021-04-04', '2021-04-28', 76.85);
CALL add_course_packages('Cardify', 35, '2021-04-03', '2021-04-25', 16.8);
CALL add_course_packages('Vagram', 36, '2021-04-03', '2021-04-28', 1.3);
CALL add_course_packages('Zontrax', 37, '2021-04-04', '2021-04-18', 5.41);
CALL add_course_packages('Regrant', 38, '2021-04-24', '2021-04-28', 45.61);
CALL add_course_packages('Cookley', 39, '2021-04-05', '2021-04-06', 38.98);
CALL add_course_packages(NULL, 40, '2021-04-04', '2021-04-18', 1.08);

/* function 12 */
-- SELECT * FROM get_available_course_packages(); -- expect 38 results

/* function 13 (cid INTEGER, pid INTEGER)*/
-- CALL buy_course_package(1, 1);
--negative CASE


/* Test case for 6 and 10 */
INSERT INTO Offerings VALUES
(2, '2021-03-01', '2021-04-01', '2021-04-11', '2021-03-10', 10, 10, 1.0, 13);


insert into Rooms(rid, location, seating_capacity) values (1,'A', 1);
insert into Rooms values (2,'room_B', 2);
insert into Rooms values (3,'room_C', 3);
insert into Rooms values (4,'room_D', 4);
insert into Rooms values (5,'room_E', 5);
insert into Rooms values (6,'room_A1', 1);
insert into Rooms values (7,'room_B1', 2);
insert into Rooms values (8,'room_C1', 3);

/* ------------------------------- Assign sessions ----------------------------- */
INSERT INTO Sessions (sid, s_date, start_time, end_time, course_id ,
    launch_date, rid, eid)
VALUES
(9, '2021-04-01', '09:00:00', 
'10:00:00', 2, '2021-03-01', 1, 9);
INSERT INTO Sessions VALUES
(10, '2021-04-01', '11:00:00', 
'12:00:00', 2, '2021-03-01', 1, 9);
/* --------------  1 hr left --------------*/
INSERT INTO Sessions VALUES
(1, '2021-04-02', '14:00:00', 
'18:00:00', 2, '2021-03-01', 2, 8);
INSERT INTO Sessions VALUES
(2, '2021-04-03', '14:00:00', 
'18:00:00', 2, '2021-03-01', 2, 8);
INSERT INTO Sessions VALUES
(3, '2021-04-04', '14:00:00', 
'18:00:00', 2, '2021-03-01', 2, 8);
INSERT INTO Sessions VALUES
(4, '2021-04-05', '14:00:00', 
'18:00:00', 2, '2021-03-01', 2, 8);
INSERT INTO Sessions VALUES
(5, '2021-04-06', '14:00:00', 
'18:00:00', 2, '2021-03-01', 2, 8);
INSERT INTO Sessions VALUES
(6, '2021-04-07', '14:00:00', 
'18:00:00', 2, '2021-03-01', 2, 8);
INSERT INTO Sessions VALUES
(7, '2021-04-08', '14:00:00', 
'18:00:00', 2, '2021-03-01', 2, 8);
INSERT INTO Sessions VALUES
(8, '2021-04-10', '17:00:00', 
'18:00:00', 2, '2021-03-01', 1, 8);


/* ---------------------fn 8--------------------------*/
-- SELECT * FROM find_rooms('2021-04-08', '17:00:00', 1); -- no room 2
-- SELECT * FROM find_rooms('2021-04-08', '10:00:00', 1); -- every room
-- INSERT INTO Sessions VALUES
-- (11, '2021-04-11', '10:00:00', 
-- '11:00:00', 2, '2021-03-01', 2, 8);
-- SELECT * FROM find_rooms('2021-04-11', '09:00:00', 3); -- no room 2
-- CALL remove_session(2, '2021-03-01', 11);

/* ------- Qn 10 Test case -----------*/
CALL add_course_offering(3, 1.0,'2021-03-02','2021-04-15', 2, 13, 
('2021-05-02', '09:00:00', 2), ('2021-05-02', '10:00:00', 1), ('2021-05-02', '11:00:00', 2));   
/* function 24 and function 23 */
CALL add_session(3, 9, '2021-04-30', '14:00:00', 9, 2);
CALL remove_session(3, '2021-03-02', 9);
-- CALL remove_session(3, '2021-03-02', 1121);
-- CALL remove_session(2, '2021-03-01',5);--fail cuz session has already started

-- CALL add_course_offering(3, 1.0,'2021-03-02','2021-03-15', 2, 13, 
-- ('2021-04-02', '09:00:00', 2), ('2021-04-02', '10:00:00', 1), ('2021-04-02', '10:00:00', 2));// expect fail