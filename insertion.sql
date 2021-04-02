-------- Insert Customers

-- Positve insertions for Employees hierarchy
INSERT INTO "Customers" (cust_id,name,phone,email,address) VALUES (1676030602899,'Nell T. Calderon',76044067,'Nunc.lectus@orci.ca','2447 Enim. Avenue');
INSERT INTO "Customers" (cust_id,name,phone,email,address) VALUES (1670121565299,'Merritt C. Wagner',61281669,'tristique.senectus.et@luctuslobortisClass.org','P.O. Box 752, 5557 Neque Av.');
INSERT INTO "Customers" (cust_id,name,phone,email,address) VALUES (1602032836299,'Adara M. Bailey',89253939,'augue.scelerisque@mauris.net','Ap #329-1731 Et Rd.');
INSERT INTO "Customers" (cust_id,name,phone,email,address) VALUES (1678011764099,'Adara M. Bailey',89686053,'a@aliquameuaccumsan.edu','P.O. Box 105, 9504 Tristique St.');
INSERT INTO "Customers" (cust_id,name,phone,email,address) VALUES (1655120277499,'Oren C. Byrd',30999101,'mi.felis.adipiscing@Fusce.ca','3840 Mauris Street');
INSERT INTO "Customers" (cust_id,name,phone,email,address) VALUES (1682121904099,'Brian Z. Osborn',30999101,'ut.nulla@amalesuadaid.com','241-1798 Fusce Av.');
INSERT INTO "Customers" (cust_id,name,phone,email,address) VALUES (1681120138899,'James L. Barrett',1323854,'tempor.arcu@mauriselit.com','P.O. Box 590, 5859 Quam Av.');
INSERT INTO "Customers" (cust_id,name,phone,email,address) VALUES (1640120779699,'Abbot C. Woods',93308560,'adipiscing@augueeutellus.com','878-1689 Natoque Rd.');
INSERT INTO "Customers" (cust_id,name,phone,email,address) VALUES (1625072041899,'Burton O. Langley',24345387,'Aliquam@ut.ca','878-1689 Natoque Rd.');
INSERT INTO "Customers" (cust_id,name,phone,email,address) VALUES (1623012646899,'Dorothy K. Nguyen',22745671,'a@ullamcorper.net','Ap #365-1251 Pede Ave');

-- Negative insertions for Employees hierarchy
INSERT INTO "Customers" (cust_id,name,phone,email,address) VALUES (1650112335899,'Conan H. Hewitt',83453879,'lorem@nonarcu.edu','P.O. Box 159, 6870 Fusce Rd.');
INSERT INTO "Customers" (cust_id,name,phone,email,address) VALUES (1650112335899,'John Z. Witt',37291142,'blandit.Nam.nulla@nonfeugiat.ca','8822 Magna. Rd.');
INSERT INTO "Customers" (cust_id,name,phone,email,address) VALUES (NULL,'Cameron T. Castillo',92187324,'lacinia@eget.org','224-9477 Vitae Road');
INSERT INTO "Customers" (cust_id,name,phone,email,address) VALUES (1677083036799,NULL,36111914,'neque.Nullam.nisl@dictum.ca','793 Tristique Avenue');
INSERT INTO "Customers" (cust_id,name,phone,email,address) VALUES (1683022040099,'Raya Y. Tate',NULL,'est.Mauris.eu@lectus.edu','Ap #445-295 Ullamcorper St.');


-------- Insert Rooms

-- Positve insertions for Rooms
INSERT INTO "Rooms" (rid,location,seating_capacity) VALUES (09948492199,'#06-013, P.O. Box 919, 1276 Nunc Rd.',151);
INSERT INTO "Rooms" (rid,location,seating_capacity) VALUES (25393426299,'P.O. Box 518, 3075 Ipsum. Av.',132);
INSERT INTO "Rooms" (rid,location,seating_capacity) VALUES (45401285099,'Ap #219-5134 Consequat Ave',16);
INSERT INTO "Rooms" (rid,location,seating_capacity) VALUES (06318568699,'604-1129 Convallis Ave',53);
INSERT INTO "Rooms" (rid,location,seating_capacity) VALUES (77228092599,'Ap #221-9496 Cursus Road',119);
INSERT INTO "Rooms" (rid,location,seating_capacity) VALUES (20600578799,'2075 Ligula. Rd.',27);
INSERT INTO "Rooms" (rid,location,seating_capacity) VALUES (71803288599,'445-4464 Ipsum Av.',55);
INSERT INTO "Rooms" (rid,location,seating_capacity) VALUES (08474057799,'P.O. Box 152, 9645 Nec Street',190);
INSERT INTO "Rooms" (rid,location,seating_capacity) VALUES (09397611499,'646-2248 Nisi. Av.',99);
INSERT INTO "Rooms" (rid,location,seating_capacity) VALUES (61384650999,'Ap #601-7100 Ipsum. St.',41);

-- Negative insertions for Rooms
INSERT INTO "Rooms" (rid,location,seating_capacity) VALUES (NULL,'P.O. Box 242, 3441 Magna Rd.',129);
INSERT INTO "Rooms" (rid,location,seating_capacity) VALUES (11621146999,'P.O. Box 656, 6025 Mauris St.',160);
INSERT INTO "Rooms" (rid,location,seating_capacity) VALUES (11621146999,'711-8257 Duis Avenue',200);
INSERT INTO "Rooms" (rid,location,seating_capacity) VALUES (65705231899,NULL,53);
INSERT INTO "Rooms" (rid,location,seating_capacity) VALUES (13300765899,'P.O. Box 718, 3543 Ligula. Rd.',NULL);


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

-- Negative insertions for Rooms
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
INSERT INTO Course_packages (package_id, sale_start_date, num_free_registrations, sale_end_date, name, price) VALUES (49832456, '2020-01-03', -1, '2021-05-20', 'Philosophy Package 3', 296.48);
INSERT INTO Course_packages (package_id, sale_start_date, num_free_registrations, sale_end_date, name, price) VALUES (42345615, '2020-06-02', 3, '2021-05-08', 'Food Science Package 1', -345.45);
