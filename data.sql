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

-- Customers
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


-- Managers (indexed 1-10)
CALL add_employee('Manager_01', 'maddress 1', 10000001, 'm1@mail.com', 15000, '2020-08-31', 'manager', ARRAY['CS']);
CALL add_employee('Manager_02', 'maddress 2', 10000002, 'm2@mail.com', 5000, '2020-11-30', 'manager', ARRAY['Science']);
CALL add_employee('Manager_03', 'maddress 3', 10000003, 'm3@mail.com', 6000, '2021-01-01', 'manager', ARRAY['Medicine']);
CALL add_employee('Manager_04', 'maddress 4', 10000004, 'm4@mail.com', 8000, '2021-04-30', 'manager', ARRAY['Mathematics']);
CALL add_employee('Manager_05', 'maddress 5', 10000005, 'm5@mail.com', 6000, '2008-05-24', 'manager', ARRAY['Economics']);
CALL add_employee('Manager_06', 'maddress 6', 10000006, 'm6@mail.com', 6000, '2000-03-04', 'manager', ARRAY['Business']);
CALL add_employee('Manager_07', 'maddress 7', 10000007, 'm7@mail.com', 10000, '1996-09-21', 'manager', ARRAY['Engineering']);
CALL add_employee('Manager_08', 'maddress 8', 10000008, 'm8@mail.com', 7000, '2016-04-30', 'manager', ARRAY['Architecture']);
CALL add_employee('Manager_09', 'maddress 9', 10000009, 'm9@mail.com', 12000, '1985-08-16', 'manager', ARRAY['Law']);
CALL add_employee('Manager_10', 'maddress 10', 10000010, 'm10@mail.com', 9500, '2001-09-11', 'manager', ARRAY['Politics']);

-- Part time instructors (indexed 11-20)
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

-- Full time instructors (indexed 21-30)
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

-- Administrators (indexed 31-40)
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
CALL add_course('CS1000', 'CS level 1', 'CS', 1);
CALL add_course('CS2000', 'CS level 2', 'CS', 2);
CALL add_course('CS3000', 'CS level 3', 'CS', 2);
CALL add_course('MD1000', 'Medicine level 1', 'Medicine', 2);
CALL add_course('MD2000', 'Medicine level 2', 'Medicine', 2);
CALL add_course('MA1000', 'Math level 1', 'Mathematics', 1);
CALL add_course('MA2000', 'Math level 2', 'Mathematics', 2);
CALL add_course('BZ1000', 'Business level 1', 'Business', 2);
CALL add_course('EC1000', 'Econ level 1', 'Economics', 2);
CALL add_course('EC2000', 'Econ level 2', 'Economics', 2);
CALL add_course('EC3000', 'Econ level 3', 'Economics', 3);

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

-- Course Offerings and Sessions
CALL add_course_offering(1, 100, '2021-05-03', '2021-04-20', 10, 31, VARIADIC ARRAY[('2021-05-03', '09:00', 1), ('2021-05-05', '15:00', 1)]::Session[]);
CALL add_course_offering(1, 100, '2021-05-10', '2021-04-25', 10, 32, VARIADIC ARRAY[('2021-05-11', '15:00', 2)]::Session[]);
CALL add_course_offering(2, 99, '2021-05-17', '2021-05-05', 5, 33, VARIADIC ARRAY[('2021-05-17', '09:00', 3)]::Session[]);
CALL add_course_offering(3, 193, '2021-05-24', '2021-05-12', 15, 33, VARIADIC ARRAY[('2021-05-24', '15:00', 1), ('2021-05-26', '09:00', 1)]::Session[]);
CALL add_course_offering(2, 100, '2021-05-10', '2021-04-25', 10, 34, VARIADIC ARRAY[('2021-05-10', '09:00', 2)]::Session[]);
CALL add_course_offering(4, 199, '2021-05-31', '2021-05-15', 5, 35, VARIADIC ARRAY[('2021-05-31', '09:00', 5)]::Session[]);
CALL add_course_offering(5, 89.99, '2021-06-02', '2021-05-20', 10, 36, VARIADIC ARRAY[('2021-06-02', '09:00', 6)]::Session[]);
CALL add_course_offering(2, 299, '2021-06-02', '2021-05-20', 5, 36, VARIADIC ARRAY[('2021-06-04', '15:00', 4)]::Session[]);
CALL add_course_offering(7, 109, '2021-06-09', '2021-05-30', 10, 33, VARIADIC ARRAY[('2021-06-10', '09:00', 3)]::Session[]);
CALL add_course_offering(2, 99, '2021-06-09', '2021-05-30', 5, 39, VARIADIC ARRAY[('2021-06-09', '15:00', 2)]::Session[]);

-- Course Packages
CALL add_course_packages('Package 1', 3, '2021-04-05', '2021-04-30', 199);
CALL add_course_packages('Package 2', 2, '2021-03-18', '2021-04-30', 209);
CALL add_course_packages('Package 3', 5, '2020-09-05', '2020-11-30', 99.99);
CALL add_course_packages('Package 4', 10, '2020-07-24', '2020-08-31', 45.49);
CALL add_course_packages('Package 5', 4, '2021-04-01', '2021-04-30', 199);
CALL add_course_packages('Package 6', 1, '2021-04-01', '2021-04-30', 89);
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

-- Buys course packages
CALL buy_course_package(1, 6);
CALL buy_course_package(2, 1);
CALL buy_course_package(3, 1);
CALL buy_course_package(5, 2);
CALL buy_course_package(7, 7);
CALL buy_course_package(11, 5);
CALL buy_course_package(12, 5);
CALL buy_course_package(4, 6);
CALL buy_course_package(6, 8);
CALL buy_course_package(8, 10);
CALL buy_course_package(9, 7);
CALL buy_course_package(10, 13);

-- Registers sessions
CALL register_session(1, 1, '2021-05-03', 1, 'payment');
CALL register_session(2, 1, '2021-05-03', 1, 'redemption');
CALL register_session(1, 2, '2021-05-17', 1, 'redemption');
CALL register_session(3, 3, '2021-05-24', 1, 'payment');
CALL register_session(1, 3, '2021-05-24', 1, 'payment');
CALL register_session(1, 4, '2021-05-31', 1, 'payment');
CALL register_session(3, 4, '2021-05-31', 1, 'redemption');
CALL register_session(3, 5, '2021-06-02', 1, 'payment');
CALL register_session(4, 1, '2021-05-10', 1, 'payment');
CALL register_session(4, 2, '2021-05-10', 1, 'payment');
CALL register_session(5, 7, '2021-06-09', 1, 'redemption');
CALL register_session(10, 7, '2021-06-09', 1, 'redemption');
CALL register_session(10, 1, '2021-05-10', 1, 'redemption');
CALL register_session(10, 2, '2021-05-17', 1, 'redemption');
CALL register_session(10, 3, '2021-05-24', 1, 'redemption');
CALL register_session(10, 5, '2021-06-02', 1, 'redemption');

-- Pay slips
SELECT * FROM pay_salary();

-- Cancels
CALL cancel_registration(1, 1, '2021-05-03');
CALL cancel_registration(1, 2, '2021-05-17');
CALL cancel_registration(2, 1, '2021-05-03');
CALL cancel_registration(3, 3, '2021-05-24');
CALL cancel_registration(1, 3, '2021-05-24');
CALL cancel_registration(10, 5, '2021-06-02');
CALL cancel_registration(10, 3, '2021-05-24');
CALL cancel_registration(5, 7, '2021-06-09');
CALL cancel_registration(1, 4, '2021-05-31');
CALL cancel_registration(10, 7, '2021-06-09');