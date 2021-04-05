SELECT add_customer('john', 'hell', 999, 'a@b.com', 999999999, '2021-12-21', 321);
SELECT add_customer('corn', 'hello', 888, 'b@b.com', 889999999, '2021-12-21', 221);
SELECT update_credit_card(1, 889999889, '2021-12-11', 121);
INSERT INTO Course_packages (sale_start_date, num_free_registrations, sale_end_date, name, price) VALUES ('2020-04-08', 15, '2021-05-03', 'Sociology Package 1', 485.51);
INSERT INTO Course_packages (sale_start_date, num_free_registrations, sale_end_date, name, price) VALUES ('2020-06-03', 16, '2021-03-31', 'Sociology Package 2', 391.21);
INSERT INTO Course_packages (sale_start_date, num_free_registrations, sale_end_date, name, price) VALUES ('2020-05-06', 13, '2020-12-13', 'Sociology Package 3', 249.76);
select buy_course_package(1,1);
call add_employee('Nell T. Calderon','2447 Enim. Avenue', 76044067,'Nunc.lectus@orci.ca', 10000, '2021-4-4', 'manager', array['CS']);
call add_course('cs1231', 'god stuf', 'CS', 2);
call add_employee('Banerjee','2341 bokers. Avenue', 98044067,'pops.lectus@orci.ca', 10000, '2021-4-4', 'administrator');
INSERT INTO Offerings (course_id, launch_date, start_date, end_date, reg_deadline, num_target_reg,
							 seating_capacity, fees, aid) VALUES (1, '2021-4-4', '2021-5-20', '2021-8-20','2021-5-4', 30, 30, 20, 2);
call add_employee('fti','0049 jame. Avenue', 32044067,'notpop.lectus@orci.ca', 6000, '2021-4-4', 'full time instructor', array['CS']);
INSERT INTO Rooms (location, seating_capacity) VALUES ('COM2', 30);
call add_session(1, 1, '2021-6-4', '10:00:00', 4,1);
call add_session(1, 2, '2021-6-4', '11:00:00', 4,1);
INSERT INTO Redeems (package_id, number, b_date, r_date, course_id, launch_date, sid, rid, eid) VALUES (1, 999999999, '2021-04-03', 
                            CURRENT_DATE, 1, '2021-4-4', 1, 1, 4);