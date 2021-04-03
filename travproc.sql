CREATE OR REPLACE PROCEDURE add_course(title TEXT, description TEXT, area TEXT, duration FLOAT) AS $$
DECLARE
    mid INTEGER;
BEGIN

    SELECT eid INTO mid FROM Course_areas WHERE name = area;
    IF mid IS NULL THEN 
        RAISE EXCEPTION 'No manager to the area %', area;
        return;
    END IF;
    INSERT INTO  Courses (title, description, duration, name)
    VALUES (title, description, duration, area);
END;
$$ LANGUAGE plpgsql;



DROP TYPE IF EXISTS Session CASCADE;
-- (session date, session start hour, and room identifier)
CREATE TYPE Session AS (
    start_dates DATE,
    start_hrs TIME,
    rid INTEGER
); 



CREATE OR REPLACE PROCEDURE add_course_offering(coid INTEGER, cid INTEGER, fees FLOAT,
launch_date DATE, reg_deadline DATE, target_no INTEGER, aid INTEGER, VARIADIC sess Session[]) AS $$
DECLARE
    temp_id INTEGER;
    course_area TEXT;
    min_seating_cap INTEGER;
    instructor_id INTEGER;
    i INTEGER := 0;
    sess_table RECORD;
    valid BOOLEAN := 1;
BEGIN
    course_area := (SELECT name FROM Courses WHERE course_id = cid);
--possible sol. generate an arr of set then eliminate.
    WHILE i < coalesce(array_length(sess, 1), 0) LOOP
        WITH avail_instructors AS (
            SELECT eid
            FROM Instructors NATURAL JOIN Pay_slips
            WHERE coalesce(num_work_hours, 0) <= 30 
        )
        SELECT eid into temp_id 
        FROM avail_instructors NATURAL JOIN Specializes 
        WHERE Course_areas = course_area;

        i := i + 1;
    END LOOP;
    -- INSERT INTO Offerings VALUES (coid, cid, launch_date, NULL, NULL,
    --  reg_deadline, target_no, 0, fees, aid);
    --check if exists valid instructor
    --check if target_no <= seating_cap
    -- min_seating_cap := (SELECT min(seating_capacity) FROM )
    RAISE EXCEPTION 'Invalid course offering information input';
END;
$$ LANGUAGE plpgsql;


-- test cases
-- insert into Rooms values (1,'A', 100);
-- insert into Rooms values (2,'B', 200);
-- insert into Rooms values (3,'C', 300);
-- insert into Rooms values (4,'D', 400);
-- insert into Rooms values (5,'E', 500);

-- insert into Sessions 

-- CALL add_course_offering(1, 1, 1.1,'2021-12-21','2021-11-21', 200, 1,
-- ('2021-12-21','23:38:10',1),('2021-12-11','23:38:10',1));
CREATE OR REPLACE PROCEDURE add_session(in_coid INTEGER, sess_id INTEGER, sess_day DATE,
                                sess_start TIME, eid INTEGER, rid INTEGER) AS $$
DECLARE 
    co RECORD;
BEGIN
    SELECT * into co FROM Offerings WHERE course_id = in_coid;
    IF sess_day < co.registration_deadline THEN
        RAISE EXCEPTION 'The registration should close before commencing';
    END IF;
    IF NOW() > co.registration_deadline THEN
        RAISE EXCEPTION 'Course offering’s registration deadline has passed';
    END IF;
    INSERT INTO Sessions VALUES 
    (sess_id, sess_day, sess_start, NULL, co.course_id, co.launch_date, rid, eid);
END;
$$ LANGUAGE plpgsql;

-- Delete from Employees CASCADE;
-- insert INTO Employees VALUES (9), (10), (11);
-- insert into Instructors VALUES (11);
-- insert into Full_time_emp VALUES (9), (10);
-- insert into Administrators VALUES (10);
-- insert into Managers VALUES (9);
-- insert into Course_areas VALUES ('area managed by 9', 9);
-- insert into Courses VALUES (10, 13, 'test', 'title 10', 'area managed by 9');
-- insert into Offerings VALUES (10, 10, '2021-02-01', '2021-02-15', NULL, '2021-02-15', 100,100, 100,10);
CALL add_session(10, 1, '2021-02-13', '20:21:00', 11, 1);
