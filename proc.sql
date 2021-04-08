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
CREATE OR REPLACE PROCEDURE remove_employee(reid INTEGER, depart_date DATE) AS $$
BEGIN
    IF (SELECT COUNT(*) FROM Offerings O WHERE reid = O.eid and depart_date < O.registration_deadline) > 0 
        or (SELECT COUNT(*) FROM Sessions WHERE reid = eid and depart_date < start_date and is_ongoing=true) > 0
        or (SELECT COUNT(*) FROM Course_areas CA WHERE reid = CA.eid) > 0
    THEN 
        RAISE EXCEPTION 'Employee cannot be removed!';
    ELSE
        UPDATE Employees E SET E.depart_date = depart_date WHERE E.eid = reid; 
    END IF;
END;
$$ LANGUAGE plpgsql;

/* 3 TESTED*/
CREATE OR REPLACE PROCEDURE add_customer(cname TEXT, caddress TEXT, cphone BIGINT,
                        cemail TEXT, cnumber BIGINT, cexpiry_date DATE, ccvv INTEGER)
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
DROP PROCEDURE IF EXISTS update_credit_card;
CREATE OR REPLACE PROCEDURE update_credit_card(cid INTEGER, cnumber BIGINT, 
                        cexpiry_date DATE, cvv INTEGER)
AS $$
BEGIN
	INSERT INTO Credit_cards(number, expiry_date, CVV, cust_id)
	VALUES (cnumber, cexpiry_date, cvv, cid);
END;
$$ LANGUAGE plpgsql;

/* 5 TESTED*/
CREATE OR REPLACE PROCEDURE add_course(title TEXT, description TEXT, area TEXT, 
                                        duration INTEGER) AS $$
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
-- DROP FUNCTION IF EXISTS find_instructors(in_course_id INTEGER, sess_date DATE, sess_start_hour TIME);
/* 6 */
CREATE OR REPLACE FUNCTION find_instructors(in_course_id INTEGER, sess_date DATE, sess_start_hour TIME)
RETURNS TABLE(out_eid INTEGER, name TEXT) AS $$
DECLARE
duration INTEGER := (SELECT duration FROM Courses where Courses.course_id = in_course_id);
BEGIN
CREATE TEMP TABLE IF NOT EXISTS temp_table AS
SELECT eid as iid, sum(EXTRACT(epoch from (end_time-start_time))/3600) as hours
FROM Sessions 
GROUP BY eid;
return query SELECT I.eid, E.name
	FROM Instructors I NATURAL JOIN Employees E NATURAL JOIN Specializes
	WHERE NOT EXISTS (
                    SELECT 1
                    FROM Sessions S
                    WHERE I.eid = S.eid
                    and sess_date = S.s_date
					and is_ongoing=true
                    and (
                            (sess_start_hour >= S.start_time OR
                            sess_start_hour + INTERVAL '1 hours' * (duration + 1) > S.start_time)
                        AND
                            (sess_start_hour < S.start_time OR
                            S.end_time + INTERVAL '1 hour' > sess_start_hour)
                    )                           
                    ) and (
                        EXISTS(SELECT 1 from full_time_emp FT WHERE FT.eid = I.eid) or  
                        COALESCE((SELECT(SELECT hours FROM temp_table WHERE iid = I.eid) + duration), 0) <= 30
                    )
                    AND (SELECT course_area_name FROM Specializes WHERE eid = I.eid) = 
                    (SELECT course_area_name FROM Courses C WHERE C.course_id = in_course_id);
    DROP TABLE temp_table;
END;
$$ LANGUAGE plpgsql;

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
        WHERE course_id = cid and date_part('month', payment_date) = date_part('month', end_date) and is_ongoing=true
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
					  and is_ongoing=true
					  and ((sess_start_hour >= S.start_time and sess_start_hour < S.end_time) 
						   or (sess_end_hour > S.start_time and sess_end_hour <= S.end_time)));
END;
$$ LANGUAGE plpgsql;

/* 9 */
DROP FUNCTION IF EXISTS get_available_rooms;
CREATE OR REPLACE FUNCTION get_available_rooms(start_date DATE, end_date DATE)
RETURNS TABLE(rrid INTEGER, capacity INTEGER, dday DATE, arr TIME[]) AS $$
DECLARE
	curr_arr TIME[];
	curr_date DATE;
	curr_time TIME;
	curs1 CURSOR FOR (SELECT rid FROM Rooms ORDER BY rid ASC);
	curs2 refcursor;
	row_var RECORD;
	curr_rid INTEGER;
	room_var RECORD;
BEGIN
	OPEN curs1;
	LOOP
		FETCH curs1 into room_var;
		EXIT WHEN NOT FOUND;
		curr_date := start_date;
		LOOP
			IF (curr_date > end_date) THEN
				EXIT;
			END IF;
			curr_arr := array['09:00:00','10:00:00','11:00:00','14:00:00','15:00:00','16:00:00','17:00:00'];
			OPEN curs2 FOR SELECT * FROM Sessions S WHERE S.s_date = curr_date and S.rid=room_var.rid and is_ongoing=true ORDER BY start_time ASC;
			LOOP
				FETCH curs2 INTO row_var;
				EXIT WHEN NOT FOUND;
				curr_time := row_var.start_time;
				LOOP
					IF (curr_time = row_var.end_time) THEN
						EXIT;
					END IF;
					curr_arr := array_remove(curr_arr, curr_time);
					curr_time := curr_time + INTERVAL '1 HOUR';
				END LOOP;
			END LOOP;
			rrid := room_var.rid;
			capacity := (SELECT seating_capacity FROM Rooms WHERE rid=room_var.rid);
			dday := curr_date;
			arr := curr_arr;
			RETURN NEXT;
			curr_date := curr_date + INTERVAL '1 DAY';
			CLOSE curs2;
		END LOOP;
	END LOOP;
	CLOSE curs1;
END;
$$ LANGUAGE plpgsql;

/* 10 */
DROP TYPE IF EXISTS Session CASCADE;
-- (session date, session start hour, and room identifier)
CREATE TYPE Session AS (
    start_date DATE,
    start_hr TIME,
    rid INTEGER
);
CREATE OR REPLACE FUNCTION helper(sess Session[], idx INTEGER, duration INTEGER, cid INTEGER, in_launch_date DATE)
RETURNS INTEGER AS $$
DECLARE 
i INTEGER;
j INTEGER;
res INTEGER;
sum INTEGER;
temp RECORD;
BEGIN
    IF array_length(sess, 1) IS NULL THEN return 0; END IF;
    select count(*) into sum from find_instructors(cid, sess[1].start_date, sess[1].start_hr);
    FOR j IN 1 .. sum LOOP
        SELECT * INTO temp FROM find_instructors(cid, sess[1].start_date, sess[1].start_hr)
        offset (j - 1) limit 1;
        INSERT INTO Sessions VALUES  --simplify into add session
        (idx, sess[1].start_date, sess[1].start_hr, sess[1].start_hr + duration * INTERVAL '1 hour',
        cid, in_launch_date, sess[1].rid, temp.out_eid);
        res := helper(sess[2:array_length(sess,1)], idx + 1, duration, cid, in_launch_date); 
        IF res = 1 THEN
            DELETE FROM Sessions WHERE sid = idx and course_id = cid and launch_date = in_launch_date;
        ELSE
            return 0;
        END IF;
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
    IF res = 1 THEN raise exception 'Valid assignment of instructor to session not found';END IF;
    FOR i IN 1 .. array_upper(sess,1) LOOP
        cap := cap + (SELECT seating_capacity FROM Rooms R
        WHERE R.rid = sess[i].rid);
        IF start_date IS NULL THEN start_date := sess[i].start_date;
        ELSIF start_date > sess[i].start_date THEN start_date:= sess[i].start_date;
        END IF;
        IF end_date IS NULL THEN end_date := sess[i].start_date;
        ELSIF end_date < sess[i].start_date THEN end_date:= sess[i].start_date;
        END IF;
    END LOOP;
    INSERT INTO Offerings VALUES
    (cid, launch_date, start_date, end_date, reg_deadline, target_no, cap, fees, aid);
END;
$$ LANGUAGE plpgsql;

/* 11 */
CREATE OR REPLACE PROCEDURE add_course_packages(p_name TEXT, num_free INTEGER,
                                    start_date DATE, end_date DATE, p_price FLOAT) AS $$
INSERT INTO Course_packages (sale_start_date, sale_end_date, num_free_registrations, package_name, price)
VALUES (start_date, end_date, num_free, p_name, p_price);
$$ LANGUAGE sql;

/* 12 */
CREATE OR REPLACE FUNCTION get_available_course_packages()
RETURNS TABLE (LIKE Course_packages) AS $$
	SELECT * 
	FROM Course_packages
	WHERE sale_end_date >= CURRENT_DATE and CURRENT_DATE >= sale_start_date;
$$ LANGUAGE sql;

/* 13 */
CREATE OR REPLACE PROCEDURE buy_course_package(cid INTEGER, pid INTEGER) AS $$
DECLARE
	cnum INTEGER;
	rnum INTEGER;
BEGIN
	cnum := (SELECT number FROM Credit_cards WHERE cust_id=cid ORDER BY from_date DESC LIMIT 1);
	IF NOT EXISTS (SELECT * FROM Buys WHERE number=cnum and num_remaining_redemptions > 0) 
        and (pid IN (SELECT package_id FROM get_available_course_packages()))
    THEN
		rnum := (SELECT num_free_registrations FROM get_available_course_packages() WHERE package_id=pid);
		INSERT INTO Buys (number, package_id, num_remaining_redemptions) VALUES (cnum, pid, rnum);
	ELSE
		RAISE NOTICE 'UNABLE TO PURCHASE PACKAGE!';
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
	SELECT num_remaining_redemptions, b_date, package_id INTO buy_info 
    FROM Buys WHERE number=cust_num ORDER BY b_date DESC LIMIT 1;
	CREATE TEMP TABLE IF NOT EXISTS tmp AS SELECT package_name, price, num_free_registrations, num_remaining_redemptions, b_date
					 FROM Course_packages NATURAL JOIN Buys 
                     WHERE Buys.number=cust_num 
                     ORDER BY b_date DESC LIMIT 1;
	CREATE TEMP TABLE IF NOT EXISTS tmp2 AS 
    SELECT (SELECT title FROM Courses C WHERE C.course_id=R.course_id) AS title,
	(SELECT s_date FROM Sessions C WHERE C.sid=R.sid and C.course_id=R.course_id and C.launch_date=R.launch_date
	and C.rid=R.rid and C.eid=R.eid and is_ongoing=true) AS session_date,
	(SELECT start_time FROM Sessions C WHERE C.sid=R.sid and C.course_id=R.course_id and C.launch_date=R.launch_date
	and C.rid=R.rid and C.eid=R.eid and is_ongoing=true) AS start_time
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

/* 15 */
CREATE OR REPLACE FUNCTION get_available_course_offerings()
RETURNS TABLE (title TEXT, course_area TEXT, start_date DATE, end_date DATE, reg_deadline DATE, fees FLOAT, num_remaining_seats INTEGER) AS $$
BEGIN
	RETURN QUERY
	SELECT C.title, C.course_area_name, C.start_date, C.end_date, C.reg_deadline, C.fees, 
	((SELECT SUM(seating_capacity) FROM (Rooms NATURAL JOIN Sessions) R WHERE R.course_id=C.course_id and R.launch_date=C.launch_date and is_ongoing=true) - 
	 (SELECT COUNT(*) FROM Registers R WHERE R.course_id=C.course_id and R.launch_date=C.launch_date))::INTEGER AS num_remaining_seats
	FROM (Offerings NATURAL JOIN Courses) C
	WHERE C.reg_deadline >= CURRENT_DATE and ((SELECT SUM(seating_capacity) FROM (Rooms NATURAL JOIN Sessions) R WHERE R.course_id=C.course_id and R.launch_date=C.launch_date and is_ongoing=true) - 
	 (SELECT COUNT(*) FROM Registers R WHERE R.course_id=C.course_id and R.launch_date=C.launch_date))>0
	ORDER BY C.reg_deadline ASC, C.title ASC;
END;
$$ LANGUAGE plpgsql;


/* 16 */
CREATE OR REPLACE FUNCTION get_available_course_sessions(coid INTEGER) 
RETURNS TABLE(sess_date DATE, sess_start TIME, i_name TEXT, seat_remaining INTEGER) AS $$
    SELECT s_date, start_time, name, seating_capacity - count(*) as avail_seats
    FROM Sessions NATURAL JOIN Instructors NATURAL JOIN Employees NATURAL JOIN Registers 
    NATURAL JOIN Rooms
    WHERE course_id = coid and is_ongoing=true
    GROUP BY s_date, start_time, name, seating_capacity;
$$ LANGUAGE sql;

/* 17 */
CREATE OR REPLACE PROCEDURE register_session(in_cust_id INTEGER, cid INTEGER, in_launch_date DATE,
in_sid INTEGER, method TEXT) AS $$
DECLARE
    credit_card_info RECORD;
    buy_info RECORD;
BEGIN
    SELECT * INTO credit_card_info FROM Credit_cards WHERE cust_id = in_cust_id
    ORDER BY from_date DESC;
    INSERT INTO Registers VALUES (credit_card_info.number, cid, in_launch_date, in_sid, CURRENT_DATE);
    IF method = 'redemption' THEN
        SELECT * INTO buy_info FROM Buys WHERE EXISTS (
            SELECT 1
            FROM Buys B NATURAL JOIN Credit_cards C
            WHERE C.cust_id = in_cust_id AND B.num_remaining_redemptions > 0
            ORDER BY b_date DESC
        );
        IF buy_info is NULL THEN RAISE EXCEPTION 'There are no avail packages to redeem from'; END IF;
        INSERT INTO Redeems VALUES
        (buy_info.package_id, credit_card_info.number, buy_info.b_date, CURRENT_DATE, 
        cid, in_launch_date, in_sid);
        --UPDATE Buys SET num_remaining_redemptions = num_remaining_redemptions - 1  assuming this is done by trigger
    ELSIF method <> 'payment' THEN
        RAISE EXCEPTION 'The method can only be payment or redemption';
    END IF;
END;
$$ LANGUAGE plpgsql;

/* 22 */
CREATE OR REPLACE PROCEDURE update_room(cid INTEGER, ld DATE, ssid INTEGER, rrid INTEGER)
AS $$
BEGIN
	IF ((SELECT s_date FROM Sessions S WHERE S.course_id=cid and S.launch_date=ld and S.sid=ssid and is_ongoing=true) > CURRENT_DATE and 
		(SELECT count(*) FROM Registers R WHERE R.course_id=cid and R.launch_date=ld and R.sid=ssid) <
		(SELECT seating_capacity FROM Rooms R WHERE R.rid=rrid)) THEN
		UPDATE Sessions
		SET rid=rrid
		WHERE course_id=cid and launch_date=ld and sid=ssid and is_ongoing=true;
	ELSE
		RAISE NOTICE 'Unable to change room!';
	END IF;
END;
$$ LANGUAGE plpgsql;

/* 23 */
CREATE OR REPLACE PROCEDURE remove_session(i_course_id INTEGER, i_launch_date DATE, i_sess_number INTEGER)
AS $$
DECLARE
	session_date DATE;
	session_start_time TIME;
BEGIN
	SELECT S.s_date INTO session_date
	FROM Sessions S
	WHERE i_course_id = S.course_id
	and i_launch_date = S.launch_date
	and i_sess_number = S.sid;

	SELECT S.start_time INTO session_start_time
	FROM Sessions S
	WHERE i_course_id = S.course_id
	and i_launch_date = S.launch_date
	and i_sess_number = S.sid;
	
	IF (CURRENT_DATE > session_date or (CURRENT_DATE = session_date and CURRENT_TIME > session_start_time)) THEN
		RAISE EXCEPTION 'The session has already started!';
	ELSIF (EXISTS (SELECT 1
				  FROM Registers R
				  WHERE R.sid = i_sess_number
				  and R.course_id = i_course_id
				  and R.launch_date = i_launch_date
		  		  UNION
		       	  SELECT 1
				  FROM Redeems R
				  WHERE R.sid = i_sess_number
				  and R.course_id = i_course_id
				  and R.launch_date = i_launch_date)) THEN
		RAISE EXCEPTION 'There is at least one registration for the session!';
	END IF;
	
	DELETE FROM Sessions WHERE i_course_id = course_id and i_launch_date = launch_date and i_sess_number = sid;
	
END;
$$ LANGUAGE plpgsql;

/* 24 */
CREATE OR REPLACE PROCEDURE add_session(in_coid INTEGER, sess_id INTEGER, sess_day DATE,
                                sess_start TIME, eid INTEGER, rid INTEGER) AS $$
DECLARE 
    c_and_co RECORD;
BEGIN
    SELECT * into c_and_co FROM Offerings NATURAL JOIN Courses WHERE course_id = in_coid;
    IF c_and_co is NULL THEN RAISE EXCEPTION 'Offering not found'; END IF;
    IF sess_day < c_and_co.reg_deadline THEN
        RAISE EXCEPTION 'The registration should close before commencing';
    END IF;
    IF NOW() > c_and_co.reg_deadline THEN
        RAISE EXCEPTION 'Course offering’s registration deadline has passed';
    END IF; --TODO turn to trigger
    INSERT INTO Sessions VALUES 
    (sess_id, sess_day, sess_start, sess_start + INTERVAL '1 hour' * c_and_co.duration, c_and_co.course_id, c_and_co.launch_date,
    rid, eid);
END;
$$ LANGUAGE plpgsql;



/* 26 */
CREATE OR REPLACE FUNCTION promote_courses()
RETURNS TABLE(customer_id INTEGER, customer_name TEXT, ca_of_interest TEXT, course_title TEXT, 
			  launch_date DATE, reg_deadline DATE, fees FLOAT)
AS $$
DECLARE
	curs CURSOR FOR (SELECT * FROM Customers);
	ca_curs REFCURSOR;
	course_curs REFCURSOR;
	co_curs REFCURSOR;
	customer RECORD;
	ca RECORD;
	course RECORD;
	co RECORD;
BEGIN
	OPEN curs;
	LOOP
		FETCH curs INTO customer;
		EXIT WHEN NOT FOUND;
		IF NOT EXISTS (SELECT 1 
					   FROM Registers R NATURAL JOIN Credit_cards C 
					   WHERE customer.cust_id = C.cust_id 
					   and R.r_date > DATE(CURRENT_DATE - INTERVAL '6 months') 
					   UNION 
					   SELECT 1 
					   FROM Redeems R NATURAL JOIN Credit_cards C 
					   WHERE customer.cust_id = C.cust_id 
					   and R.r_date > DATE(CURRENT_DATE - INTERVAL '6 months')) THEN
			OPEN ca_curs FOR (WITH Registrations AS 
							  (SELECT R.sid, R.course_id, R.launch_date, R.r_date
							   FROM Redeems R NATURAL JOIN Credit_cards C 
							   WHERE r.cust_id = C.cust_id 
							   UNION
							   SELECT R.sid, R.course_id, R.launch_date, R.r_date
							   FROM Registers R NATURAL JOIN Credit_cards C
							   WHERE r.cust_id = C.cust_id)
							  SELECT C.course_area_name
							  FROM Registrations R NATURAL JOIN Courses C
							  ORDER BY R.r_date DESC
						  	  LIMIT 3);					  
			LOOP
				FETCH ca_curs INTO ca;
				EXIT WHEN NOT FOUND;
				OPEN course_curs FOR (SELECT C.course_id, C.title
									  FROM Courses C 
									  WHERE C.course_area_name = ca.course_area_name);
				LOOP
					FETCH course_curs INTO course;
					EXIT WHEN NOT FOUND;
					OPEN co_curs FOR (SELECT O.launch_date, O.reg_deadline, O.fees
									  FROM Offerings O
									  WHERE O.course_id = course.course_id 
									  and CURRENT_DATE <= O.reg_deadline);
					LOOP
						FETCH co_curs INTO co;
						EXIT WHEN NOT FOUND;
						customer_id := customer.cust_id;
						customer_name := customer.cust_name;
						ca_of_interest := ca.course_area_name;
						course_title := course.title;
						launch_date := co.launch_date;
						reg_deadline := co.reg_deadline;
						fees := co.fees;
						RETURN NEXT;
					END LOOP;
					CLOSE co_curs;
				END LOOP;
				CLOSE course_curs;
			END LOOP;
			CLOSE ca_curs;
		END IF;
	END LOOP;
	CLOSE curs;
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
