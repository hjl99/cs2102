/* 1  TESTED*/
CREATE OR REPLACE PROCEDURE
add_employee(name TEXT, address TEXT, phone INTEGER, email TEXT, 
             salary_or_hourly_rate FLOAT, join_date DATE, category TEXT, 
             course_areas TEXT[] DEFAULT ARRAY[]::TEXT[])
AS $$
DECLARE
curr_eid INTEGER;
carea TEXT;
BEGIN
  	IF (category != 'administrator' and category != 'manager'
        and category != 'part time instructor' and category != 'full time instructor')
    THEN
      RAISE EXCEPTION 'Please insert the correct category! E.G. "administrator", 
      "manager", "part time instructor" or "full time instructor"';
    END IF;

    INSERT INTO Employees (name, phone, email, join_date, address)
    VALUES (name, phone, email, join_date, address) RETURNING eid INTO curr_eid;

    IF (category = 'part time instructor') THEN
        IF (array_length(course_areas, 1) IS NULL) THEN
        RAISE EXCEPTION 'An instructor must specialize in some course areas!';	
        END IF;
        
        INSERT INTO Part_time_emp VALUES (curr_eid, salary_or_hourly_rate);
        INSERT INTO Instructors VALUES (curr_eid);       
        INSERT INTO Part_time_instructors VALUES (curr_eid);
        
        FOREACH carea IN ARRAY course_areas LOOP
            INSERT INTO Specializes VALUES (curr_eid, carea);
        END LOOP;
    ELSE
        INSERT INTO Full_time_emp VALUES (curr_eid, salary_or_hourly_rate);
        IF (category = 'administrator') THEN
            IF (array_length(course_areas, 1) > 0) THEN
                RAISE EXCEPTION 'An administrator must not specialize or manage any course areas!';
            END IF;
            INSERT INTO Administrators VALUES (curr_eid);
        ELSIF (category = 'manager') THEN
            IF (array_length(course_areas, 1) IS NULL) THEN
                RAISE EXCEPTION 'A manager must manage some course areas!';
           END IF;
            INSERT INTO Managers VALUES (curr_eid);
            FOREACH carea IN ARRAY course_areas LOOP
                INSERT INTO Course_areas VALUES (carea, curr_eid);
            END LOOP;
        ELSIF (category = 'full time instructor') THEN
            IF (array_length(course_areas, 1) IS NULL) THEN
                RAISE EXCEPTION 'An instructor must specialize in some course areas!';
            END IF;
            INSERT INTO Instructors VALUES (curr_eid);
            INSERT INTO Full_time_instructors VALUES (curr_eid);
            FOREACH carea IN ARRAY course_areas LOOP
                INSERT INTO Specializes VALUES (curr_eid, carea);
            END LOOP;
        ELSE 
            RAISE EXCEPTION 'Something wrong happened on our side';
        END IF;
    END IF;
END;
$$ LANGUAGE plpgsql;

/* 2 */
CREATE OR REPLACE PROCEDURE remove_employee(reid INTEGER, depart_date DATE) 
AS $$
BEGIN
    IF (SELECT COUNT(*) FROM Offerings O WHERE reid = O.eid and depart_date < O.registration_deadline) > 0 
        or (SELECT COUNT(*) FROM Sessions WHERE reid = eid and depart_date < start_date) > 0
        or (SELECT COUNT(*) FROM Course_areas CA WHERE reid = CA.eid) > 0
    THEN 
        RAISE EXCEPTION 'Employee cannot be removed!';
    ELSE
        UPDATE Employees E SET E.depart_date = depart_date WHERE E.eid = reid; 
    END IF;
END;
$$ LANGUAGE plpgsql;

/* 3 TESTED*/
CREATE OR REPLACE PROCEDURE add_customer(cname TEXT, caddress TEXT, cphone INTEGER,
                        cemail TEXT, cnumber INTEGER, cexpiry_date DATE, ccvv INTEGER)
AS $$
DECLARE 
	cid INTEGER;
BEGIN
    INSERT INTO Customers (cust_name, address, phone, email)
    VALUES (cname, caddress, cphone, cemail) RETURNING cust_id INTO cid;
	INSERT INTO Credit_cards(number, expiry_date, CVV, cust_id)
	VALUES (cnumber, cexpiry_date, ccvv, cid);
END;
$$ LANGUAGE plpgsql;

/* 4 TESTED*/
CREATE OR REPLACE PROCEDURE update_credit_card(cid INTEGER, cnumber INTEGER, cexpiry_date DATE,
                                             cvv INTEGER)
AS $$
BEGIN
	INSERT INTO Credit_cards(number, expiry_date, CVV, cust_id)
	VALUES (cnumber, cexpiry_date, cvv, cid);
END;
$$ LANGUAGE plpgsql;

/* 5 TESTED*/
CREATE OR REPLACE PROCEDURE add_course(title TEXT, description TEXT, area TEXT, duration INTEGER) AS $$
DECLARE
    mid INTEGER;
BEGIN
    SELECT eid INTO mid FROM Course_areas WHERE course_area_name = area;
    IF mid IS NULL THEN 
        RAISE EXCEPTION 'No manager to the area %', area;
        return;
    END IF;
    INSERT INTO  Courses (title, description, duration, course_area_name)
    VALUES (title, description, duration, area);
END;
$$ LANGUAGE plpgsql;

/* 6 */
CREATE OR REPLACE FUNCTION find_instructors(course_id INTEGER, sess_date DATE, sess_start_hour TIME)
RETURNS TABLE(eid INTEGER, name TEXT) AS $$
	SELECT I.eid, E.name
	FROM Instructors I NATURAL JOIN Employees E
	WHERE NOT EXISTS (
                    SELECT 1
                    FROM Sessions S
                    WHERE I.eid = S.eid
                    and sess_date = S.s_date
                    and (sess_start_hour + INTERVAL '1 hours' * 
                    ((SELECT duration FROM Courses where Courses.course_id = course_id) + 1) > S.start_time 
                    or 
                    sess_start_hour < S.end_time + INTERVAL '1 hour')
                    )
    AND NOT EXISTS (
                    SELECT 1
                    FROM pay_slips S
                    WHERE I.eid = S.eid 
                    and (num_work_hours + (SELECT duration FROM Courses where Courses.course_id = course_id) > 30)
    );
$$ LANGUAGE sql;

/* 7 */
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
        SELECT Instructors.eid as e1, E.name as n1, num_work_hours as w1, date_part('day', s_date) as day, 
        start_time as t1, EXTRACT(epoch from (end_time-start_time))/3600 as duration
        FROM Instructors NATURAL JOIN Specializes Spec NATURAL JOIN Courses C 
        NATURAL JOIN Pay_slips P NATURAL JOIN Sessions S NATURAL JOIN Employees E
        WHERE course_id = cid and date_part('month', payment_date) = date_part('month', end_date) 
        ORDER BY Instructors.eid, day;
    FOR record IN curs LOOP
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

/* 9 */
CREATE OR REPLACE FUNCTION get_available_rooms(start_date DATE, end_date DATE)
RETURNS TABLE(room_identifier INTEGER, room_capacity INTEGER, day DATE, array_of_hour TIME[]) AS $$
DECLARE
	curr_arr TIME[];
	curr_date DATE;
	curr_time TIME;
	curs refcursor;
	row_var RECORD;
	prev_row RECORD;
	curr_rid INTEGER;
BEGIN
	curr_date := start_date;
	LOOP
		IF (curr_date > end_date) THEN
			EXIT;
		END IF;
		curr_arr := array['09:00:00','10:00:00','11:00:00','14:00:00','15:00:00','16:00:00','17:00:00'];
		OPEN curs FOR SELECT * FROM Sessions WHERE date = curr_date ORDER BY rid ASC, start_time ASC; 
		LOOP
			prev_row := row_var;
			FETCH curs INTO row_var;
			EXIT WHEN NOT FOUND;
			IF (prev_row.rid <> row_var.rid and prev_row <> null) THEN
				room_identifier := prev_row.rid;
				room_capacity := (SELECT seating_capacity FROM Rooms WHERE rid=room_identifier);
				day := curr_date;
				array_of_hour := curr_arr;
				RETURN NEXT;
				curr_arr := array['09:00:00','10:00:00','11:00:00','14:00:00','15:00:00','16:00:00','17:00:00'];
			END IF;
			curr_time := row_var.start_time;
			LOOP
				IF (curr_time = row_var.end_time) THEN
					EXIT;
				END IF;
				curr_arr := array_remove(curr_arr, curr_time);
				curr_time := curr_time + INTERVAL '1 HOUR';
			END LOOP;
		END LOOP;
		curr_date := curr_date + INTERVAL '1 DAY';
		CLOSE curs;
	END LOOP;
END;
$$ LANGUAGE plpgsql;

/* 10 without validation*/
DROP TYPE IF EXISTS Session CASCADE;
-- (session date, session start hour, and room identifier)
CREATE TYPE Session AS (
    start_date DATE,
    start_hr TIME,
    rid INTEGER,
    instructor_id INTEGER --TO BE REMOVED 
);
CREATE OR REPLACE PROCEDURE add_course_offering(coid INTEGER, cid INTEGER, fees FLOAT,
launch_date DATE, reg_deadline DATE, target_no INTEGER, aid INTEGER, VARIADIC sess Session[]) AS $$
DECLARE
    course_and_area RECORD;
    temp_id INTEGER;
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

    FOR i IN 1 .. array_upper(sess,1) LOOP
        cap := cap + (SELECT seating_capacity FROM Rooms R
        WHERE R.rid = sess[i].rid);
        IF start_date IS NULL THEN start_date := sess[i].start_date;
        ELSIF start_date > sess[i].start_date THEN start_date:= sess[i].start_date;
        END IF;
        IF start_date IS NULL THEN end_date := sess[i].end_date;
        ELSIF end_date < sess[i].start_date THEN end_date:= sess[i].start_date;
        END IF;
        INSERT INTO Sessions VALUES
        (i, CURRENT_DATE, sess[i].start_hr, sess[i].start_hr + course_and_area.duration * INTERVAL '1 hour', 
        cid, launch_date, sess[i].rid, sess[i].instructor_id);
    END LOOP;
    INSERT INTO Offerings VALUES
    (coid, cid, launch_date, start_date, end_date, reg_deadline, target_no, cap, fees, aid);
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
	DROP TABLE IF EXISTS tmp, tmp2;
	cust_num := (SELECT number FROM Credit_cards WHERE cust_id=cid ORDER BY from_date DESC LIMIT 1);
	SELECT num_remaining_redemptions, b_date, package_id INTO buy_info FROM Buys WHERE number=cust_num ORDER BY b_date DESC LIMIT 1;
	CREATE TEMP TABLE IF NOT EXISTS tmp AS SELECT package_name, price, num_free_registrations, num_remaining_redemptions, b_date
					 FROM Course_packages NATURAL JOIN Buys WHERE Buys.number=cust_num ORDER BY b_date DESC LIMIT 1;
	CREATE TEMP TABLE IF NOT EXISTS tmp2 AS SELECT (SELECT title FROM Courses C WHERE C.course_id=R.course_id) AS title,
	(SELECT s_date FROM Sessions C WHERE C.sid=R.sid and C.course_id=R.course_id and C.launch_date=R.launch_date
	and C.rid=R.rid and C.eid=R.eid) AS session_date,
	(SELECT start_time FROM Sessions C WHERE C.sid=R.sid and C.course_id=R.course_id and C.launch_date=R.launch_date
	and C.rid=R.rid and C.eid=R.eid) AS start_time
	FROM Redeems R
	WHERE package_id=buy_info.package_id and number=cust_num and b_date=buy_info.b_date
	ORDER BY session_date ASC, start_time ASC;
	RETURN (SELECT row_to_json(t)
	FROM (
		SELECT package_name, price, num_free_registrations, num_remaining_redemptions, b_date,
		(
			SELECT json_agg(d)
			FROM (
				SELECT title, session_date, start_time
				FROM tmp2
			) d
		) as redeemed_session_information
		FROM tmp
	) t);
END;
$$ LANGUAGE plpgsql;


/* 16 */
CREATE OR REPLACE FUNCTION get_available_course_sessions(coid INTEGER) 
RETURNS TABLE(sess_date DATE, sess_start TIME, i_name TEXT, seat_remaining INTEGER) AS $$
    SELECT s_date, start_time, name, seating_capacity - count(*) as avail_seats
    FROM Sessions NATURAL JOIN Instructors NATURAL JOIN Employees NATURAL JOIN Registers 
    NATURAL JOIN Rooms
    WHERE course_id = coid
    GROUP BY s_date, start_time, name, seating_capacity;
$$ LANGUAGE sql;


/* 24 */
CREATE OR REPLACE PROCEDURE add_session(in_coid INTEGER, sess_id INTEGER, sess_day DATE,
                                sess_start TIME, eid INTEGER, rid INTEGER) AS $$
DECLARE 
    c_and_co RECORD;
BEGIN
    SELECT * into c_and_co FROM Offerings NATURAL JOIN Courses WHERE course_id = in_coid;
    IF sess_day < c_and_co.registration_deadline THEN
        RAISE EXCEPTION 'The registration should close before commencing';
    END IF;
    IF NOW() > c_and_co.registration_deadline THEN
        RAISE EXCEPTION 'Course offering’s registration deadline has passed';
    END IF;
    INSERT INTO Sessions VALUES 
    (sess_id, sess_day, sess_start, sess_start + INTERVAL '1 hour' * c_and_co.duration, c_and_co.course_id, c_and_co.launch_date,
    rid, eid);
END;
$$ LANGUAGE plpgsql;


/* 25 */
-- CREATE OR REPLACE FUNCTION pay_salary()
-- RETURNS @salTable TABLE(eid INTEGER, ename TEXT, estatus TEXT, num_work_days INTEGER, 
-- 	num_work_hours INTEGER, hourly_rate FLOAT, monthly_salary FLOAT, amount FLOAT)
-- AS $$
-- DECLARE
-- 	curs CURSOR FOR (SELECT * FROM Employees WHERE depart_date IS NULL ORDER BY eid ASC)
-- 	r RECORD;
-- 	partTime BOOLEAN;
-- 	estatus TEXT;
-- 	num_work_days INTEGER;
-- 	num_work_hours INTEGER;
-- 	hourly_rate FLOAT;
-- 	monthly_salary FLOAT;
-- 	amount FLOAT;
-- BEGIN
-- 	OPEN curs;
-- 	LOOP
-- 		FETCH curs INTO r;
-- 		EXIT WHEN NOT FOUND;
-- 		eid := r.eid;
-- 		ename := r.name;
-- 		partTime := EXISTS(SELECT 1 FROM Part_time_emp PTE WHERE r.eid=PTE.eid);
-- 		IF partTime THEN 
-- 			estatus := 'part-time';
-- 			num_work_hours := SUM(
-- 				SELECT (EXTRACT(EPOCH FROM end_time)::INTEGER - EXTRACT(EPOCH FROM start_time)::INTEGER) / 3600;
-- 				FROM Sessions WHERE eid = r.eid);
-- 			IF num_work_hours = 0 THEN CONTINUE;
-- 			num_work_days := NULL;
-- 			hourly_rate := SELECT hourly_rate FROM Part_time_emp PTE WHERE r.eid=PTE.eid);
-- 			monthly_salary := NULL;
-- 			amount := num_work_hours * hourly_rate;
-- 		ELSE
-- 			estatus := 'full-time';
-- 			num_work_hours := NULL;
-- 			num_work_days := CASE
-- 				WHEN SELECT EXTRACT(YEAR FROM r.join_date)::INTEGER = EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER
-- 						AND SELECT EXTRACT(MONTH FROM r.join_date)::INTEGER = EXTRACT(MONTH FROM CURRENT_DATE)::INTEGER
-- 					THEN SELECT EXTRACT(DAY FROM CURRENT_DATE)::INTEGER - EXTRACT(DAY FROM r.join_date)::INTEGER + 1
-- 				ELSE SELECT EXTRACT(DAY FROM CURRENT_DATE)::INTEGER
-- 				END
-- 			IF num_work_days = 0 THEN CONTINUE;
-- 			hourly_rate := NULL;
-- 			monthly_salary := SELECT monthly_salary FROM Full_time_emp PTE WHERE r.eid=PTE.eid);
-- 			amount := monthly_salary * (num_work_days / SELECT EXTRACT(DAY FROM CURRENT_DATE)::INTEGER);
-- 		END IF;
-- 		INSERT INTO Pay_slips VALUES (eid, CURRENT_DATE, amount, num_work_hours, num_work_days);
-- 		RETURN NEXT;
-- 	END LOOP;
-- 	CLOSE curs;
-- END;
-- $$ LANGUAGE plpgsql;
