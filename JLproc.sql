/* 18 */
CREATE OR REPLACE FUNCTION get_my_registrations(c_id INTEGER)
RETURNS TABLE (c_name TEXT, c_fees INTEGER, s_date DATE, s_start_hour TIME, 
    s_duration INTEGER, instr_name TEXT) AS $$
DECLARE
    curs CURSOR FOR (
        SELECT * 
        FROM Registers NATURAL JOIN Sessions RS
        WHERE number IN (SELECT number 
                        FROM Credit_cards CC 
                        WHERE CC.cust_id = RS.c_id)
            AND CURRENT_DATE <= (SELECT registration_deadline 
                                FROM Offerings O
                                WHERE RS.course_id = O.course_id AND RS.launch_date = O.launch_date)
            AND NOT EXISTS (SELECT 1 FROM Cancels C WHERE RS.rid = C.rid);
    r RECORD;
BEGIN
    OPEN curs;
    LOOP
        FETCH curs INTO r;
        EXIT WHEN NOT FOUND;
        c_name := SELECT course_name FROM Courses C WHERE r.course_id = C.course_id;
        c_fees := SELECT fees FROM Offerings O WHERE r.course_id = O.course_id AND r.launch_date = O.launch_date;
        s_date := r.s_date;
        s_start_hour := r.start_time;
        s_duration := SELECT EXTRACT(HOUR FROM (r.end_time - r.start_time));
        instr_name := SELECT name FROM Employees WHERE eid = r.eid;
        RETURN NEXT;
    END LOOP;
    CLOSE curs;
END;
$$ LANGUAGE plpgsql;


/* 19 */
CREATE OR REPLACE PROCEDURE update_course_session(cust_id INTEGER, co_id INTEGER, s_id INTEGER) AS $$

BEGIN

END;
$$ LANGUAGE plpgsql;


/* 20 */
CREATE OR REPLACE PROCEDURE cancel_registration(customer_id INTEGER, course_off_id INTEGER) AS $$
DECLARE
    reg_count INTEGER;
    late_cancel BOOLEAN;
    redeem_wo_card BOOLEAN;
    cancel_ddl DATE;
    refund_amt FLOAT;
    package_credit INTEGER;
    s_id INTEGER;
    r_id INTEGER;
    e_id INTEGER;
    launch_d DATE;
BEGIN
    reg_count := COUNT(SELECT * FROM Registers WHERE 
        number IN (SELECT number FROM Credit_cards WHERE cust_id = customer_id)
        AND course_id = course_off_id);
    IF reg_count = 0 THEN RAISE EXCEPTION 'No prior registration exists';
    ELSIF reg_count = COUNT(SELECT * FROM Cancels WHERE cust_id = customer_id AND course_id = course_off_id)
        THEN RAISE EXCEPTION ('Registration already cancelled');
    END IF;
    SELECT (s_date - INTERVAL '7 DAYS'), sid, rid, eid, launch_date INTO cancel_ddl, s_id, r_id, e_id, launch_d
        FROM Sessions NATURAL JOIN Registers
        WHERE number IN (SELECT number FROM Credit_cards WHERE cust_id = customer_id)
            AND course_id = course_off_id;
    late_cancel := CASE WHEN SELECT (CURRENT_DATE > cancel_ddl) THEN TRUE ELSE FALSE END;
    redeem_wo_card := EXISTS (SELECT 1 FROM Redeems WHERE course_id = course_off_id
                        AND number IN (SELECT number FROM Credit_cards WHERE cust_id = customer_id));
    refund_amt := CASE WHEN (NOT redeem_wo_card) AND (NOT late_cancel) 
                        THEN 0.9 * (SELECT fees FROM Offerings WHERE course_id = course_off_id AND launch_date = launch_d)
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
CREATE OR REPLACE PROCEDURE update_instructor(co_id INTEGER, sess_id INTEGER, new_instr_id INTEGER) AS $$
DECLARE
    sess_date DATE;
    sess_start_time TIME;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Sessions WHERE course_id = co_id AND sid = sess_id) THEN 
        RAISE EXCEPTION ('Course Session specified does not exist.');
    ELSIF NOT EXISTS (SELECT 1 FROM Instructors WHERE eid = new_instr_id) THEN
        RAISE EXCEPTION ('The new instructor ID specified does not exist.');
    END IF;
    SELECT s_date, start_time INTO sess_date, sess_start_time 
        FROM Sessions WHERE course_id = co_id AND sid = sess_id;
    IF SELECT (CURRENT_TIMESTAMP < (sess_date + sess_start_time)) THEN 
        RAISE EXCEPTION ('Changes cannot be made to an ongoing or finished session.');
    ELSE 
        UPDATE Sessions SET eid = new_instr_id WHERE course_id = co_id AND sid = sess_id;
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

