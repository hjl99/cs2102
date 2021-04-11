/* FOR Function 18, 19, 20, 21, 25, 27, 28, 29, 30 */ 

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

INSERT INTO Employees (name, phone, email, join_date, address, depart_date) VALUES 
	('Part_time_instr_01', 01010101, 'employee01@gmail.com', DATE'2020-01-01', 'address_employee_01', NULL),
	('Full_time_instr_01', 02020202, 'employee02@gmail.com', DATE'2020-12-31', 'address_employee_02', DATE'2021-04-11'),
	('Manager_01', 03030303, 'employee03@gmail.com', DATE'2020-01-01', 'address_employee_03', NULL),
	('Manager_02', 04040404, 'employee04@gmail.com', DATE'2020-01-01', 'address_employee_04', NULL),
	('Administrator_01', 05050505, 'employee05@gmail.com', DATE'2020-01-01', 'address_employee_05', NULL),
	('Administrator_02', 06060606, 'employee06@gmail.com', DATE'2020-01-01', 'address_employee_06', NULL),
	('Administrator_03', 07070707, 'employee07@gmail.com', CURRENT_DATE, 'address_employee_06', NULL),
	('Administrator_04', 08080808, 'employee08@gmail.com', DATE'2020-01-01', 'address_employee_06', CURRENT_DATE);

INSERT INTO Part_time_emp (eid, hourly_rate) VALUES 
	(1, 100.01);
	
INSERT INTO Full_time_emp (eid, monthly_salary) VALUES
	(2, 20000.01),
	(3, 10000.01),
	(4, 20000.01),
	(5, 20000.01),
	(6, 20000.01),
	(7, 20000.01),
	(8, 20000.01);

INSERT INTO Instructors (eid) VALUES 
	(1),
	(2);

INSERT INTO Part_time_instructors (eid) VALUES 
	(1);

INSERT INTO Full_time_instructors (eid) VALUES 
	(2);

INSERT INTO Managers (eid)VALUES
	(3),
	(4);

INSERT INTO Administrators (eid) VALUES
	(5),
	(6),
	(7),
	(8);

INSERT INTO Customers (cust_name, phone, email, address) VALUES
	('1', 11, '111', '1111'),
	('2', 22, '222', '2222'),
	('3', 33, '333', '3333'),
	('4', 44, '444', '4444'),
	('5', 55, '555', '5555'),
	('6', 66, '666', '6666'),
	('7', 77, '777', '7777');
	
INSERT INTO Credit_cards (number, CVV, expiry_date, cust_id, from_date) VALUES
	-- Customer 1
	(11111111, 555, DATE'2023-01-01', 1, DATE'2000-01-01'),
	(11111112, 555, DATE'2023-01-01', 1, DATE'2000-01-01'),
	(11111113, 555, DATE'2023-01-01', 1, DATE'2000-01-01'),
	-- Customer 2
	(21111111, 555, DATE'2023-01-01', 2, DATE'2000-01-01'),
	-- Customer 3
	(31111111, 555, DATE'2023-01-01', 3, DATE'2000-01-01'),
	-- Customer 4
	(41111111, 555, DATE'2023-01-01', 4, DATE'2000-01-01'),
	-- Customer 5
	(51111111, 555, DATE'2023-01-01', 5, DATE'2000-01-01'),
	-- Customer 6
	(61111111, 555, DATE'2023-01-01', 6, DATE'2000-01-01'),
	-- Customer 7
	(71111111, 555, DATE'2023-01-01', 7, DATE'2000-01-01');

INSERT INTO Rooms (location, seating_capacity) VALUES 
	-- Room 1
	('Room01_location', 100),
	-- Room 2
	('Room02_location', 100);

INSERT INTO Course_areas (course_area_name, eid) VALUES
	-- Course Area 1
	('course_area_1', 3),
	-- Course Area 2
	('course_area_2', 4);

INSERT INTO Courses (duration, description, title, course_area_name) VALUES
	-- Course 1
	(2, 'course1', 'course1', 'course_area_1'),
	-- Course 2
	(2, 'course2', 'course2', 'course_area_2');

INSERT INTO Course_packages (sale_start_date, num_free_registrations, sale_end_date, package_name, price) VALUES
	(DATE'2021-01-01', 1, DATE'2021-05-01', '0101-0501-1', 100),
	(DATE'2021-01-01', 2, DATE'2021-05-01', '0101-0501-2', 200),
	(DATE'2021-01-01', 3, DATE'2021-05-01', '0101-0501-3', 300),
	(DATE'2021-01-01', 4, DATE'2021-05-01', '0101-0501-4', 400),
	(DATE'2021-01-01', 5, DATE'2021-05-01', '0101-0501-5', 500);

INSERT INTO Offerings (course_id, launch_date, start_date, end_date, reg_deadline, num_target_reg, seating_capacity, fees, eid) VALUES
	-- Course 1, ending this year
	(1, DATE'2021-03-01', DATE'2021-04-01', DATE'2021-04-30', DATE'2021-03-22', 300, 300, 500, 5),
	(1, DATE'2021-03-02', DATE'2021-10-01', DATE'2021-10-01', DATE'2021-09-21', 100, 100, 500, 6),
	-- Course 1, ending next year
	(1, DATE'2022-03-03', DATE'2022-05-01', DATE'2022-06-02', DATE'2022-04-21', 200, 200, 500, 6),
	-- Course 2
	(2, DATE'2021-04-01', DATE'2021-04-02', DATE'2021-04-02', DATE'2021-03-23', 100, 100, 500, 6),
	(2, DATE'2021-04-02', DATE'2021-05-02', DATE'2021-05-02', DATE'2021-04-22', 100, 100, 500, 5);

INSERT INTO Sessions (course_id, launch_date, sid, s_date, start_time, end_time, rid, eid) VALUES
	-- Course 1 Offering 1	
	(1, DATE'2021-03-01', 1, DATE'2021-04-01', TIME'09:00:00', TIME'10:00:00', 1, 1), 
	(1, DATE'2021-03-01', 2, DATE'2021-04-01', TIME'15:00:00', TIME'16:00:00', 2, 2), 
	(1, DATE'2021-03-01', 3, DATE'2021-04-11', TIME'09:00:00', TIME'10:00:00', 1, 2), -- session starting tmr
	(1, DATE'2021-03-01', 4, DATE'2021-04-30', TIME'09:00:00', TIME'10:00:00', 1, 2), -- session starting after 7 days
	-- Course 1 Offering 2	
	(1, DATE'2021-03-02', 1, DATE'2021-10-01', TIME'09:00:00', TIME'10:00:00', 1, 1),
	-- Course 1 Offering 3	
	(1, DATE'2022-03-03', 1, DATE'2022-05-01', TIME'09:00:00', TIME'10:00:00', 2, 1),
	(1, DATE'2022-03-03', 2, DATE'2022-06-02', TIME'09:00:00', TIME'10:00:00', 1, 2),
	-- Course 2 Offering 1	
	(2, DATE'2021-04-01', 1, DATE'2021-04-02', TIME'09:00:00', TIME'10:00:00', 1, 1),
	-- Course 2 Offering 2	
	(2, DATE'2021-04-02', 1, DATE'2021-07-01', TIME'09:00:00', TIME'10:00:00', 2, 2);

INSERT INTO Registers (number, course_id, launch_date, sid, r_date) VALUES
	-- Course 1 Offering 1 Session 1
	(11111111, 1, DATE'2021-03-01', 1, DATE'2021-03-01'), -- Redeem
	(21111111, 1, DATE'2021-03-01', 1, DATE'2021-03-01'), -- Card
	-- Course 1 Offering 1 Session 3
	(31111111, 1, DATE'2021-03-01', 3, DATE'2021-03-01'), -- Card
	(51111111, 1, DATE'2021-03-01', 3, DATE'2021-03-01'), -- Redeem
	-- Course 1 Offering 1 Session 4
	(61111111, 1, DATE'2021-03-01', 4, DATE'2021-03-01'), -- Card
	(71111111, 1, DATE'2021-03-01', 4, DATE'2021-03-01'), -- Redeem
	-- Course 1 Offering 2 Session 1
	(41111111, 1, DATE'2021-03-02', 1, DATE'2021-04-01'), -- Card
	-- Course 2 Offering 1 Session 1
	(11111112, 2, DATE'2021-04-02', 1, DATE'2021-04-02'), -- Card
	(41111111, 2, DATE'2021-04-02', 1, DATE'2021-04-02'); -- Redeem

INSERT INTO Buys (package_id, number, b_date, num_remaining_redemptions) VALUES
	(1, 11111113, DATE'2021-01-01', 0), -- After 1 redemption
	(5, 21111111, DATE'2021-01-01', 5), -- No redemption
	(5, 41111111, DATE'2021-01-01', 4), -- After 1 redemption
	(5, 51111111, DATE'2021-01-01', 4), -- After 1 redemption
	(5, 71111111, DATE'2021-01-01', 4); -- After 1 redemption

INSERT INTO Redeems (package_id, number, b_date, r_date, course_id, launch_date, sid) VALUES
	-- Customer 1, Course 1 Offering 1 Session 1
	(1, 11111113, DATE'2021-01-01', DATE'2021-03-01', 1, DATE'2021-03-01', 1),
	-- Customer 5, Course 1 Offering 1 Session 3
	(5, 51111111, DATE'2021-01-01', DATE'2021-03-01', 1, DATE'2021-03-01', 3),
	-- Customer 7, Course 1 Offering 1 Session 4
	(5, 71111111, DATE'2021-01-01', DATE'2021-03-01', 1, DATE'2021-03-01', 4),
	-- Customer 4, Course 2 Offering 1 Session 1
	(5, 41111111, DATE'2021-01-01', DATE'2021-04-02', 2, DATE'2021-04-02', 1);

/* 18 */
SELECT get_my_registrations(1);

/* 19 */
CALL update_course_session(1, 1, '2021-03-01', 8000);

/* 20 */

/* 21 */

/* 22 */