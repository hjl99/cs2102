/* 18 */
/* SIMPLE VERSION */
CREATE OR REPLACE FUNCTION get_my_registrations(customer_id INTEGER)
RETURNS TABLE (course_name TEXT, course_fees INTEGER, sess_date DATE, sess_start_hour TIME, 
    sess_duration INTEGER, instr_name TEXT) AS $$
DECLARE
    curs CURSOR FOR (
        SELECT DISTINCT course_id, launch_date, sid, fees, s_date, start_time, end_time, eid
        FROM (Registers NATURAL JOIN Sessions NATURAL JOIN
            (SELECT course_id, launch_date, reg_deadline, fees FROM Offerings)) RSO
        WHERE number IN (SELECT number FROM Credit_cards WHERE cust_id = customer_id)
            AND CURRENT_DATE <= reg_deadline
        ORDER BY s_date, start_time;
    r RECORD;
BEGIN
    OPEN curs;
    LOOP
        FETCH curs INTO r;
        EXIT WHEN NOT FOUND;
        course_name := SELECT course_name FROM Courses C WHERE course_id = r.course_id;
        course_fees := r.fees;
        sess_date := r.s_date;
        sess_start_hour := r.start_time;
        sess_duration := SELECT EXTRACT(HOUR FROM (r.end_time - r.start_time));
        instr_name := SELECT name FROM Employees WHERE eid = r.eid;
        RETURN NEXT;
    END LOOP;
    CLOSE curs;
END;
$$ LANGUAGE plpgsql;

/* BOOKKEEPING VERSION */
CREATE OR REPLACE FUNCTION get_my_registrations(customer_id INTEGER)
RETURNS TABLE (course_name TEXT, course_fees INTEGER, sess_date DATE, sess_start_hour TIME, 
    sess_duration INTEGER, instr_name TEXT) AS $$
DECLARE
    curs CURSOR FOR (
        SELECT DISTINCT course_id, launch_date, sid, fees, s_date, start_time, end_time, eid
        FROM (Registers NATURAL JOIN Sessions NATURAL JOIN
            (SELECT course_id, launch_date, reg_deadline, fees FROM Offerings)) RSO
        WHERE number IN (SELECT number FROM Credit_cards WHERE cust_id = customer_id)
            AND CURRENT_DATE <= reg_deadline
            AND (SELECT COUNT(*) FROM Registers 
                    WHERE course_id = RSO.course_id AND launch_date = RSO.launch_date AND sid = RSO.sid
                        AND number IN (SELECT number FROM Credit_cards WHERE cust_id = customer_id))
                > (SELECT COUNT(*) FROM Cancels WHERE 
                    course_id = RSO.course_id AND launch_date = RSO.launch_date AND sid = RSO.sid AND cust_id = customer_id)
        ORDER BY s_date, start_time;
    r RECORD;
BEGIN
    OPEN curs;
    LOOP
        FETCH curs INTO r;
        EXIT WHEN NOT FOUND;
        course_name := SELECT course_name FROM Courses C WHERE course_id = r.course_id;
        course_fees := r.fees;
        sess_date := r.s_date;
        sess_start_hour := r.start_time;
        sess_duration := SELECT EXTRACT(HOUR FROM (r.end_time - r.start_time));
        instr_name := SELECT name FROM Employees WHERE eid = r.eid;
        RETURN NEXT;
    END LOOP;
    CLOSE curs;
END;
$$ LANGUAGE plpgsql;


/* 19 */
/* SIMPLE VERSION */
CREATE OR REPLACE PROCEDURE update_course_session(customer_id INTEGER, c_id INTEGER, 
    launch_d DATE, new_sess_id INTEGER) AS $$
DECLARE
    prev_sess_id INTEGER;
    prev_sess_rid INTEGER;
    prev_sess_eid INTEGER;
    sess_reg_ddl DATE;
    new_sess_rid INTEGER;
    new_sess_eid INTEGER;
    new_sess_seating_capacity INTEGER;
    new_sess_valid_reg_count INTEGER;
    cust_card_number INTEGER;

    /*prev_sess_date DATE;
    prev_sess_start_time TIME;
    new_sess_date DATE;
    new_sess_start_time TIME;*/
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Customers WHERE cust_id = customer_id)
        THEN RAISE EXCEPTION ('The customer specified does not exist.');
    END IF;

    SELECT number, sid, rid, eid INTO cust_card_number, prev_sess_id, prev_sess_rid, prev_sess_eid 
        FROM Registers R
        WHERE course_id = c_id 
            AND launch_date = launch_d
            AND number IN (SELECT number FROM Credit_cards WHERE cust_id = customer_id)

    SELECT rid, eid INTO new_sess_rid, new_sess_eid FROM Sessions 
        WHERE course_id = c_id AND launch_date = launch_d AND sid = new_sess_id;
    
    IF prev_sess_id IS NULL THEN RAISE EXCEPTION ('Customer has not registered for the course specified.');
    ELSIF new_sess_rid IS NULL THEN RAISE EXCEPTION ('The new session specified does not exist.');
    END IF;

    /* EITHER Checking for registration deadline */
    sess_reg_ddl := SELECT reg_deadline FROM Offerings WHERE course_id = c_id AND launch_date = launch_d;
    IF CURRENT_DATE >= sess_reg_ddl 
        THEN RAISE EXCEPTION ('No update on course sessions allowed after the registration deadline');
    END IF;
    /* OR Checking for time - if neither session has started */
    /*SELECT s_date, start_time INTO prev_sess_date 
        FROM Sessions WHERE course_id = c_id AND launch_date = launch_d AND sid = prev_sess_id;
    SELECT s_date, start_time INTO new_sess_date, new_sess_start_time
        FROM Sessions WHERE course_id = c_id AND launch_date = launch_d AND sid = new_sess_id;
    IF prev_sess_date + prev_sess_start_time <= CURRENT_TIMESTAMP OR new_sess_date + new_sess_end_time <= CURRENT_TIMESTAMP THEN  
        RAISE EXCEPTION ('Updates involving ongoing or finished session are not allowed.');
    END IF;*/

    new_sess_seating_capacity := SELECT seating_capacity FROM Rooms WHERE rid = new_sess_rid;
    new_sess_valid_reg_count := SELECT COUNT(*) FROM Registers 
                            WHERE course_id = c_id AND launch_date = launch_d AND sid = new_sess_id);
    IF new_sess_seating_capacity <= new_sess_valid_reg_count THEN RAISE EXCEPTION ('No vacancy in the new session.');
    ELSE UPDATE Registers SET eid = new_instr_id, r_date = CURRENT_DATE
            WHERE course_id = c_id AND launch_date = launch_d AND sid = new_sess_id;
    END IF;

END;
$$ LANGUAGE plpgsql;

/* BOOKKEEPING VERSION */
CREATE OR REPLACE PROCEDURE update_course_session(customer_id INTEGER, c_id INTEGER, 
    launch_d DATE, new_sess_id INTEGER) AS $$
DECLARE
    prev_sess_id INTEGER;
    prev_sess_rid INTEGER;
    prev_sess_eid INTEGER;
    sess_reg_ddl DATE;
    new_sess_rid INTEGER;
    new_sess_eid INTEGER;
    new_sess_seating_capacity INTEGER;
    new_sess_valid_reg_count INTEGER;
    cust_card_number INTEGER;

    prev_sess_date DATE;
    prev_sess_start_time TIME;
    new_sess_date DATE;
    new_sess_start_time TIME;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Customers WHERE cust_id = customer_id)
        THEN RAISE EXCEPTION ('The customer specified does not exist.');
    END IF;

    SELECT number, sid, rid, eid INTO cust_card_number, prev_sess_id, prev_sess_rid, prev_sess_eid 
        FROM Registers R
        WHERE course_id = c_id 
            AND launch_date = launch_d
            AND number IN (SELECT number FROM Credit_cards WHERE cust_id = customer_id)
            AND (SELECT COUNT(*) FROM Registers 
                    WHERE course_id = c_id AND launch_date = launch_d AND sid = R.sid
                        AND number IN (SELECT number FROM Credit_cards WHERE cust_id = customer_id))
                <> (SELECT COUNT(*) FROM Cancels 
                        WHERE course_id = c_id AND launch_date = launch_d AND sid = R.sid AND cust_id = customer_id);
                /* Since a course can be registered and canceled multiple times */

    SELECT rid, eid INTO new_sess_rid, new_sess_eid FROM Sessions 
        WHERE course_id = c_id AND launch_date = launch_d AND sid = new_sess_id;
    
    IF prev_sess_id IS NULL THEN RAISE EXCEPTION ('Customer has not registered for the course specified.');
    ELSIF new_sess_rid IS NULL THEN RAISE EXCEPTION ('The new session specified does not exist.');
    END IF;

    /* EITHER Checking for registration deadline */
    sess_reg_ddl := SELECT reg_deadline FROM Offerings WHERE course_id = c_id AND launch_date = launch_d;
    IF CURRENT_DATE >= sess_reg_ddl 
        THEN RAISE EXCEPTION ('No update on course sessions allowed after the registration deadline');
    END IF;
    /* OR Checking for time */
    /*SELECT s_date, start_time INTO prev_sess_date 
        FROM Sessions WHERE course_id = c_id AND launch_date = launch_d AND sid = prev_sess_id;
    SELECT s_date, start_time INTO new_sess_date, new_sess_start_time
        FROM Sessions WHERE course_id = c_id AND launch_date = launch_d AND sid = new_sess_id;
    IF prev_sess_date + prev_sess_start_time <= CURRENT_TIMESTAMP OR new_sess_date + new_sess_end_time <= CURRENT_TIMESTAMP THEN  
        RAISE EXCEPTION ('Updates involving ongoing or finished session are not allowed.');
    END IF;*/

    new_sess_seating_capacity := SELECT seating_capacity FROM Rooms WHERE rid = new_sess_rid;
    new_sess_valid_reg_count := (SELECT COUNT(*) FROM Registers 
                            WHERE course_id = c_id AND launch_date = launch_d AND sid = new_sess_id)
                        - (SELECT COUNT(*) FROM Cancels
                            WHERE course_id = c_id AND launch_date = launch_d AND sid = new_sess_id);
    IF new_sess_seating_capacity <= new_sess_valid_reg_count THEN RAISE EXCEPTION ('No vacancy in the new session.');
    ELSE
        INSERT INTO Cancels VALUES (CURRENT_DATE, null, 1, customer_id, c_id, launch_d, prev_sess_id, prev_sess_rid, prev_sess_eid);
        INSERT INTO Registers VALUES (cust_card_number, c_id, launch_d, new_sess_id, CURRENT_DATE, new_sess_rid, new_sess_eid);
    END IF;

END;
$$ LANGUAGE plpgsql;


/* 20 */

/* SIMPLE VERSION */
CREATE OR REPLACE PROCEDURE cancel_registration(customer_id INTEGER, c_id INTEGER, launch_d DATE) AS $$
DECLARE
    reg_count INTEGER;
    cancel_count INTEGER;
    late_cancel BOOLEAN;
    redeem_wo_card BOOLEAN;
    cancel_ddl DATE;
    refund_amt FLOAT;
    package_credit INTEGER;
    s_id INTEGER;
    r_id INTEGER;
    e_id INTEGER;
BEGIN
    IF EXISTS (SELECT 1 FROM Registers 
        WHERE number IN (SELECT number FROM Credit_cards WHERE cust_id = customer_id)
            AND course_id = c_id AND launch_date = launch_d)
        THEN RAISE EXCEPTION 'No registration to cancel';
    END IF;

    SELECT (s_date - INTERVAL '7 DAYS'), sid, rid, eid INTO cancel_ddl, s_id, r_id, e_id 
        FROM Sessions NATURAL JOIN Registers
        WHERE number IN (SELECT number FROM Credit_cards WHERE cust_id = customer_id)
            AND course_id = c_id AND launch_date = launch_d;
    late_cancel := CASE WHEN CURRENT_DATE > cancel_ddl THEN TRUE ELSE FALSE END;
    redeem_wo_card := EXISTS (SELECT 1 FROM Redeems WHERE course_id = c_id AND launch_date = launch_d
                        AND number IN (SELECT number FROM Credit_cards WHERE cust_id = customer_id));
    refund_amt := CASE WHEN (NOT redeem_wo_card) AND (NOT late_cancel) 
                        THEN 0.9 * (SELECT fees FROM Offerings WHERE course_id = c_id AND launch_date = launch_d)
                        ELSE 0 END;
    package_credit := CASE WHEN (redeem_wo_card AND (NOT late_cancel)) THEN 1 ELSE 0 END;
    /* Whether the refund_amt or package_credit shud be NULL depends on the constraints in Cancels */
    INSERT INTO Cancels VALUES (CURRENT_DATE, refund_amt, package_credit, customer_id, course_off_id, launch_d, s_id, r_id, e_id);
    IF redeem_wo_card AND (NOT late_cancel) THEN
        UPDATE Buys SET num_remaining_redemptions = num_remaining_redemptions + 1
            WHERE package_id = (SELECT package_id FROM Redeems 
                                    WHERE course_id = c_id AND launch_date = launch_d AND sid = s_id));
    END IF;
END;
$$ LANGUAGE plpgsql;

/* BOOKKEEPING VERSION */
CREATE OR REPLACE PROCEDURE cancel_registration(customer_id INTEGER, c_id INTEGER, launch_d DATE) AS $$
DECLARE
    reg_count INTEGER;
    cancel_count INTEGER;
    late_cancel BOOLEAN;
    redeem_wo_card BOOLEAN;
    cancel_ddl DATE;
    refund_amt FLOAT;
    package_credit INTEGER;
    s_id INTEGER;
    r_id INTEGER;
    e_id INTEGER;
BEGIN
    reg_count := SELECT COUNT(*) FROM Registers 
        WHERE number IN (SELECT number FROM Credit_cards WHERE cust_id = customer_id)
            AND course_id = c_id AND launch_date = launch_d);
    cancel_count := SELECT COUNT(*) FROM Cancels 
            WHERE cust_id = customer_id AND course_id = c_id AND launch_date = launch_d);

    IF reg_count = 0 THEN RAISE EXCEPTION 'No prior registration exists';
    ELSIF reg_count = cancel_count THEN RAISE EXCEPTION ('Registration already cancelled');
    END IF;

    SELECT (s_date - INTERVAL '7 DAYS'), sid, rid, eid INTO cancel_ddl, s_id, r_id, e_id 
        FROM Sessions NATURAL JOIN Registers
        WHERE number IN (SELECT number FROM Credit_cards WHERE cust_id = customer_id)
            AND course_id = c_id AND launch_date = launch_d;
    late_cancel := CASE WHEN SELECT (CURRENT_DATE > cancel_ddl) THEN TRUE ELSE FALSE END;
    redeem_wo_card := EXISTS (SELECT 1 FROM Redeems WHERE course_id = c_id AND launch_date = launch_d
                        AND number IN (SELECT number FROM Credit_cards WHERE cust_id = customer_id));
    refund_amt := CASE WHEN (NOT redeem_wo_card) AND (NOT late_cancel) 
                        THEN 0.9 * (SELECT fees FROM Offerings WHERE course_id = c_id AND launch_date = launch_d)
                        ELSE 0 END;
    package_credit := CASE WHEN (redeem_wo_card AND (NOT late_cancel)) THEN 1 ELSE 0 END;
    INSERT INTO Cancels VALUES (CURRENT_DATE, refund_amt, package_credit, customer_id, course_off_id, launch_d, s_id, r_id, e_id);
    IF redeem_wo_card AND (NOT late_cancel) THEN
        UPDATE Buys SET num_remaining_redemptions = num_remaining_redemptions + 1
            WHERE package_id = (SELECT package_id FROM Redeems WHERE sid = s_id));
    END IF;
END;
$$ LANGUAGE plpgsql;


/* 21 */
CREATE OR REPLACE PROCEDURE update_instructor(c_id INTEGER, launch_d DATE, 
    sess_id INTEGER, new_instr_id INTEGER) AS $$
DECLARE
    sess_date DATE;
    sess_start_time TIME;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Instructors WHERE eid = new_instr_id) THEN
        RAISE EXCEPTION ('The new instructor ID specified does not exist.');
    END IF;
    SELECT s_date, start_time INTO sess_date, sess_start_time 
        FROM Sessions WHERE course_id = c_id AND launch_date = launch_d AND sid = sess_id;
    IF s_date IS NULL THEN 
        RAISE EXCEPTION ('Course Session specified does not exist.');
    ELSIF CURRENT_TIMESTAMP < (sess_date + sess_start_time) THEN 
        RAISE EXCEPTION ('Changes cannot be made to an ongoing or finished session.');
    ELSE 
        UPDATE Sessions SET eid = new_instr_id 
            WHERE course_id = c_id AND launch_date = launch_d AND sid = sess_id;
    END IF;
END;
$$ LANGUAGE plpgsql;


/* 25 */
CREATE OR REPLACE FUNCTION pay_salary()
RETURNS TABLE(eid INTEGER, ename TEXT, estatus TEXT, num_work_days INTEGER, 
	num_work_hours INTEGER, hourly_rate FLOAT, monthly_salary FLOAT, amount FLOAT)
AS $$
DECLARE
	curs CURSOR FOR (SELECT * FROM Employees WHERE depart_date IS NULL ORDER BY eid ASC);
	r RECORD;
	partTime BOOLEAN;
BEGIN
	OPEN curs;
	LOOP
		FETCH curs INTO r;
		EXIT WHEN NOT FOUND;
		eid := r.eid;
		ename := r.name;
		partTime := EXISTS(SELECT 1 FROM Part_time_emp PTE WHERE r.eid=PTE.eid);
		IF partTime THEN 
			estatus := 'part-time';
			num_work_hours := SUM(
				SELECT ((EXTRACT(EPOCH FROM end_time)::INTEGER - EXTRACT(EPOCH FROM start_time)::INTEGER) / 3600)
				FROM Sessions WHERE eid = r.eid AND 
					SELECT EXTRACT(YEAR FROM date)::INTEGER = EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER
					AND SELECT EXTRACT(MONTH FROM date)::INTEGER = EXTRACT(MONTH FROM CURRENT_DATE)::INTEGER);
			IF num_work_hours = 0 THEN CONTINUE;
			num_work_days := NULL;
			hourly_rate := SELECT hourly_rate FROM Part_time_emp PTE WHERE r.eid=PTE.eid);
			monthly_salary := NULL;
			amount := num_work_hours * hourly_rate;
		ELSE
			estatus := 'full-time';
			num_work_hours := NULL;
			num_work_days := CASE
				WHEN SELECT EXTRACT(YEAR FROM r.join_date)::INTEGER = EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER
						AND SELECT EXTRACT(MONTH FROM r.join_date)::INTEGER = EXTRACT(MONTH FROM CURRENT_DATE)::INTEGER
					THEN SELECT EXTRACT(DAY FROM CURRENT_DATE)::INTEGER - EXTRACT(DAY FROM r.join_date)::INTEGER + 1
				ELSE SELECT EXTRACT(DAY FROM CURRENT_DATE)::INTEGER
				END
			IF num_work_days = 0 THEN CONTINUE;
			hourly_rate := NULL;
			monthly_salary := SELECT monthly_salary FROM Full_time_emp PTE WHERE r.eid=PTE.eid);
			amount := monthly_salary * (num_work_days / SELECT EXTRACT(DAY FROM CURRENT_DATE)::INTEGER);
		END IF;
		INSERT INTO Pay_slips VALUES (eid, CURRENT_DATE, amount, num_work_hours, num_work_days);
		RETURN NEXT;
	END LOOP;
	CLOSE curs;
END;
$$ LANGUAGE plpgsql;


