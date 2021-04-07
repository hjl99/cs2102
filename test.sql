/* Sample valid data */

/* All dates start from this month and increment accordingly. If an 'expired' date is needed
it's march*/
/* one-indexed. Rid increments by 1, Locations are a single capital letter increment by 1, 
seating capacity == rid*/
DELETE FROM Redeems;
DELETE FROM Registers;
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
CALL add_employee('pti_A2', 'addr_A2', 10000000, 'A2@A.com', 1.0, '2021-04-01', 'part time instructor', '{"course_area_A"}');
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
CALL add_course('course_A2', 'course_A2', 'course_area_A',4);    
/* Test case for 6 and 10 */
--first course offering we primarily concerned with
INSERT INTO Offerings VALUES
(1, '2021-03-01', '2021-04-01', '2021-04-11', '2021-03-10', 10, 10, 1.0, 11);
-- this offering is to make B have 1 hour left
INSERT INTO Offerings VALUES
(2, '2021-03-01', '2021-04-01', '2021-04-11', '2021-03-10', 10, 10, 1.0, 11);
INSERT INTO Sessions VALUES
(1, '2021-04-01', '09:00:00', 
'10:00:00', 1, '2021-03-01', 1, 4);
INSERT INTO Sessions VALUES
(3, '2021-04-01', '11:00:00', 
'12:00:00', 1, '2021-03-01', 1, 4);
-- make b hav 1 hr left
INSERT INTO Sessions VALUES
(1, '2021-04-02', '14:00:00', 
'18:00:00', 2, '2021-03-01', 2, 7);
INSERT INTO Sessions VALUES
(2, '2021-04-03', '14:00:00', 
'18:00:00', 2, '2021-03-01', 2, 7);
INSERT INTO Sessions VALUES
(3, '2021-04-04', '14:00:00', 
'18:00:00', 2, '2021-03-01', 2, 7);
INSERT INTO Sessions VALUES
(4, '2021-04-05', '14:00:00', 
'18:00:00', 2, '2021-03-01', 2, 7);
INSERT INTO Sessions VALUES
(5, '2021-04-06', '14:00:00', 
'18:00:00', 2, '2021-03-01', 2, 7);
INSERT INTO Sessions VALUES
(6, '2021-04-07', '14:00:00', 
'18:00:00', 2, '2021-03-01', 2, 7);
INSERT INTO Sessions VALUES
(7, '2021-04-08', '14:00:00', 
'18:00:00', 2, '2021-03-01', 2, 7);
INSERT INTO Sessions VALUES
(4, '2021-04-08', '14:00:00', 
'18:00:00', 1, '2021-03-01', 1, 7);


SELECT * FROM find_instructors(1,'2021-04-01','10:00');















DROP TYPE IF EXISTS Session CASCADE;
-- (session date, session start hour, and room identifier)
CREATE TYPE Session AS (
    start_date DATE,
    start_hr TIME,
    rid INTEGER
);
-- DROP PROCEDURE IF EXISTS add_course_offering;
CREATE OR REPLACE PROCEDURE add_course_offering(cid INTEGER, fees FLOAT,
launch_date DATE, reg_deadline DATE, target_no INTEGER, aid INTEGER, VARIADIC sess Session[]) AS $$
DECLARE
    course_and_area RECORD;
    instructor_id INTEGER;
    i INTEGER := 0;
    sess_table RECORD;
    start_date DATE;
    end_date DATE;
    cap INTEGER := 0;
    valid BOOLEAN := 1;
BEGIN
    set constraints offerings_fkey deferred;
    SELECT * INTO course_and_area FROM Courses WHERE course_id = cid;
    -- get_available_instructors(cid, sess[i].start_date, sess[i].start_date);
    FOR i IN 1 .. array_upper(sess,1) LOOP
        cap := cap + (SELECT seating_capacity FROM Rooms R
        WHERE R.rid = sess[i].rid);
        IF start_date IS NULL THEN start_date := sess[i].start_date;
        ELSIF start_date > sess[i].start_date THEN start_date:= sess[i].start_date;
        END IF;
        IF start_date IS NULL THEN end_date := sess[i].end_date;
        ELSIF end_date < sess[i].start_date THEN end_date:= sess[i].start_date;
        END IF;

        -- INSERT INTO Sessions VALUES
        -- (i, CURRENT_DATE, sess[i].start_hr, sess[i].start_hr + course_and_area.duration * INTERVAL '1 hour', 
        -- cid, launch_date, sess[i].rid, sess[i].instructor_id);
    END LOOP;
    INSERT INTO Offerings VALUES
    (cid, launch_date, start_date, end_date, reg_deadline, target_no, cap, fees, aid);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION helper1(i INTEGER)
RETURNS INTEGER AS $$
DECLARE 
j INTEGER;
BEGIN
    raise notice 'i is %', i;
    insert into Rooms values (i,'room_B', i);
    j := helper2(i);
    if j = 1 THEN
        raise notice 'hit';
        ROLLBACK;
        raise notice 'hit';
    end if;
    return 1;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION helper2(i INTEGER)
RETURNS INTEGER AS $$
DECLARE 
j INTEGER;
BEGIN
    i := i + 1;
    raise notice 'j is %', i;
    IF i = 4  THEN
        return 1;
    ELSE
        insert into Rooms values (i,'room_B', i);
        j := helper2(i);
        return j;
    END IF;
END;
$$ LANGUAGE plpgsql;
