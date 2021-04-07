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
CALL add_employee('m_D', 'addr_D', 30000000, 'D@D.com', 300.0, '2021-04-03', 'manager', '{"course_area_qn10"}');
CALL add_employee('pti_A', 'addr_A', 10000000, 'A@A.com', 1.0, '2021-04-01', 'part time instructor', '{"course_area_A"}');
CALL add_employee('pti_B', 'addr_B', 20000000, 'B@B.com', 2.0, '2021-04-02', 'part time instructor', '{"course_area_B"}');
CALL add_employee('pti_C', 'addr_C', 30000000, 'C@C.com', 3.0, '2021-04-03', 'part time instructor', '{"course_area_C"}');
CALL add_employee('pti_D', 'addr_D', 10000000, 'D@D.com', 1.0, '2021-04-01', 'part time instructor', '{"course_area_qn10"}');
CALL add_employee('pti_D2', 'addr_D2', 10000000, 'D2@D.com', 1.0, '2021-04-01', 'part time instructor', '{"course_area_qn10"}');
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
CALL add_course('course_D2', 'course_D2', 'course_area_qn10',4);  
CALL add_course('course_D', 'course_D', 'course_area_qn10',1);   
  

/* Test case for 6 and 10 */
INSERT INTO Offerings VALUES
(2, '2021-03-01', '2021-04-01', '2021-04-11', '2021-03-10', 10, 10, 1.0, 13);

/* ------------------------------- Assign sessions ----------------------------- */
INSERT INTO Sessions (sid, s_date, start_time, end_time, course_id ,
    launch_date, rid, eid)
VALUES
(9, '2021-04-01', '09:00:00', 
'10:00:00', 2, '2021-03-01', 1, 9);
INSERT INTO Sessions VALUES
(10, '2021-04-01', '11:00:00', 
'12:00:00', 2, '2021-03-01', 1, 9);
/* -------------- make 7 have 1 hr left --------------*/
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
/* -----------------------------------------------*/

SELECT eid as iid, sum(EXTRACT(epoch from (end_time-start_time))/3600) as hours
FROM Sessions
GROUP BY eid;

SELECT * FROM find_instructors(3, '2021-04-02', '09:00:00');
SELECT * FROM find_instructors(3, '2021-04-01', '10:00:00');


DROP TYPE IF EXISTS Session CASCADE;
-- (session date, session start hour, and room identifier)
CREATE TYPE Session AS (
    start_date DATE,
    start_hr TIME,
    rid INTEGER
);
CREATE OR REPLACE FUNCTION 
CREATE OR REPLACE FUNCTION helper(sess Session[], idx INTEGER, duration INTEGER, cid INTEGER, in_launch_date DATE)--, idx, duration, cid, launch_date
RETURNS INTEGER AS $$
DECLARE 
i INTEGER;
j INTEGER;
res INTEGER;
sum INTEGER;
temp RECORD;
BEGIN
    IF array_length(sess, 1) IS NULL THEN return 0; END IF;
    FOR i IN 1 .. array_upper(sess,1) LOOP
        select count(*) into sum from find_instructors(cid, sess[i].start_date, sess[i].start_hr);
        raise notice 'sum is % %', sum, idx;
        j := 0;
        FOR j IN 1 .. sum LOOP
            SELECT * INTO temp FROM find_instructors(cid, sess[i].start_date, sess[i].start_hr)
            offset (j - 1) limit 1;
            raise notice 'inserting % %', temp.out_eid, temp.name;
            INSERT INTO Sessions VALUES 
            (idx, sess[i].start_date, sess[i].start_hr, sess[i].start_hr + duration * INTERVAL '1 hour',
            cid, in_launch_date, sess[i].rid, temp.out_eid);
            res := helper(sess[2:array_length(sess,1)], idx + 1, duration, cid, in_launch_date);
            IF res = 1 THEN
                raise notice 'rewinding %', idx;
                DELETE FROM Sessions WHERE sid = idx and course_id = cid and launch_date = in_launch_date;
            ELSE 
                return 0;
            END IF;
        END LOOP;
    END LOOP;
    return 1;
END;
$$ LANGUAGE plpgsql;
-- DROP PROCEDURE IF EXISTS add_course_offering;
CREATE OR REPLACE PROCEDURE add_course_offering(cid INTEGER, fees FLOAT,
launch_date DATE, reg_deadline DATE, target_no INTEGER, aid INTEGER, VARIADIC sess Session[]) AS $$
DECLARE
    course_and_area RECORD;
    i INTEGER := 0;
    start_date DATE;
    end_date DATE;
    cap INTEGER := 0;
    res INTEGER := 0;
BEGIN
    set constraints offerings_fkey deferred;
    SELECT * INTO course_and_area FROM Courses 
    WHERE course_id = cid;
    res := helper(sess, 1, course_and_area.duration, cid, launch_date);
    FOR i IN 1 .. array_upper(sess,1) LOOP
        cap := cap + (SELECT seating_capacity FROM Rooms R
        WHERE R.rid = sess[i].rid);
        IF start_date IS NULL THEN start_date := sess[i].start_date;
        ELSIF start_date > sess[i].start_date THEN start_date:= sess[i].start_date;
        END IF;
        IF start_date IS NULL THEN end_date := sess[i].end_date;
        ELSIF end_date < sess[i].start_date THEN end_date:= sess[i].start_date;
        END IF;
    END LOOP;
    INSERT INTO Offerings VALUES
    (cid, launch_date, start_date, end_date, reg_deadline, target_no, cap, fees, aid);
END;
$$ LANGUAGE plpgsql;


CALL add_course_offering(3, 1.0,'2021-03-02','2021-03-15', 2, 13, 
('2021-04-02', '09:00:00', 2), ('2021-04-02', '10:00:00', 1), ('2021-04-02', '11:00:00', 2));    