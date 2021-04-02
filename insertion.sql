 --<----------------------- company side ----------------------->
-------- Insert Customers

-- Positve insertions for Employees hierarchy
INSERT INTO Customers (cust_id,name,phone,email,address) VALUES (1,'Nell T. Calderon',76044067,'Nunc.lectus@orci.ca','2447 Enim. Avenue');
INSERT INTO Customers (cust_id,name,phone,email,address) VALUES (2,'Merritt C. Wagner',61281669,'tristique.senectus.et@luctuslobortisClass.org','P.O. Box 752, 5557 Neque Av.');
INSERT INTO Customers (cust_id,name,phone,email,address) VALUES (3,'Adara M. Bailey',89253939,'augue.scelerisque@mauris.net','Ap #329-1731 Et Rd.');
INSERT INTO Customers (cust_id,name,phone,email,address) VALUES (4,'Adara M. Bailey',89686053,'a@aliquameuaccumsan.edu','P.O. Box 105, 9504 Tristique St.');
INSERT INTO Customers (cust_id,name,phone,email,address) VALUES (5,'Oren C. Byrd',30999101,'mi.felis.adipiscing@Fusce.ca','3840 Mauris Street');
INSERT INTO Customers (cust_id,name,phone,email,address) VALUES (6,'Brian Z. Osborn',30999101,'ut.nulla@amalesuadaid.com','241-1798 Fusce Av.');
INSERT INTO Customers (cust_id,name,phone,email,address) VALUES (7,'James L. Barrett',1323854,'tempor.arcu@mauriselit.com','P.O. Box 590, 5859 Quam Av.');
INSERT INTO Customers (cust_id,name,phone,email,address) VALUES (8,'Abbot C. Woods',93308560,'adipiscing@augueeutellus.com','878-1689 Natoque Rd.');
INSERT INTO Customers (cust_id,name,phone,email,address) VALUES (9,'Burton O. Langley',24345387,'Aliquam@ut.ca','878-1689 Natoque Rd.');
INSERT INTO Customers (cust_id,name,phone,email,address) VALUES (10,'Dorothy K. Nguyen',22745671,'a@ullamcorper.net','Ap #365-1251 Pede Ave');

-- Negative insertions for Employees hierarchy
INSERT INTO Customers (cust_id,name,phone,email,address) VALUES (11,'Conan H. Hewitt',83453879,'lorem@nonarcu.edu','P.O. Box 159, 6870 Fusce Rd.');
INSERT INTO Customers (cust_id,name,phone,email,address) VALUES (11,'John Z. Witt',37291142,'blandit.Nam.nulla@nonfeugiat.ca','8822 Magna. Rd.');
INSERT INTO Customers (cust_id,name,phone,email,address) VALUES (NULL,'Cameron T. Castillo',92187324,'lacinia@eget.org','224-9477 Vitae Road');


-------- Insert Rooms

-- Positve insertions for Rooms
INSERT INTO Rooms (rid,location,seating_capacity) VALUES (09948492199,'#06-013, P.O. Box 919, 1276 Nunc Rd.',151);
INSERT INTO Rooms (rid,location,seating_capacity) VALUES (25393426299,'P.O. Box 518, 3075 Ipsum. Av.',132);
INSERT INTO Rooms (rid,location,seating_capacity) VALUES (45401285099,'Ap #219-5134 Consequat Ave',16);
INSERT INTO Rooms (rid,location,seating_capacity) VALUES (06318568699,'604-1129 Convallis Ave',53);
INSERT INTO Rooms (rid,location,seating_capacity) VALUES (77228092599,'Ap #221-9496 Cursus Road',119);
INSERT INTO Rooms (rid,location,seating_capacity) VALUES (20600578799,'2075 Ligula. Rd.',27);
INSERT INTO Rooms (rid,location,seating_capacity) VALUES (71803288599,'445-4464 Ipsum Av.',55);
INSERT INTO Rooms (rid,location,seating_capacity) VALUES (08474057799,'P.O. Box 152, 9645 Nec Street',190);
INSERT INTO Rooms (rid,location,seating_capacity) VALUES (09397611499,'646-2248 Nisi. Av.',99);
INSERT INTO Rooms (rid,location,seating_capacity) VALUES (61384650999,'Ap #601-7100 Ipsum. St.',41);

-- Negative insertions for Rooms
INSERT INTO Rooms (rid,location,seating_capacity) VALUES (NULL,'P.O. Box 242, 3441 Magna Rd.',129);
INSERT INTO Rooms (rid,location,seating_capacity) VALUES (11621146999,'P.O. Box 656, 6025 Mauris St.',160);
INSERT INTO Rooms (rid,location,seating_capacity) VALUES (11621146999,'711-8257 Duis Avenue',200);
INSERT INTO Rooms (rid,location,seating_capacity) VALUES (65705231899,NULL,53);
INSERT INTO Rooms (rid,location,seating_capacity) VALUES (13300765899,'P.O. Box 718, 3543 Ligula. Rd.',NULL);


-------- Insert Course_areas

-- Positve insertions for Course_areas
INSERT INTO Course_areas (name, eid) VALUES ('Computer Science', 978192384);
INSERT INTO Course_areas (name, eid) VALUES ('Product Management', 320212438);
INSERT INTO Course_areas (name, eid) VALUES ('Sales', 785784942);
INSERT INTO Course_areas (name, eid) VALUES ('Medicine', 357763074);
INSERT INTO Course_areas (name, eid) VALUES ('Food Science', 516230644);
INSERT INTO Course_areas (name, eid) VALUES ('Chemical Engineering', 641174894);
INSERT INTO Course_areas (name, eid) VALUES ('Music Production', 522407555);
INSERT INTO Course_areas (name, eid) VALUES ('Finance', 150478853);
INSERT INTO Course_areas (name, eid) VALUES ('Law', 768160495);
INSERT INTO Course_areas (name, eid) VALUES ('Philosophy', 992679413);

-- Negative insertions for Course_areas
INSERT INTO Course_areas (name, eid) VALUES (NULL, 978192384);
INSERT INTO Course_areas (name, eid) VALUES ('Mechanical Engineering', 320212438);
INSERT INTO Course_areas (name, eid) VALUES ('Mechanical Engineering', 785784942);
INSERT INTO Course_areas (name, eid) VALUES ('Sociology', NULL);


-------- Insert Course_packages

-- Positve insertions for Course_packages
INSERT INTO Course_packages (package_id, sale_start_date, num_free_registrations, sale_end_date, name, price) VALUES (55615684, '2020-01-15', 0, '2020-03-06', 'Computer Science Package 1', 402.47);
INSERT INTO Course_packages (package_id, sale_start_date, num_free_registrations, sale_end_date, name, price) VALUES (79264924, '2020-01-19', 1, '2021-03-18', 'Computer Science Package 2', 198.44);
INSERT INTO Course_packages (package_id, sale_start_date, num_free_registrations, sale_end_date, name, price) VALUES (17193750, '2020-03-23', 4, '2021-03-22', 'Computer Science Package 3', 262.46);
INSERT INTO Course_packages (package_id, sale_start_date, num_free_registrations, sale_end_date, name, price) VALUES (61432879, '2020-04-08', 15, '2021-05-03', 'Sociology Package 1', 485.51);
INSERT INTO Course_packages (package_id, sale_start_date, num_free_registrations, sale_end_date, name, price) VALUES (10728548, '2020-06-03', 16, '2021-03-31', 'Sociology Package 2', 391.21);
INSERT INTO Course_packages (package_id, sale_start_date, num_free_registrations, sale_end_date, name, price) VALUES (79933267, '2020-05-06', 13, '2020-12-13', 'Sociology Package 3', 249.76);
INSERT INTO Course_packages (package_id, sale_start_date, num_free_registrations, sale_end_date, name, price) VALUES (59981916, '2021-01-30', 7, '2021-12-15', 'Philosophy Package 1', 190.33);
INSERT INTO Course_packages (package_id, sale_start_date, num_free_registrations, sale_end_date, name, price) VALUES (32126145, '2020-05-26', 13, '2021-01-20', 'Philosophy Package 2', 444.77);
INSERT INTO Course_packages (package_id, sale_start_date, num_free_registrations, sale_end_date, name, price) VALUES (49830056, '2020-01-03', 11, '2021-05-20', 'Philosophy Package 3', 296.48);
INSERT INTO Course_packages (package_id, sale_start_date, num_free_registrations, sale_end_date, name, price) VALUES (48028615, '2020-06-02', 3, '2021-05-08', 'Food Science Package 1', 401.46);

-- Negative insertions for Course_packages
INSERT INTO Course_packages (package_id, sale_start_date, num_free_registrations, sale_end_date, name, price) VALUES (79933123, '2020-05-06', 13, '2020-12-13', 'Sociology Package 3', 249.76);
INSERT INTO Course_packages (package_id, sale_start_date, num_free_registrations, sale_end_date, name, price) VALUES (79933123, '2021-01-30', 7, '2021-12-15', 'Philosophy Package 1', 190.33);
INSERT INTO Course_packages (package_id, sale_start_date, num_free_registrations, sale_end_date, name, price) VALUES (NULL, '2020-05-26', 13, '2021-01-20', 'Philosophy Package 2', 444.77);
INSERT INTO Course_packages (package_id, sale_start_date, num_free_registrations, sale_end_date, name, price) VALUES (49832456, '2020-01-03', -1, '2021-05-20', 'Philosophy Package 3', -296.48);
INSERT INTO Course_packages (package_id, sale_start_date, num_free_registrations, sale_end_date, name, price) VALUES (42345615, '2020-06-00', 3, '2021-05-765', 'Food Science Package 1', 123.32);


-------- Insert Credit_cards

-- Positve insertions for Credit_cards
INSERT INTO Credit_cards (number, CVV, expiry_date, cust_id, from_date) VALUES (5207757125861655, 712,'21-12-21', 1676030602899);
INSERT INTO Credit_cards (number, CVV, expiry_date, cust_id, from_date) VALUES (1449389814987739, 448,'21-01-08', 1670121565299);
INSERT INTO Credit_cards (number, CVV, expiry_date, cust_id, from_date) VALUES (4772425519204232, 468,'21-09-28', 1602032836299);
INSERT INTO Credit_cards (number, CVV, expiry_date, cust_id, from_date) VALUES (2238406833054283, 132,'20-12-03', 1678011764099);
INSERT INTO Credit_cards (number, CVV, expiry_date, cust_id, from_date) VALUES (8405238874121091, 906,'21-07-18', 1655120277499);
INSERT INTO Credit_cards (number, CVV, expiry_date, cust_id, from_date) VALUES (5404411412295264, 320,'20-06-22', 1682121904099);
INSERT INTO Credit_cards (number, CVV, expiry_date, cust_id, from_date) VALUES (7268272469910540, 834,'22-02-27', 1681120138899);
INSERT INTO Credit_cards (number, CVV, expiry_date, cust_id, from_date) VALUES (7531491645485563, 258,'20-09-10', 1640120779699);
INSERT INTO Credit_cards (number, CVV, expiry_date, cust_id, from_date) VALUES (5204373474155087, 442,'20-09-09', 1625072041899);
INSERT INTO Credit_cards (number, CVV, expiry_date, cust_id, from_date) VALUES (2065629961409359, 377,'20-05-08', 1623012646899);

-- Negative insertions for Credit_cards
INSERT INTO Credit_cards (number, CVV, expiry_date, cust_id, from_date) VALUES (NULL, 831,'20-08-29', 1623012623456);
INSERT INTO Credit_cards (number, CVV, expiry_date, cust_id, from_date) VALUES (3551375609223241, 547,1623765436899);
INSERT INTO Credit_cards (number, CVV, expiry_date, cust_id, from_date) VALUES (3551375609223241, 641,'20-08-30', 1623012609865);
INSERT INTO Credit_cards (number, CVV, expiry_date, cust_id, from_date) VALUES (1326261219057330, 368,'21-09-17', NULL);
INSERT INTO Credit_cards (number, CVV, expiry_date, cust_id, from_date) VALUES (9612070681780448, 438,'20-12-22', 1633417626899);


-------- Insert Courses

-- Positve insertions for Courses
INSERT INTO Courses (course_id, duration, description, title, name) VALUES (1, 69.0, 'Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.', 'vestibulum eget vulputate ut ultrices vel augue vestibulum ante', 'Computer Science');
INSERT INTO Courses (course_id, duration, description, title, name) VALUES (2, 62.4, 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti. Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus.', 'luctus et ultrices', 'Product Management');
INSERT INTO Courses (course_id, duration, description, title, name) VALUES (3, 86.8, 'In eleifend quam a odio. In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem.', 'donec vitae nisi nam ultrices', 'Sales');
INSERT INTO Courses (course_id, duration, description, title, name) VALUES (4, 79.9, 'Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor.', 'tortor quis turpis sed ante vivamus', 'Medicine');
INSERT INTO Courses (course_id, duration, description, title, name) VALUES (5, 67.9, 'Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.', 'nulla nisl nunc nisl duis', 'Food Science';
INSERT INTO Courses (course_id, duration, description, title, name) VALUES (6, 76.9, 'Praesent lectus. Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis. Duis consequat dui nec nisi volutpat eleifend.', 'id mauris vulputate', 'Chemical Engineering');
INSERT INTO Courses (course_id, duration, description, title, name) VALUES (7, 65.7, 'Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti. Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus.', 'in quam fringilla rhoncus mauris enim', 'Music Production');
INSERT INTO Courses (course_id, duration, description, title, name) VALUES (8, 64.5, 'Proin eu mi. Nulla ac enim.', 'ipsum primis in faucibus orci luctus', 'Finance');
INSERT INTO Courses (course_id, duration, description, title, name) VALUES (9, 64.4, 'Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede. Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus.', 'dignissim vestibulum vestibulum ante ipsum primis in faucibus', 'Law');
INSERT INTO Courses (course_id, duration, description, title, name) VALUES (10, 73.5, 'Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis. Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis.', 'etiam faucibus cursus urna ut', 'Philosophy');

-- Negative insertions for Courses
INSERT INTO Courses (course_id, duration, description, title, name) VALUES (11, 70.1, 'Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede. Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.', 'at turpis donec posuere metus vitae ipsum aliquam non mauris', 'Music Production');
INSERT INTO Courses (course_id, duration, description, title, name) VALUES (11, 98.4, 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat.', 'aliquam non mauris morbi non lectus aliquam sit amet diam', 'Philosophy');
INSERT INTO Courses (course_id, duration, description, title, name) VALUES (12, 67.2, 'Nam dui.', 'iaculis congue vivamus', NULL);




