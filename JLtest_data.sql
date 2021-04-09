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

INSERT INTO Employees (name, phone, email, join_date, address, depart_date) 
	VALUES ('Part_time_instr_01', 01010101, 'employee01@gmail.com', DATE'2020-01-01', 'address_employee_01', NULL);
INSERT INTO Employees (name, phone, email, join_date, address, depart_date) 
	VALUES ('Full_time_instr_01', 02020202, 'employee02@gmail.com', DATE'2020-12-31', 'address_employee_02', DATE'2021-04-11');
INSERT INTO Employees (name, phone, email, join_date, address, depart_date) 
	VALUES ('Manager_01', 03030303, 'employee03@gmail.com', DATE'2020-01-01', 'address_employee_03', NULL);
INSERT INTO Employees (name, phone, email, join_date, address, depart_date) 
	VALUES ('Manager_02', 04040404, 'employee04@gmail.com', DATE'2020-01-01', 'address_employee_04', NULL);
INSERT INTO Employees (name, phone, email, join_date, address, depart_date) 
	VALUES ('Administrator_01', 05050505, 'employee05@gmail.com', DATE'2020-01-01', 'address_employee_05', NULL);
INSERT INTO Employees (name, phone, email, join_date, address, depart_date) 
	VALUES ('Administrator_02', 06060606, 'employee06@gmail.com', DATE'2020-01-01', 'address_employee_06', NULL);
INSERT INTO Employees (name, phone, email, join_date, address, depart_date) 
	VALUES ('Administrator_03', 07070707, 'employee07@gmail.com', CURRENT_DATE, 'address_employee_06', NULL);
INSERT INTO Employees (name, phone, email, join_date, address, depart_date) 
	VALUES ('Administrator_04', 08080808, 'employee08@gmail.com', DATE'2020-01-01', 'address_employee_06', CURRENT_DATE);

INSERT INTO Part_time_emp (eid, hourly_rate)
	VALUES (1, 100.01);
	
INSERT INTO Full_time_emp (eid, monthly_salary)
	VALUES (2, 20000.01);
INSERT INTO Full_time_emp (eid, monthly_salary)
	VALUES (3, 10000.01);
INSERT INTO Full_time_emp (eid, monthly_salary)
	VALUES (4, 20000.01);
INSERT INTO Full_time_emp (eid, monthly_salary)
	VALUES (5, 20000.01);
INSERT INTO Full_time_emp (eid, monthly_salary)
	VALUES (6, 20000.01);
INSERT INTO Full_time_emp (eid, monthly_salary)
	VALUES (7, 20000.01);
INSERT INTO Full_time_emp (eid, monthly_salary)
	VALUES (8, 20000.01);

INSERT INTO Instructors (eid)
	VALUES (1);
INSERT INTO Instructors (eid)
	VALUES (2);

INSERT INTO Part_time_instructors (eid)
	VALUES (1);
INSERT INTO Full_time_instructors (eid)
	VALUES (2);

INSERT INTO Managers (eid)
	VALUES (3);
INSERT INTO Managers (eid)
	VALUES (4);
INSERT INTO Administrators (eid)
	VALUES (5);
INSERT INTO Administrators (eid)
	VALUES (6)
INSERT INTO Administrators (eid)
	VALUES (7);
INSERT INTO Administrators (eid)
	VALUES (8);

INSERT INTO Rooms (location, seating_capacity)
	VALUES ('Room01_location', 100);
INSERT INTO Rooms (location, seating_capacity)
	VALUES ('Room02_location', 1);
/*INSERT INTO Rooms (location, seating_capacity)
	VALUES ('Room02_location', 100);*/

INSERT INTO Course_areas (course_area_name, eid)
	VALUES ('course_area_1', 3);
INSERT INTO Course_areas (course_area_name, eid)
	VALUES ('course_area_2', 4);

INSERT INTO Courses (duration, description, title, course_area_name) 
	VALUES (2, 'course1', 'course1', 'course_area_1');
INSERT INTO Courses (duration, description, title, course_area_name) 
	VALUES (2, 'course2', 'course2', 'course_area_2');



/*INSERT INTO Offerings (course_id, launch_date, start_date, end_date, reg_deadline, num_target_reg, seating_capacity, fees, eid)
	VALUES (1, DATE'2021-05-01', DATE'2021-05-01', DATE'2021-06-02', DATE'2021-04-21', 100, 200, 500, 5);*/
INSERT INTO Offerings (course_id, launch_date, start_date, end_date, reg_deadline, num_target_reg, seating_capacity, fees, eid)
	VALUES (1, DATE'2021-04-01', DATE'2021-05-01', DATE'2021-06-02', DATE'2021-04-21', 100, 200, 500, 5);
INSERT INTO Offerings (course_id, launch_date, start_date, end_date, reg_deadline, num_target_reg, seating_capacity, fees, eid)
	VALUES (1, DATE'2022-04-01', DATE'2022-05-01', DATE'2022-06-02', DATE'2022-04-21', 100, 200, 500, 6);
INSERT INTO Offerings (course_id, launch_date, start_date, end_date, reg_deadline, num_target_reg, seating_capacity, fees, eid)
	VALUES (2, DATE'2021-05-02', DATE'2021-05-02', DATE'2021-07-01', DATE'2021-04-22', 100, 200, 500, 6);


INSERT INTO Sessions (course_id, launch_date, sid, s_date, start_time, end_time, rid, eid)
	VALUES (1, DATE'2021-04-01', 1, DATE'2021-05-01', TIME'09:00:00', TIME'10:00:00', 1, 1);
INSERT INTO Sessions (course_id, launch_date, sid, s_date, start_time, end_time, rid, eid)
	VALUES (1, DATE'2021-04-01', 2, DATE'2021-05-07', TIME'09:00:00', TIME'10:00:00', 2, 1);
INSERT INTO Sessions (course_id, launch_date, sid, s_date, start_time, end_time, rid, eid)
	VALUES (2, DATE'2021-05-02', 1, DATE'2021-07-01', TIME'09:00:00', TIME'10:00:00', 1, 2);

INSERT INTO Customers (cust_name, phone, email, address)
	VALUES ('1234', 1234, '1234', '1234');
INSERT INTO Customers (cust_name, phone, email, address)
	VALUES ('4321', 4321, '4321', '4321');
	
INSERT INTO Credit_cards (number, CVV, expiry_date, cust_id, from_date)
	VALUES (12345678, 555, DATE'2023-01-01', 1, DATE'2000-01-01');
INSERT INTO Credit_cards (number, CVV, expiry_date, cust_id, from_date)
	VALUES (87654321, 555, DATE'2023-01-01', 1, DATE'2000-01-01');
INSERT INTO Credit_cards (number, CVV, expiry_date, cust_id, from_date)
	VALUES (05060708, 555, DATE'2023-01-01', 1, DATE'2000-01-01');
INSERT INTO Credit_cards (number, CVV, expiry_date, cust_id, from_date)
	VALUES (01020304, 555, DATE'2023-01-01', 2, DATE'2000-01-01');

INSERT INTO Registers (number, course_id, launch_date, sid, r_date) 
	VALUES (12345678, 1, DATE'2021-04-01', 1, CURRENT_DATE);
INSERT INTO Registers (number, course_id, launch_date, sid, r_date) 
	VALUES (01020304, 1, DATE'2021-04-01', 2, CURRENT_DATE);
INSERT INTO Registers (number, course_id, launch_date, sid, r_date) 
	VALUES (87654321, 2, DATE'2021-05-02', 1, CURRENT_DATE);




	
	

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	