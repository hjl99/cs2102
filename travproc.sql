DROP TYPE IF EXISTS Session CASCADE;
-- (session date, session start hour, and room identifier)
CREATE TYPE Session AS (
    start_date DATE,
    start_hr TIME,
    rid INTEGER
);

CREATE OR REPLACE PROCEDURE add_course_offering(coid INTEGER, cid INTEGER, fees FLOAT,
launch_date DATE, reg_deadline DATE, target_no INTEGER, aid INTEGER, VARIADIC sess Session[]) AS $$
DECLARE
    course_and_area RECORD;
    temp_id INTEGER;
    min_seating_cap INTEGER;
    instructor_id INTEGER;
    i INTEGER := 0;
    sess_table RECORD;
    valid BOOLEAN := 1;
BEGIN
    course_and_area := (SELECT * FROM Courses NATURAL JOIN course_areas
    WHERE course_id = cid);
    -- insert sessions
    WHILE i < coalesce(array_length(sess, 1), 0) LOOP
        -- add_session(coid, i+1, start)
        i := i + 1;
    END LOOP;
        -- WITH avail_instructors AS (
        --     SELECT eid
        --     FROM Instructors NATURAL JOIN Pay_slips
        --     WHERE coalesce(num_work_hours, 0) <= 30 
        -- )
        -- SELECT eid into temp_id 
        -- FROM avail_instructors NATURAL JOIN Specializes 
        -- WHERE Course_areas = course_area;
    -- INSERT INTO Offerings VALUES (coid, cid, launch_date, NULL, NULL,
    --  reg_deadline, target_no, 0, fees, aid);
    --check if exists valid instructor
    --check if target_no <= seating_cap
    -- min_seating_cap := (SELECT min(seating_capacity) FROM )
    RAISE EXCEPTION 'Invalid course offering information input';
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE add_session(in_coid INTEGER, sess_id INTEGER, sess_day DATE,
                                sess_start TIME, eid INTEGER, rid INTEGER) AS $$
DECLARE 
    c_and_co RECORD;
BEGIN
    SELECT * into c_and_co FROM Offerings NATURAL JOIN Courses WHERE course_id = in_coid;
    -- IF sess_day < c_and_co.registration_deadline THEN
    --     RAISE EXCEPTION 'The registration should close before commencing';
    -- END IF;
    -- IF NOW() > c_and_co.registration_deadline THEN
    --     RAISE EXCEPTION 'Course offering’s registration deadline has passed';
    -- END IF;
    INSERT INTO Sessions VALUES 
    (sess_id, sess_day, sess_start, sess_start + interval '1 hour' * c_and_co.duration, c_and_co.course_id, c_and_co.launch_date,
    rid, eid);
END;
$$ LANGUAGE plpgsql;

-- insert into Sessions 

-- CALL add_course_offering(1, 1, 1.1,'2021-12-21','2021-11-21', 200, 1,
-- ('2021-12-21','23:38:10',1),('2021-12-11','23:38:10',1));

-- test cases
-- insert into Rooms values (1,'A', 100);
-- insert into Rooms values (2,'B', 200);
-- insert into Rooms values (3,'C', 300);
-- insert into Rooms values (4,'D', 400);
-- insert into Rooms values (5,'E', 500);
-- Delete from Employees CASCADE;
-- insert INTO Employees VALUES (9), (10), (11);
-- insert into Instructors VALUES (11);
-- insert into Full_time_emp VALUES (9), (10);
-- insert into Administrators VALUES (10);
-- insert into Managers VALUES (9);
-- insert into Course_areas VALUES ('area managed by 9', 9);
-- insert into Courses VALUES (10, 13, 'test', 'title 10', 'area managed by 9');
-- insert into Offerings VALUES (10, 10, '2021-02-01', '2021-02-15', NULL, '2021-02-15', 100,100, 100,10);
-- CALL add_session(10, 1, '2021-02-13', '20:00:00', 11, 1);

DROP FUNCTION IF EXISTS get_available_instructors;
CREATE OR REPLACE FUNCTION get_available_instructors(cid INTEGER, start_date DATE, end_date DATE)
RETURNS TABLE(e_id INTEGER, i_name TEXT, total_hrs_for_month INTEGER, day INTEGER, hours TIME[]) AS $$
DECLARE
    curr record;
    timings TIME[] := ARRAY['09:00','10:00', '11:00', '14:00', '15:00', '16:00', '17:00'];
    curs CURSOR FOR (
        SELECT DISTINCT eid FROM Specializes NATURAL JOIN Courses
        WHERE course_id = cid
    );
    i integer := date_part('day', start_date);
    j integer := 1;
    k integer := 0;
    timing TIME;
BEGIN
    CREATE TEMP TABLE IF NOT EXISTS temp_table AS
        SELECT Instructors.eid as e1, E.name as n1, num_work_hours as w1, date_part('day', S.date) as day, 
        start_time as t1, EXTRACT(epoch from (end_time-start_time))/3600 as duration
        FROM Instructors NATURAL JOIN Specializes Spec NATURAL JOIN Courses C 
        NATURAL JOIN Pay_slips P NATURAL JOIN Sessions S JOIN Employees E on E.eid = Instructors.eid
        WHERE course_id = cid and date_part('month', payment_date) = date_part('month', end_date) 
        ORDER BY Instructors.eid, day;
    FOR record IN curs LOOP
        raise notice 'it is %', record.eid;
        i := date_part('day', start_date);
        WHILE i <= date_part('day', end_date) LOOP
            If exists (SELECT * FROM temp_table WHERE temp_table.day = i) THEN
                SELECT * INTO curr FROM temp_table 
                where temp_table.e1 = record.eid and temp_table.day = i;
                e_id := curr.e1;
                i_name := curr.n1;
                total_hrs_for_month := curr.w1;
                day := i;
                hours := timings;
                WHILE k < (SELECT count(*) FROM temp_table 
                WHERE temp_table.e1 = record.eid and temp_table.day = i) LOOP
                    raise notice 'k is %', k;
                    SELECT * INTO curr FROM temp_table 
                    where temp_table.e1 = record.eid and temp_table.day = i OFFSET k;
                    FOREACH timing IN ARRAY hours LOOP
                        IF timing = curr.t1 THEN
                            hours :=  hours[1: j-1]||hours[j + curr.duration:];
                            EXIT;
                        END IF;
                        j:=j+1;
                    END LOOP;
                    k:=k+1;
                END LOOP;
                k:=0;
                j:=1;
                RETURN NEXT;
            ELSE
                SELECT * INTO curr FROM temp_table where temp_table.e1 = record.eid LIMIT 1;
                e_id := curr.e1;
                i_name := curr.n1;
                total_hrs_for_month := curr.w1;
                day := i;
                hours := timings;
                RETURN next;
            END IF; 
            i := i + 1;
        END LOOP;
    END LOOP;
    DROP TABLE temp_table;
END;
$$ LANGUAGE plpgsql;

-- insert INTO Employees VALUES (20), (21), (22);
-- insert into Instructors VALUES (20), (21), (22);
-- CALL add_session(10, 1, '2021-04-01',
--                     '10:00', 20, 1);
-- CALL add_session(10, 1, '2021-04-01',
--                     '10:00', 21, 1);
-- CALL add_session(10, 2, '2021-04-01',
--                     '15:00', 20, 1);
-- insert into Pay_slips VALUES (10,'2021-04-30', 2000, 3, 0);
-- insert into Pay_slips VALUES (20,'2021-04-30', 2000, 3, 0);
-- insert into Pay_slips VALUES (21,'2021-04-30', 4000, 2, 0);
-- insert into Specializes VALUES (20, 'area managed by 9');
-- insert into Specializes VALUES (21, 'area managed by 9');
-- insert into Specializes VALUES (20, 'area managed by 9');
-- SELECT eid, E.name, num_work_hours, date_part('day', S.date) as day, start_time, 
-- (end_time-start_time) as duration
-- FROM Specializes NATURAL JOIN Courses NATURAL JOIN Pay_slips NATURAL JOIN Sessions S 
-- NATURAL JOIN Employees E
-- ORDER BY eid, day
SELECT * from get_available_instructors(10, '2021-04-01', '2021-04-04');


-- CREATE OR REPLACE FUNCTION get_available_instructors(cid INTEGER, start_date DATE, end_date DATE)
-- RETURNS TABLE(e_id INTEGER, i_name TEXT, total_hrs_for_month INTEGER, day DATE, hours TIME[]) AS $$
-- DECLARE
--     curr record;
--     r record;
--     curs CURSOR FOR (
--         SELECT E.eid
--         FROM Employees E
--     );
--     -- curs CURSOR FOR (
--     --     SELECT eid, E.name, num_work_hours, date_part('day', S.date) as day, start_time, (end_time-start_time)/ INTERVAL '1 hour'as duration
--     --     FROM Specializes NATURAL JOIN Courses NATURAL JOIN Pay_slips NATURAL JOIN Sessions S 
--     --     NATURAL JOIN Employees E
--     --     WHERE course_id = coid and date_part('month', payment_date) = date_part('month', end_date) 
--     --     ORDER BY eid, day
--     -- );
-- BEGIN
--     OPEN curs;
--     LOOP
--         e_id
--         EXIT WHEN NOT FOUND
--     END LOOP
--     CLOSE curs;

-- END;
-- $$ LANGUAGE plpgsql;
