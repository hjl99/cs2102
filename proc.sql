/* 1 */
CREATE OR REPLACE PROCEDURE
add_employee(name TEXT, address TEXT, 
             phone INTEGER, email TEXT, 
             salary_or_hourly_rate FLOAT, join_date DATE, 
             category TEXT, course_areas TEXT[] DEFAULT ARRAY[]::TEXT[])
AS $$
  DECLARE
    curr_eid INTEGER;
	carea TEXT;
  BEGIN
  	IF (category != 'administrator' and category != 'manager'
        and category != 'part time instructor' and category != 'full time instructor')
    THEN
      RAISE EXCEPTION 'Please insert the correct category!';
    END IF;
	
    INSERT INTO Employees (name, phone, email, join_date, address)
    VALUES (name, phone, email, join_date, address) RETURNING eid INTO curr_eid;
   
    IF (category = 'part time instructor') THEN
	  IF (array_length(course_areas, 1) IS NULL) THEN
	  	RAISE EXCEPTION 'An instructor must specialize in some course areas!';	
	  END IF;
	  
      INSERT INTO Part_time_emp
      VALUES (curr_eid, salary_or_hourly_rate);
      INSERT INTO Instructors
      VALUES (curr_eid);       
      INSERT INTO Part_time_instructors 
      VALUES (curr_eid);
	  
	  FOREACH carea IN ARRAY course_areas LOOP
	  	INSERT INTO Specializes
		VALUES (curr_eid, carea);
	  END LOOP;
    ELSE
      INSERT INTO Full_time_emp
      VALUES (curr_eid, salary_or_hourly_rate);
      IF (category = 'administrator') THEN
	  	IF (array_length(course_areas, 1) > 0) THEN
			RAISE EXCEPTION 'An administrator must not specialize or manage any course areas!';
		END IF;
		
        INSERT INTO Administrators 
        VALUES (curr_eid);
      
	  ELSIF (category = 'manager') THEN
	  	IF (array_length(course_areas, 1) IS NULL) THEN
			RAISE EXCEPTION 'A manager must manages some course areas!';
		END IF;
		
        INSERT INTO Managers       
        VALUES (curr_eid);
		
		FOREACH carea IN ARRAY course_areas LOOP
			INSERT INTO Course_areas VALUES (carea, curr_eid);
		END LOOP;
      
	  ELSIF (category = 'full time instructor') THEN
	  	IF (array_length(course_areas, 1) IS NULL) THEN
			RAISE EXCEPTION 'An instructor must specializes in some course areas!';
		END IF;
	  
        INSERT INTO Instructors
        VALUES (curr_eid);
        INSERT INTO Full_time_instructors
        VALUES (curr_eid);
		
		FOREACH carea IN ARRAY course_areas LOOP
	  		INSERT INTO Specializes
			VALUES (curr_eid, carea);
	  	END LOOP;
      END IF;
    END IF;
  END;
$$ LANGUAGE plpgsql;

/* 2 */
CREATE OR REPLACE PROCEDURE remove_employee(reid INTEGER, depart_date DATE) 
AS $$
	BEGIN
		IF ((SELECT COUNT(*) FROM Offerings O WHERE reid = O.eid and depart_date < O.registration_deadline) > 0 
		   or (SELECT COUNT(*) FROM Conducts C WHERE reid = C.eid and depart_date < C.launch_date) > 0
		   or (SELECT COUNT(*) FROM Course_areas CA WHERE reid = CA.eid) > 0)
		THEN RAISE EXCEPTION 'Employee cannot be removed!';
		ELSE
			UPDATE Employees E SET E.depart_date = depart_date WHERE E.eid = reid; 
		END IF;
	END;
$$ LANGUAGE plpgsql;

/* 3 */
CREATE OR REPLACE FUNCTION add_customer(cname TEXT, caddress TEXT, cphone INTEGER, cemail TEXT, cnumber INTEGER, cexpiry_date DATE, ccvv INTEGER)
	RETURNS VOID 
AS $$
DECLARE 
	cid INTEGER;
BEGIN
    INSERT INTO Customers (name, address, phone, email)
    VALUES (cname, caddress, cphone, cemail) RETURNING cust_id INTO cid;
	INSERT INTO Credit_cards(number, expiry_date, CVV, cust_id)
	VALUES (cnumber, cexpiry_date, ccvv, cid);
END;
$$ LANGUAGE plpgsql;

/* 4 */
CREATE OR REPLACE FUNCTION update_credit_card(cid INTEGER, cnumber INTEGER, cexpiry_date DATE, ccvv INTEGER)
	RETURNS VOID 
AS $$
BEGIN
	INSERT INTO Credit_cards(number, expiry_date, CVV, cust_id)
	VALUES (cnumber, cexpiry_date, ccvv, cid);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION find_instructors(cid INTEGER, cnumber INTEGER, cexpiry_date DATE, ccvv INTEGER)
	RETURNS VOID 
AS $$
BEGIN
END;
$$ LANGUAGE plpgsql;


/* 5 */
CREATE OR REPLACE PROCEDURE add_course(title TEXT, description TEXT, area TEXT, duration INTEGER) AS $$
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

/* 6 */
CREATE OR REPLACE FUNCTION find_instructors(course_id INTEGER, sess_date DATE, sess_start_hour TIME)
RETURNS TABLE(eid INTEGER, name TEXT) AS $$
	SELECT I.eid, I.name
	FROM Instructors I
	WHERE NOT EXISTS (SELECT 1
					 FROM Sessions S
					 WHERE I.eid = S.eid
					 and sess_date = S.date
					 and (sess_start_hour >= S.start_time and sess_start_hour < S.end_time));
$$ LANGUAGE plpgsql;

/* 8 */
CREATE OR REPLACE FUNCTION find_rooms(sess_date DATE, sess_start_hour TIME, sess_duration INTEGER)
RETURNS TABLE(rid INTEGER) AS $$
DECLARE
	sess_end_hour TIME;
BEGIN
	sess_end_hour := sess_start_hour + sess_duration * INTERVAL '1 hour';
	SELECT R.rid
	FROM Rooms R
	WHERE NOT EXISTS (SELECT 1 
					 FROM Sessions S
					 WHERE R.rid = S.rid 
					  and S.date = sess_date 
					  and ((sess_start_hour >= S.start_time and sess_start_hour < S.end_time) 
						   or (sess_end_hour > S.start_time and sess_end_hour <= S.end_time)));
END;
$$ LANGUAGE plpgsql;

/* 12 */
CREATE OR REPLACE FUNCTION get_available_course_packages()
RETURNS TABLE (LIKE Course_packages) AS $$
	SELECT * 
	FROM Course_packages
	WHERE sale_end_date >= CURRENT_DATE and CURRENT_DATE >= sale_start_date;
$$ LANGUAGE sql;

/* 13 */
CREATE OR REPLACE FUNCTION buy_course_package(cid INTEGER, pid INTEGER)
RETURNS VOID AS $$
DECLARE
	cnum INTEGER;
	rnum INTEGER;
BEGIN
	cnum := (SELECT number FROM Credit_cards WHERE cust_id=cid ORDER BY from_date DESC LIMIT 1);
	IF NOT EXISTS (SELECT * FROM Buys WHERE number=cnum and num_remaining_redemptions > 0) and 
		(pid IN (SELECT package_id FROM get_available_course_packages())) THEN
		rnum := (SELECT num_free_registrations FROM get_available_course_packages() WHERE package_id=pid);
		INSERT INTO Buys (number, package_id, num_remaining_redemptions) VALUES (cnum, pid, rnum);
	END IF;
END;
$$ LANGUAGE plpgsql;

/* 14 */
CREATE OR REPLACE FUNCTION get_my_course_package(cid INTEGER)
RETURNS json AS $$
DECLARE
	cust_num INTEGER;
	package_info RECORD;
	buy_info RECORD;
BEGIN
	cust_num := (SELECT number FROM Credit_cards WHERE cust_id=cid ORDER BY from_date DESC LIMIT 1);
	SELECT num_remaining_redemptions, b_date, package_id INTO buy_info FROM Buys WHERE number=cust_num ORDER BY b_date DESC LIMIT 1;
	CREATE TEMP TABLE IF NOT EXISTS tmp AS SELECT name, price, num_free_registrations, num_remaining_redemptions, b_date
					 FROM Course_packages NATURAL JOIN Buys WHERE Buys.number=cust_num ORDER BY b_date DESC LIMIT 1;
	CREATE TEMP TABLE IF NOT EXISTS tmp2 AS SELECT (SELECT title FROM Courses C WHERE C.course_id=R.course_id) AS title,
	(SELECT date FROM Sessions C WHERE C.sid=R.sid and C.course_id=R.course_id and C.launch_date=R.launch_date
	and C.rid=R.rid and C.eid=R.eid) AS session_date,
	(SELECT start_time FROM Sessions C WHERE C.sid=R.sid and C.course_id=R.course_id and C.launch_date=R.launch_date
	and C.rid=R.rid and C.eid=R.eid) AS start_time
	FROM Redeems R
	WHERE package_id=buy_info.package_id and number=cust_num and b_date=buy_info.b_date
	ORDER BY session_date ASC, start_time ASC;
	RETURN (SELECT row_to_json(t)
	FROM (
		SELECT name, price, num_free_registrations, num_remaining_redemptions, b_date,
		(
			SELECT array_to_json(array_agg(row_to_json(d)))
			FROM (
				SELECT title, session_date, start_time
				FROM tmp2
			) d
		) as redeemed_session_information
		FROM tmp
	) t);
	DROP TABLE tmp, tmp2;
END;
$$ LANGUAGE plpgsql;


/* 24 */
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