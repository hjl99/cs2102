/* Routine 1 */ 
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


/* Routine 2 */
DROP PROCEDURE IF EXISTS remove_employee;
CREATE OR REPLACE PROCEDURE remove_employee(reid INTEGER, in_depart_date DATE) AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM Offerings O WHERE reid = O.eid and in_depart_date < O.reg_deadline) THEN
        RAISE EXCEPTION 'This employee is an administrator who is still handling some course offerings!';
    ELSIF EXISTS (SELECT 1 FROM Sessions WHERE reid = eid and in_depart_date < s_date and is_ongoing=true) THEN
        RAISE EXCEPTION 'This employee is an instructor who is teaching some course session that starts after the departure date!';
    ELSIF EXISTS (SELECT 1 FROM Course_areas CA WHERE reid = CA.eid) THEN 
        RAISE EXCEPTION 'The employee is a manager who is managing some course area!';
    ELSE
        UPDATE Employees SET depart_date = in_depart_date WHERE eid = reid; 
    END IF;
END;
$$ LANGUAGE plpgsql;


/* Routine 3 */
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


/* Routine 4 */
DROP PROCEDURE IF EXISTS update_credit_card;
CREATE OR REPLACE PROCEDURE update_credit_card(cid INTEGER, cnumber BIGINT, 
                        cexpiry_date DATE, cvv INTEGER)
AS $$
BEGIN
	INSERT INTO Credit_cards(number, expiry_date, CVV, cust_id)
	VALUES (cnumber, cexpiry_date, cvv, cid);
END;
$$ LANGUAGE plpgsql;


/* Routine 5 */
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


/* Routine 6 */
CREATE OR REPLACE FUNCTION find_instructors(in_course_id INTEGER, sess_date DATE, sess_start_hour TIME)
RETURNS TABLE(out_eid INTEGER, name TEXT) AS $$
DECLARE
duration INTEGER := (SELECT duration FROM Courses where Courses.course_id = in_course_id);
BEGIN
drop table if exists temp_table;
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
                    AND ((SELECT course_area_name FROM Courses C WHERE C.course_id = in_course_id) 
                    in (SELECT course_area_name FROM Specializes WHERE eid = I.eid));
    DROP TABLE temp_table;
END;
$$ LANGUAGE plpgsql;


/* Routine 7 */
DROP FUNCTION IF EXISTS get_available_instructors;
CREATE OR REPLACE FUNCTION get_available_instructors(in_cid INTEGER, start_date DATE, end_date DATE)
RETURNS TABLE(e_id INTEGER, i_name TEXT, total_hrs_for_month INTEGER, day INTEGER, hours TIME[]) AS $$
DECLARE
    temp TIME[] := '{}';
    timings TIME[] := ARRAY['09:00','10:00', '11:00', '14:00', '15:00', '16:00', '17:00'];
    curs CURSOR FOR (
        SELECT DISTINCT eid FROM Specializes NATURAL JOIN Courses
        WHERE course_id = in_cid ORDER BY eid ASC
    );
    total_hrs integer;
    timing TIME;
    curr_date DATE;
BEGIN
    FOR record IN curs LOOP
        curr_date = start_date;
        WHILE curr_date <= end_date LOOP
            SELECT sum(EXTRACT(epoch from (end_time-start_time))/3600) INTO total_hrs
            FROM Sessions S
            WHERE S.eid = record.eid and date_part('month', s_date) = date_part('month', curr_date)
            and date_part('year', s_date) = date_part('year', curr_date) and is_ongoing=true;
            temp := '{}';
            FOREACH timing IN ARRAY timings LOOP
                IF NOT EXISTS (
                    SELECT 1 FROM Sessions S 
                    WHERE S.start_time <= timing and S.end_time > timing
                    and s_date = curr_date
                    and record.eid = eid
                ) THEN
                SELECT array_append(temp, timing) INTO temp;
                END IF;
            END LOOP;
            e_id:= record.eid;
            i_name:= (SELECT name FROM Employees WHERE eid = record.eid);
            total_hrs_for_month := coalesce(total_hrs, 0);
            day := date_part('day', curr_date);
            hours := temp;
            RETURN NEXT;
			curr_date := curr_date + INTERVAL '1 DAY';
        END LOOP;
    END LOOP;
END;
$$ LANGUAGE plpgsql;


/* Routine 8 */
CREATE OR REPLACE FUNCTION find_rooms(sess_date DATE, sess_start_hour TIME, sess_duration INTEGER)
RETURNS TABLE(rid INTEGER) AS $$
DECLARE
	sess_end_hour TIME;
BEGIN
	sess_end_hour := sess_start_hour + sess_duration * INTERVAL '1 hour';
	RETURN QUERY SELECT R.rid
	FROM Rooms R
	WHERE NOT EXISTS (SELECT 1 
					 FROM Sessions S
					 WHERE R.rid = S.rid 
					  and S.s_date = sess_date 
					  and is_ongoing=true
					  and (
                        (sess_start_hour >= S.start_time OR
                            sess_end_hour > S.start_time)
                        AND
                            (sess_start_hour < S.start_time OR
                            S.end_time > sess_start_hour)
                        )
                    );
END;
$$ LANGUAGE plpgsql;


/* Routine 9 */
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
			OPEN curs2 FOR SELECT * FROM Sessions S WHERE S.s_date = curr_date and S.rid=room_var.rid 
            and is_ongoing=true ORDER BY start_time ASC;
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
/* Uses triggers 2, 3, 14, 15, 17, and 19 to check for violations,  4, 6 to update offerings */
DROP TYPE IF EXISTS Session CASCADE;
CREATE TYPE Session AS (
    start_date DATE,
    start_hr TIME,
    rid INTEGER
);
-- DROP PROCEDURE IF EXISTS add_course_offering;
CREATE OR REPLACE PROCEDURE add_course_offering(cid INTEGER, fees FLOAT,
in_launch_date DATE, reg_deadline DATE, target_no INTEGER, aid INTEGER, VARIADIC sess Session[]) AS $$
DECLARE
    course_and_area RECORD;
    last_stops INTEGER[];
    i INTEGER := 1;
    j INTEGER := 1;
    start_date DATE;
    end_date DATE;
    cap INTEGER := 0;
    res INTEGER := 0;
    total INTEGER;
    temp RECORD;
BEGIN
    set constraints offerings_fkey deferred;
    SELECT * INTO course_and_area FROM Courses 
    WHERE course_id = cid;
    WHILE (i <= array_upper(sess,1)) LOOP
        last_stops[i] = 1;
        i := i + 1;
    END LOOP;
    i := 1;
    WHILE (i <= array_upper(sess,1)) LOOP
        j :=last_stops[i];
        select count(*) into total from find_instructors(cid, sess[i].start_date, sess[i].start_hr);
        IF total = 0 or total < j THEN
            i := i - 1;
            IF i < 1 THEN
                RAISE EXCEPTION 'No valid assignment!';
            ELSE
                IF (i+1 <= array_upper(sess,1)) THEN
                    last_stops[i+1] := 1;
                END IF;
                DELETE FROM Sessions 
                WHERE sid = i and course_id = cid and launch_date = in_launch_date;
            END IF;
        ELSE
            SELECT * INTO temp FROM find_instructors(cid, sess[i].start_date, sess[i].start_hr)
            offset (j-1) limit 1;
            INSERT INTO Sessions VALUES
            (i, sess[i].start_date, sess[i].start_hr, sess[i].start_hr + course_and_area.duration * INTERVAL '1 hour',
            cid, in_launch_date, sess[i].rid, temp.out_eid);
            last_stops[i] := last_stops[i] + 1;
            i := i + 1;
        END IF;
    END LOOP;
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
    (cid, in_launch_date, start_date, end_date, reg_deadline, target_no, cap, fees, aid);
END;
$$ LANGUAGE plpgsql;


/* Routine 11 */
CREATE OR REPLACE PROCEDURE add_course_packages(p_name TEXT, num_free INTEGER,
                                    start_date DATE, end_date DATE, p_price FLOAT) AS $$
INSERT INTO Course_packages (sale_start_date, sale_end_date, num_free_registrations, package_name, price)
VALUES (start_date, end_date, num_free, p_name, p_price);
$$ LANGUAGE sql;


/* Routine 12 */
CREATE OR REPLACE FUNCTION get_available_course_packages()
RETURNS TABLE (LIKE Course_packages) AS $$
	SELECT * 
	FROM Course_packages
	WHERE sale_end_date >= CURRENT_DATE and CURRENT_DATE >= sale_start_date;
$$ LANGUAGE sql;


/* Routine 13 */
CREATE OR REPLACE PROCEDURE buy_course_package(cid INTEGER, pid INTEGER) AS $$
DECLARE
	cnum BIGINT;
	rnum INTEGER;
BEGIN
	cnum := (SELECT number FROM Credit_cards WHERE cust_id=cid ORDER BY from_date DESC LIMIT 1);
	IF NOT EXISTS (SELECT * FROM Buys WHERE number=cnum and num_remaining_redemptions > 0) 
        and (pid IN (SELECT package_id FROM get_available_course_packages()))
    THEN
		rnum := (SELECT num_free_registrations FROM get_available_course_packages() WHERE package_id=pid);
		INSERT INTO Buys (number, package_id, num_remaining_redemptions) VALUES (cnum, pid, rnum);
	ELSE
		RAISE EXCEPTION 'UNABLE TO PURCHASE PACKAGE!';
	END IF;
END;
$$ LANGUAGE plpgsql;


/* Routine 14 */
CREATE OR REPLACE FUNCTION get_my_course_package(cid INTEGER)
RETURNS json AS $$
DECLARE
	cust_num INTEGER;
	package_info RECORD;
	buy_info RECORD;
BEGIN
	DROP TABLE IF EXISTS tmp, tmp2, tmp3;
	CREATE TEMP TABLE IF NOT EXISTS tmp3 AS SELECT number FROM Credit_cards WHERE cust_id=cid ORDER BY from_date DESC;
	cust_num := (SELECT number FROM Buys WHERE number in (SELECT * FROM tmp3) ORDER BY b_date DESC LIMIT 1);
    IF EXISTS (SELECT * FROM Buys B WHERE B.num_remaining_redemptions > 0 and B.number IN (SELECT * FROM tmp3)) OR EXISTS
            (SELECT * FROM Redeems R WHERE R.number IN (SELECT * FROM tmp3) and 
            (SELECT s_date FROM Sessions S WHERE S.sid=R.sid and S.course_id=R.course_id and S.launch_date=R.launch_date)
            >=CURRENT_DATE + INTERVAL '7 DAYS') THEN
        SELECT num_remaining_redemptions, b_date, package_id INTO buy_info 
        FROM Buys WHERE number=cust_num ORDER BY b_date DESC LIMIT 1;
        CREATE TEMP TABLE IF NOT EXISTS tmp AS SELECT package_name, price, num_free_registrations, num_remaining_redemptions, b_date
                        FROM Course_packages NATURAL JOIN Buys 
                        WHERE Buys.number=cust_num 
                        ORDER BY b_date DESC LIMIT 1;
        CREATE TEMP TABLE IF NOT EXISTS tmp2 AS 
        SELECT (SELECT title FROM Courses C WHERE C.course_id=R.course_id) AS title,
        (SELECT s_date FROM Sessions C WHERE C.sid=R.sid and C.course_id=R.course_id and C.launch_date=R.launch_date
        and is_ongoing=true) AS session_date,
        (SELECT start_time FROM Sessions C WHERE C.sid=R.sid and C.course_id=R.course_id and C.launch_date=R.launch_date
        and is_ongoing=true) AS start_time
        FROM Redeems R
        WHERE package_id=buy_info.package_id and number=cust_num and b_date=buy_info.b_date
        ORDER BY session_date ASC, start_time ASC;
        RETURN (SELECT row_to_json(t)
        FROM (
            SELECT package_name, price, num_free_registrations, num_remaining_redemptions, b_date::date,
            (
                SELECT json_agg(d)
                FROM (
                    SELECT title, session_date, start_time
                    FROM tmp2
                ) d
            ) as redeemed_session_information
            FROM tmp
        ) t);
    ELSE
        RAISE NOTICE 'You have no active package';
    END IF;
END;
$$ LANGUAGE plpgsql;


/* Routine 15 */
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


/* Routine 16 */
CREATE OR REPLACE FUNCTION get_available_course_sessions(in_cid INTEGER, in_launch_date DATE) 
RETURNS TABLE(sess_date DATE, start_hour TIME, i_name TEXT, seat_remaining INTEGER) AS $$
    RETURN QUERY
    SELECT s_date, start_time, sid, seating_capacity - 
    (SELECT count(*) FROM Registers R 
    WHERE course_id= in_cid and launch_date = in_launch_date and R.sid = 1) as avail_seats
    FROM Sessions S NATURAL JOIN Instructors NATURAL JOIN Employees
    NATURAL JOIN Rooms
    WHERE course_id = in_cid and launch_date = in_launch_date and is_ongoing=true
    and not exists (
        SELECT 1 FROM Registers R WHERE course_id = in_cid and launch_date = in_launch_date and R.sid= S.sid
    )
    GROUP BY s_date, start_time, name, seating_capacity, sid
    ORDER BY s_date ASC, start_time ASC;
$$ LANGUAGE sql;


/* Routine 17 */
/* Uses triggers 5, 7, 9 */
CREATE OR REPLACE PROCEDURE register_session(in_cust_id INTEGER, cid INTEGER, in_launch_date DATE,
in_sid INTEGER, method TEXT) AS $$
DECLARE
    credit_card_info RECORD;
    buy_info RECORD;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Sessions WHERE cid = course_id 
    and in_launch_date = launch_date and in_sid = sid) THEN
        RAISE EXCEPTION 'This session does not exist!';
    END IF;
    SELECT * INTO credit_card_info FROM Credit_cards 
    WHERE cust_id = in_cust_id
    ORDER BY from_date DESC;
    INSERT INTO Registers VALUES 
    (credit_card_info.number, cid, in_launch_date, in_sid, CURRENT_DATE);
    IF method = 'redemption' THEN
        SELECT * INTO buy_info FROM Buys B NATURAL JOIN Credit_cards C
            WHERE C.cust_id = in_cust_id AND B.num_remaining_redemptions > 0
            ORDER BY b_date DESC;
        IF buy_info is NULL THEN RAISE EXCEPTION 'There are no avail packages to redeem from'; END IF;
        INSERT INTO Redeems VALUES
        (buy_info.package_id, credit_card_info.number, buy_info.b_date, CURRENT_DATE, 
        cid, in_launch_date, in_sid);
    ELSIF method <> 'payment' THEN
        RAISE EXCEPTION 'The method can only be payment or redemption';
    END IF;
END;
$$ LANGUAGE plpgsql;



/* Routine 18 */
drop function if exists get_my_registrations;
CREATE OR REPLACE FUNCTION get_my_registrations(in_cust_id INTEGER)
RETURNS TABLE (course_name TEXT, course_fees FLOAT, sess_date DATE, sess_start_hour TIME, 
    sess_duration INTEGER, instr_name TEXT) AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Customers WHERE cust_id = in_cust_id) THEN
        RAISE EXCEPTION 'Customer specified does not exist';
    END IF;
    RETURN QUERY
    WITH
    Active_reg AS (
        SELECT *
        FROM Registers NATURAL JOIN Sessions NATURAL JOIN Courses NATURAL JOIN
            (SELECT course_id, launch_date, reg_deadline, fees FROM Offerings) Off
        WHERE number IN (SELECT number FROM Credit_cards WHERE cust_id = in_cust_id)
            AND CURRENT_DATE <= reg_deadline
        ORDER BY s_date, start_time
    )
    SELECT title AS course_name, fees AS course_fees, s_date AS sess_date, start_time AS sess_start_hour,
        duration AS sess_duration, (SELECT name FROM Employees WHERE eid = AR.eid) AS instr_name
    FROM Active_reg AR;
END;
$$ LANGUAGE plpgsql;


/* Routine 19 */
/* Uses triggers 5 */
CREATE OR REPLACE PROCEDURE update_course_session(in_cust_id INTEGER, in_course_id INTEGER, 
    in_launch_date DATE, new_sess_id INTEGER) AS $$
DECLARE
    prev_sess_id INTEGER;
    new_sess_rid INTEGER;
    new_sess_seating_capacity INTEGER;
    new_sess_valid_reg_count INTEGER;
    cust_card_number BIGINT;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Customers WHERE cust_id = in_cust_id) THEN 
        RAISE EXCEPTION 'The customer specified does not exist.';
    END IF;

    SELECT number, sid INTO cust_card_number, prev_sess_id
    FROM Registers
    WHERE course_id = in_course_id AND launch_date = in_launch_date
        AND number IN (SELECT number FROM Credit_cards WHERE cust_id = in_cust_id);

    new_sess_rid := (SELECT rid FROM Sessions 
                    WHERE course_id = in_course_id AND launch_date = in_launch_date AND sid = new_sess_id);
    
    IF prev_sess_id IS NULL THEN 
        RAISE EXCEPTION 'Customer has not registered for the course specified.';
    ELSIF new_sess_rid IS NULL THEN 
        RAISE EXCEPTION 'The new session specified does not exist.';
    END IF;

    new_sess_seating_capacity := (SELECT seating_capacity FROM Rooms WHERE rid = new_sess_rid);
    new_sess_valid_reg_count := (SELECT COUNT(*) FROM Registers 
                            WHERE course_id = in_course_id AND launch_date = in_launch_date AND sid = new_sess_id);

    IF new_sess_seating_capacity <= new_sess_valid_reg_count THEN 
        RAISE EXCEPTION 'No vacancy in the new session.';
    ELSE 
        UPDATE Registers 
        SET sid = new_sess_id
        WHERE course_id = in_course_id AND launch_date = in_launch_date AND sid = prev_sess_id 
            AND number = cust_card_number;
    END IF;
END;
$$ LANGUAGE plpgsql;


/* Routine 20 */
/* Uses triggers 18 to update Buys, 24 to check */
CREATE OR REPLACE PROCEDURE cancel_registration(in_cust_id INTEGER, in_course_id INTEGER, in_launch_date DATE) AS $$
DECLARE
    reg_cust_card_number BIGINT;
    late_cancel BOOLEAN;
    sess_redeemed BOOLEAN;
    early_cancel_ddl DATE;
    refund_amt FLOAT;
    package_credit INTEGER;
    sess_id INTEGER;
    payment_date TIMESTAMP;
    redeemed_package_id INTEGER;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Customers WHERE cust_id = in_cust_id) THEN
        RAISE EXCEPTION 'The customer specified does not exist.';
    ELSIF NOT EXISTS (SELECT 1 FROM Offerings WHERE course_id = in_course_id AND launch_date = in_launch_date) THEN
        RAISE EXCEPTION 'The course offering specified does not exist.';
    END IF;

    SELECT number, sid INTO reg_cust_card_number, sess_id 
    FROM Registers 
    WHERE number IN (SELECT number FROM Credit_cards WHERE cust_id = in_cust_id)
    AND course_id = in_course_id AND launch_date = in_launch_date;

    IF sess_id IS NULL THEN 
        RAISE EXCEPTION 'No registration to cancel.';
    ELSIF CURRENT_TIMESTAMP >= (SELECT s_date + start_time FROM Sessions 
        WHERE sid = sess_id AND course_id = in_course_id AND launch_date = in_launch_date) THEN
        RAISE EXCEPTION 'Cancelling a session after its start time is not allowed.';
    END IF;

    early_cancel_ddl := (SELECT (s_date - INTERVAL '7 DAYS') 
                        FROM Sessions 
                        WHERE sid = sess_id AND course_id = in_course_id AND launch_date = in_launch_date);
    late_cancel := CASE WHEN CURRENT_DATE > early_cancel_ddl THEN TRUE 
                        ELSE FALSE 
                    END;
    redeemed_package_id := (SELECT package_id 
                            FROM Redeems 
                            WHERE course_id = in_course_id AND launch_date = in_launch_date AND sid = sess_id
                            AND number IN (SELECT number FROM Credit_cards WHERE cust_id = in_cust_id));
    sess_redeemed := CASE WHEN redeemed_package_id IS NOT NULL THEN TRUE 
                        ELSE FALSE 
                    END;
    refund_amt := CASE 
                    WHEN (NOT sess_redeemed) AND (NOT late_cancel) THEN 
                        0.9 * (SELECT fees FROM Offerings 
                            WHERE course_id = in_course_id AND launch_date = in_launch_date)
                    WHEN (NOT sess_redeemed) AND late_cancel THEN 0
                    ELSE NULL 
                END;
    package_credit := CASE 
                        WHEN sess_redeemed AND (NOT late_cancel) THEN 1 
                        WHEN sess_redeemed AND late_cancel THEN 0
                        ELSE NULL 
                    END;
    payment_date := CASE
                        WHEN sess_redeemed THEN 
                            (SELECT b_date FROM Redeems
                            WHERE course_id = in_course_id AND launch_date = in_launch_date AND sid = sess_id
                                AND number IN (SELECT number FROM Credit_cards WHERE cust_id = in_cust_id))
                        ELSE (SELECT r_date::TIMESTAMP FROM Registers 
                            WHERE course_id = in_course_id AND launch_date = in_launch_date AND sid = sess_id
                                AND number = reg_cust_card_number)
                    END;
    INSERT INTO Cancels (c_date, refund_amt, package_credit, cust_id, course_id, 
            launch_date, sid, payment_date) 
    VALUES (CURRENT_DATE, refund_amt, package_credit, in_cust_id, in_course_id, 
            in_launch_date, sess_id, payment_date);
    DELETE FROM Registers 
    WHERE number = reg_cust_card_number 
        AND course_id = in_course_id AND launch_date = in_launch_date AND sid = sess_id;
END;
$$ LANGUAGE plpgsql;


/* Routine 21 */
/* Uses triggers 14 and 15 to check instructor teaching constraints */
CREATE OR REPLACE PROCEDURE update_instructor(in_course_id INTEGER, in_launch_date DATE, 
    sess_id INTEGER, new_instr_id INTEGER) AS $$
DECLARE
    sess_date DATE;
    sess_start_time TIME;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Instructors WHERE eid = new_instr_id) THEN
        RAISE EXCEPTION 'The new instructor specified does not exist.';
    END IF;

    SELECT s_date, start_time INTO sess_date, sess_start_time 
    FROM Sessions 
    WHERE course_id = in_course_id AND launch_date = in_launch_date AND sid = sess_id;

    IF sess_date IS NULL THEN 
        RAISE EXCEPTION 'Course Session specified does not exist.';
    ELSIF CURRENT_TIMESTAMP >= (sess_date + sess_start_time) THEN 
        RAISE EXCEPTION 'Changes cannot be made to an ongoing or finished session.';
    ELSE 
        UPDATE Sessions SET eid = new_instr_id 
        WHERE course_id = in_course_id AND launch_date = in_launch_date AND sid = sess_id;
    END IF;
END;
$$ LANGUAGE plpgsql;


/* Routine 22 */
/* Uses trigger 3 to check for constraint violations */
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


/* Routine 23 */
/* Uses triggers 3, 14, 15, 17, and 19 to check violations,  4, 6 to update offerings */
CREATE OR REPLACE PROCEDURE remove_session(i_course_id INTEGER, i_launch_date DATE, i_sess_number INTEGER)
AS $$
DECLARE
	session_date DATE;
	session_start_time TIME;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Sessions WHERE i_course_id = course_id and i_launch_date = launch_date and i_sess_number = sid) THEN
        RAISE EXCEPTION 'This session does not exist!';
    END IF;

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


/* Routine 24 */
/* Uses triggers 3, 14, 15, 17, and 19 to check violations,  4, 6 to update offerings */
CREATE OR REPLACE PROCEDURE add_session(in_cid INTEGER, l_date DATE, sess_id INTEGER, sess_day DATE,
                                sess_start TIME, eid INTEGER, rid INTEGER) AS $$
DECLARE 
    c_and_co RECORD;
BEGIN
    SELECT * into c_and_co FROM Offerings NATURAL JOIN Courses WHERE course_id = in_cid and launch_date=l_date;
    INSERT INTO Sessions VALUES 
    (sess_id, sess_day, sess_start, sess_start + INTERVAL '1 hour' * c_and_co.duration, c_and_co.course_id, c_and_co.launch_date,
    rid, eid);
END;
$$ LANGUAGE plpgsql;


/* Routine 25 */
/* Uses trigger 20 to check for violations */
CREATE OR REPLACE FUNCTION pay_salary()
RETURNS TABLE(eid INTEGER, name TEXT, status TEXT, num_work_days INTEGER, 
	num_work_hours INTEGER, hourly_rate FLOAT, monthly_salary FLOAT, amount FLOAT) AS $$
DECLARE
	curs CURSOR FOR (SELECT * FROM Employees 
        WHERE depart_date IS NULL OR DATE_TRUNC('MONTH', depart_date) = DATE_TRUNC('MONTH', CURRENT_DATE)
        ORDER BY eid ASC);
	r RECORD;
	partTime BOOLEAN;
    depart_this_month BOOLEAN;
    join_this_month BOOLEAN;
    first_work_day DATE;
    last_work_day DATE;
    days_in_month FLOAT;
BEGIN
	OPEN curs;
	LOOP
		FETCH curs INTO r;
		EXIT WHEN NOT FOUND;
		eid := r.eid;
		name := r.name;
		partTime := (SELECT EXISTS(SELECT 1 FROM Part_time_emp PTE WHERE PTE.eid = r.eid));
        join_this_month := (SELECT DATE_TRUNC('MONTH', r.join_date) = DATE_TRUNC('MONTH', CURRENT_DATE));
        depart_this_month := (SELECT r.depart_date IS NOT NULL 
            AND DATE_TRUNC('MONTH', r.depart_date) = DATE_TRUNC('MONTH', CURRENT_DATE));
        first_work_day := 
            CASE 
                WHEN join_this_month THEN r.join_date
                ELSE DATE_TRUNC('MONTH', CURRENT_DATE) 
            END;
        last_work_day := 
            CASE
                WHEN depart_this_month THEN r.depart_date
                ELSE DATE_TRUNC('MONTH', CURRENT_DATE) + INTERVAL '1 MONTH' - INTERVAL '1 DAY' 
            END;
		IF partTime THEN 
			status := 'part-time';
			num_work_hours := 
                (SELECT COALESCE(SUM(sess_hours), 0) FROM 
				    (SELECT ((EXTRACT(EPOCH FROM end_time)::INTEGER - EXTRACT(EPOCH FROM start_time)::INTEGER) / 3600) sess_hours
				    FROM Sessions S 
                    WHERE S.eid = r.eid 
                    AND s_date BETWEEN first_work_day AND last_work_day) AS Sess_hour_table);
			IF num_work_hours = 0 THEN 
                CONTINUE;
            END IF;
			num_work_days := NULL;
			hourly_rate := (SELECT PTE.hourly_rate FROM Part_time_emp PTE WHERE r.eid = PTE.eid);
			monthly_salary := NULL;
			amount := ROUND((num_work_hours * hourly_rate)::NUMERIC, 2);  -- ROUND TO 2 DECIMAL PLACES???
		ELSE
			status := 'full-time';
			num_work_hours := NULL;
			num_work_days := (SELECT EXTRACT(DAY FROM last_work_day)::INTEGER - EXTRACT(DAY FROM first_work_day)::INTEGER + 1);
			IF num_work_days = 0 THEN 
                CONTINUE;
            END IF;
			hourly_rate := NULL;
			monthly_salary := (SELECT FTE.monthly_salary FROM Full_time_emp FTE WHERE FTE.eid = r.eid);
            days_in_month := (SELECT EXTRACT('DAY' FROM DATE_TRUNC('MONTH', CURRENT_DATE) + INTERVAL '1 MONTH' - INTERVAL '1 DAY'));
			amount := ROUND((monthly_salary * num_work_days / days_in_month)::NUMERIC, 2); -- ROUND TO 2 DECIMAL PLACES???
		END IF;

		INSERT INTO Pay_slips (eid, payment_date, amt, num_work_hours, num_work_days) 
        VALUES (eid, CURRENT_DATE, amount, num_work_hours, num_work_days);

		RETURN NEXT;
	END LOOP;
	CLOSE curs;
END;
$$ LANGUAGE plpgsql;


/* Routine 26 */
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
					   and R.r_date > DATE(CURRENT_DATE - INTERVAL '6 months')) THEN
			OPEN ca_curs FOR (WITH CAreas AS
                              (WITH Registrations AS 
							   (SELECT R.sid, R.course_id, R.launch_date, R.r_date
							    FROM Registers R NATURAL JOIN Credit_cards C
							    WHERE customer.cust_id = C.cust_id)
							   SELECT C.course_area_name
							   FROM Registrations R NATURAL JOIN Courses C
							   ORDER BY R.r_date DESC
						  	   LIMIT 3)
                             SELECT DISTINCT CAreas.course_area_name
                             FROM CAreas);					  
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

/* Routine 27 */
CREATE OR REPLACE FUNCTION top_packages(top_limit_num INTEGER)
RETURNS TABLE (package_id INTEGER, num_free_registrations INTEGER, price FLOAT, sale_start_date DATE,
    sale_end_date DATE, num_package_sold INTEGER) AS $$
BEGIN
	IF top_limit_num < 1 THEN 
		RAISE EXCEPTION 'The number of top packages must larger or equal to 1.';
	END IF;
    RETURN QUERY
    WITH 
    Info_table AS (
        SELECT BC.package_id, BC.num_free_registrations, BC.price, 
            BC.sale_start_date, BC.sale_end_date, COUNT(*)::INTEGER AS num_package_sold
        FROM (Buys NATURAL JOIN Course_packages) BC
        WHERE BC.sale_start_date >= DATE_TRUNC('YEAR', CURRENT_DATE) 
        GROUP BY BC.package_id, BC.num_free_registrations, BC.price, 
            BC.sale_start_date, BC.sale_end_date
    ),
    Nth_info AS (
        SELECT IT.num_package_sold, IT.price
        FROM Info_table IT
        ORDER BY IT.num_package_sold DESC, IT.price DESC
        LIMIT 1
        OFFSET top_limit_num - 1
    )
    SELECT *
    FROM Info_table IT
    WHERE IT.num_package_sold >= (SELECT COALESCE(MAX(NI.num_package_sold), 0) FROM Nth_info NI)
	ORDER BY IT.num_package_sold DESC, IT.price DESC;
END;
$$ LANGUAGE plpgsql;


/* Routine 28 */
CREATE OR REPLACE FUNCTION popular_courses() 
RETURNS TABLE (course_id INTEGER, course_title TEXT, course_area TEXT, 
    num_offerings_this_year INTEGER, num_reg_of_latest_offering_this_year INTEGER) AS $$
BEGIN 
    WITH
    Curr_year_offerings AS (
        SELECT O.course_id, O.launch_date, start_date, 
            (SELECT COUNT(*) FROM Registers R 
            WHERE R.course_id = O.course_id AND R.launch_date = O.launch_date) num_reg
        FROM Offerings O
        WHERE start_date >= DATE_TRUNC('YEAR', CURRENT_DATE)
    ),
    Multi_off_courses AS (
        SELECT  CYO.course_id, COUNT(*) num_offerings, MAX(num_reg) num_reg_latest_off
        FROM Curr_year_offerings CYO
        GROUP BY  CYO.course_id
        HAVING COUNT(*) >= 2
    )
    SELECT M.course_id, 
        (SELECT title FROM Courses C WHERE C.course_id = M.course_id) AS course_title,
        (SELECT course_area_name FROM Courses C WHERE C.course_id = M.course_id) AS course_area,
        M.num_offerings, 
		M.num_reg_latest_off
	INTO course_id, course_title, course_area, num_offerings_this_year, num_reg_of_latest_offering_this_year
    FROM Multi_off_courses M
    WHERE NOT EXISTS 
        (SELECT 1 FROM Curr_year_offerings A, Curr_year_offerings B
        WHERE M.course_id = A.course_id AND A.course_id = B.course_id 
            AND A.launch_date <> B.launch_date AND A.start_date < B.start_date 
            AND A.num_reg >= B.num_reg)
    ORDER BY num_reg_latest_off DESC, course_id ASC;
	RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

/* Routine 29 */
CREATE OR REPLACE FUNCTION view_summary_report(num_month INTEGER) 
RETURNS TABLE (month_year TEXT, total_salary FLOAT, total_packages_sales_amt FLOAT, 
    total_reg_fees_card FLOAT, total_amt_refunded_fees FLOAT, total_num_reg_redeem INTEGER) AS $$
DECLARE
    first_day_of_month DATE := DATE_TRUNC('MONTH', CURRENT_DATE);
    last_day_of_month DATE := DATE_TRUNC('MONTH', CURRENT_DATE + INTERVAL '1 MONTH') - INTERVAL '1 DAY';
BEGIN
    FOR num_month_counter IN 1..num_month 
    LOOP
        month_year := TO_CHAR(first_day_of_month, 'FMMonth YYYY');
        total_salary := (SELECT COALESCE(SUM(amt), 0)
                        FROM Pay_slips 
                        WHERE payment_date BETWEEN first_day_of_month AND last_day_of_month);
        total_packages_sales_amt := 
            (SELECT COALESCE(SUM(package_sale_amt), 0)
            FROM (
                SELECT (COALESCE(price * COUNT(*), 0)) package_sale_amt
                FROM Buys NATURAL JOIN Course_packages
                WHERE b_date BETWEEN first_day_of_month AND last_day_of_month
                GROUP BY package_id, price) AS Package_sale_amt_table
            );
        total_reg_fees_card := 
            COALESCE(
				(SELECT COALESCE(SUM(offering_fees), 0)
            	FROM
                	(SELECT COALESCE((COUNT(*) * fees), 0) offering_fees
                	FROM (Registers NATURAL JOIN Offerings) RO
                	WHERE NOT EXISTS (
                    	SELECT 1 FROM Redeems Rdm 
                    	WHERE Rdm.course_id = RO.course_id AND Rdm.launch_date = RO.launch_date AND Rdm.sid = RO.sid
                        AND Rdm.number IN (SELECT number FROM Credit_cards 
                                        	WHERE cust_id = (SELECT cust_id FROM Credit_cards 
                                                        	WHERE number = RO.number)))
                    AND r_date BETWEEN first_day_of_month AND last_day_of_month
                GROUP BY course_id, launch_date, fees) off_fees)
            + 
            (SELECT COALESCE(SUM(offering_fees), 0)
            FROM
                (SELECT COALESCE((COUNT(*) * fees), 0) AS offering_fees
                FROM Cancels NATURAL JOIN Offerings
                WHERE refund_amt IS NOT NULL
                    AND payment_date BETWEEN first_day_of_month AND last_day_of_month
                GROUP BY course_id, launch_date, fees) off_fees_table), 0);
        total_amt_refunded_fees := 
            (SELECT COALESCE(SUM(refund_amt), 0)
            FROM Cancels
            WHERE c_date BETWEEN first_day_of_month AND last_day_of_month
                AND refund_amt IS NOT NULL);
        total_num_reg_redeem := 
            (SELECT COUNT(*) 
            FROM Redeems 
            WHERE r_date BETWEEN first_day_of_month AND last_day_of_month);
        RETURN NEXT;
        first_day_of_month := first_day_of_month - INTERVAL '1 MONTH';
        last_day_of_month := last_day_of_month - INTERVAL '1 MONTH';
    END LOOP;
END;
$$ LANGUAGE plpgsql;

/* Routine 30 */
CREATE OR REPLACE FUNCTION view_manager_report()
RETURNS TABLE (manager_name TEXT, num_course_areas INTEGER, num_co_ending_this_year INTEGER,
    net_reg_fees_co_ending_this_year FLOAT, co_title_highest_net_reg_fees TEXT[]) AS $$
DECLARE
    r RECORD;
    first_day_of_year DATE := DATE_TRUNC('YEAR', CURRENT_DATE);
    last_day_of_year DATE := DATE_TRUNC('YEAR', CURRENT_DATE) + INTERVAL '1 YEAR' - INTERVAL '1 DAY';
BEGIN
    FOR r IN SELECT * FROM Managers NATURAL JOIN Employees ORDER BY name ASC 
    LOOP
        manager_name := r.name;
        num_course_areas := (SELECT COUNT(*) FROM Course_areas WHERE eid = r.eid);
        num_co_ending_this_year := (SELECT COUNT(*)
                                    FROM (SELECT course_id, launch_date, end_date FROM Offerings) O
                                        NATURAL JOIN (SELECT course_id, course_area_name FROM Courses) C
                                        NATURAL JOIN (SELECT * FROM Course_areas) CA
                                    WHERE (end_date BETWEEN first_day_of_year AND last_day_of_year)
                                        AND eid = r.eid);
        WITH
        Valid_course_offs AS (
            SELECT course_id, launch_date, fees
            FROM (SELECT course_id, launch_date, fees, end_date FROM Offerings) O
                NATURAL JOIN (SELECT course_id, course_area_name FROM Courses) C
                NATURAL JOIN (SELECT * FROM Course_areas) CA
            WHERE (end_date BETWEEN first_day_of_year AND last_day_of_year)
            AND eid = r.eid
        ),
        Card_reg_fees_in_Registers AS (
            SELECT COALESCE((COUNT(*) * fees), 0) registers_card_reg_fees, course_id, launch_date
            FROM 
                ((SELECT course_id, launch_date, fees
                FROM Registers NATURAL JOIN Valid_course_offs)
                EXCEPT ALL
                (SELECT course_id, launch_date, fees
                FROM Redeems NATURAL JOIN Valid_course_offs)) Card_regs
            GROUP BY course_id, launch_date, fees
        ),
        Net_cancelled_card_reg_fees AS (
            SELECT (COALESCE(COUNT(*) * fees, 0) - COALESCE(SUM(refund_amt), 0)) cancels_card_reg_fees, course_id, launch_date
            FROM Cancels NATURAL JOIN Valid_course_offs
            WHERE package_credit IS NULL
            GROUP BY course_id, launch_date, fees
        ),
        No_credit_back_late_cancel_redemp_reg_fees AS (
            SELECT course_id, launch_date, COALESCE(SUM(reg_fees), 0) cancels_redemp_reg_fees
            FROM (
            SELECT course_id, launch_date,
                (SELECT COALESCE(ROUND(price / num_free_registrations), 0) session_price
                FROM Course_packages 
                WHERE package_id = 
                    (SELECT package_id 
                    FROM Buys 
                    WHERE b_date = CV.payment_date
                    AND number IN (SELECT number FROM Credit_cards WHERE cust_id = CV.cust_id)
                    LIMIT 1)) reg_fees
            FROM (Cancels NATURAL JOIN Valid_course_offs) CV
            WHERE refund_amt IS NULL AND package_credit = 0) KK
            GROUP BY course_id, launch_date
        ),
        Redemption_fees_Redeems AS (
            SELECT course_id, launch_date, COALESCE(SUM(reg_fees), 0) redeems_redemp_reg_fees
            FROM (
            SELECT course_id, launch_date,
                (SELECT COALESCE(ROUND(price / num_free_registrations), 0) AS session_price
                FROM Course_packages 
                WHERE package_id = RV.package_id) AS reg_fees
            FROM (Redeems NATURAL JOIN Valid_course_offs) RV) JQ
            GROUP BY course_id, launch_date
        ),
        Course_off_fees AS (
            SELECT course_id, launch_date, 
                (COALESCE((SELECT registers_card_reg_fees FROM Card_reg_fees_in_Registers A 
                            WHERE A.course_id = V.course_id AND A.launch_date = V.launch_date), 0)
                + COALESCE((SELECT cancels_card_reg_fees FROM Net_cancelled_card_reg_fees B 
                            WHERE B.course_id = V.course_id AND B.launch_date = V.launch_date), 0)
				+ COALESCE((SELECT cancels_redemp_reg_fees FROM No_credit_back_late_cancel_redemp_reg_fees C 
                            WHERE C.course_id = V.course_id AND C.launch_date = V.launch_date), 0)
				+ COALESCE((SELECT redeems_redemp_reg_fees FROM Redemption_fees_Redeems D 
                            WHERE D.course_id = V.course_id AND D.launch_date = V.launch_date), 0)
				) net_co_reg_fees
            FROM Valid_course_offs V
        )
        SELECT SUM(net_co_reg_fees), 
            ARRAY(SELECT title FROM Courses 
                WHERE course_id IN(SELECT course_id FROM Course_off_fees 
                                    GROUP BY course_id, net_co_reg_fees
                                    HAVING net_co_reg_fees = (SELECT MAX(net_co_reg_fees) 
                                                            FROM Course_off_fees)))
        INTO net_reg_fees_co_ending_this_year, co_title_highest_net_reg_fees
        FROM Course_off_fees COF;

        RETURN NEXT;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
