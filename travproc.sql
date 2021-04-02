CREATE OR REPLACE PROCEDURE add_course(title TEXT, description TEXT, area TEXT, duration FLOAT)
LANGUAGE SQL 
AS $$
INSERT INTO  Courses VALUES (title, description, area, duration) VALUES (title, description, area, duration);
$$;

/*

CREATE OR REPLACE ROUTINE add_course_offering(coid INTEGER, cid INTEGER, fees FLOAT, ldate DATABASE,
deadline DATE, aid INTEGER, )





*/
CALL add_course("CS1231", "UWU MOD", "Computer Science", 1.5);
