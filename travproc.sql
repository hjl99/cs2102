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


-- CREATE OR REPLACE ROUTINE add_course_offering(coid INTEGER, cid INTEGER, fees FLOAT, ldate DATABASE,
-- deadline DATE, aid INTEGER, )

CALL add_course('CS1231', 'UWU MOD', 'Computer Science', 1.5);
