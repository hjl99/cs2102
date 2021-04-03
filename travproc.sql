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
    min_seating_cap INTEGER;
    instructor_id INTEGER;
    i INTEGER := 0;
    sess_table RECORD;
    valid BOOLEAN := 1;
BEGIN
    -- WITH valid_instructors AS (
    --     SELECT eid
    --     FROM Instructors NATURAL JOIN Pay_slips
    --     WHERE coalesce(num_work_hours, 0) <= 30 
    --     EXCEPT 
    --     SELECT eid 
    --     FROM Instructors I, Instructors I2
    --     WHERE 
    -- )

    WHILE i < coalesce(array_length(sess, 1), 0) LOOP
    END LOOP;
    INSERT INTO Offerings VALUES (coid, cid, launch_date, NULL, NULL,
     reg_deadline, target_no, 0, fees, aid);
    --check primary key and eid not null
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

CALL add_course_offering(1, 1, 1.1,'2021-12-21','2021-11-21', 200, 1,
('2021-12-21','23:38:10',1),('2021-12-11','23:38:10',1));

-- CREATE OR REPLACE ROUTINE add_course_package()

