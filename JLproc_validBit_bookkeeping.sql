/* Requires triggers to enforce that each customer can register for at most one sesion of a course */
CREATE TABLE Registers (
    number INTEGER REFERENCES Credit_cards ON DELETE CASCADE,
    course_id INTEGER,
    launch_date DATE,
    sid INTEGER,
    r_date DATE,
    status TEXT IN ('valid', 'cancelled', '')
    FOREIGN KEY (sid, course_id, launch_date) REFERENCES Sessions ON DELETE NO ACTION, 
    PRIMARY KEY (course_id, launch_date, sid, number, r_date)
);

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
    DELETE FROM Registers WHERE number IN (SELECT number FROM Credit_cards WHERE cust_id = customer_id)
            AND course_id = c_id AND launch_date = launch_d;
    INSERT INTO Cancels VALUES (CURRENT_DATE, refund_amt, package_credit, customer_id, course_off_id, launch_d, s_id, r_id, e_id);
    IF redeem_wo_card AND (NOT late_cancel) THEN
        UPDATE Buys SET num_remaining_redemptions = num_remaining_redemptions + 1
            WHERE package_id = (SELECT package_id FROM Redeems 
                                    WHERE course_id = c_id AND launch_date = launch_d AND sid = s_id));
        DELETE FROM Redeems /* DELETE RECORD??? */
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


/* 27 */
CREATE OR REPLACE FUNCTION top_packages(N INTEGER)
RETURNS TABLE (package_id INTEGER, num_free_registrations INTEGER, price FLOAT, sale_start_date DATE,
    sale_end_date DATE, num_package_sold INTEGER) AS $$
BEGIN
    RETURN QUERY /* TO FIX ERROR:  query has no destination for result data */
    WITH 
    Info_table AS (
        SELECT package_id, num_free_registrations, price, 
            sale_start_date, sale_end_date, COUNT(*) AS num_package_sold
        FROM Buys NATURAL JOIN Course_packages
        WHERE sale_start_date >= DATE_TRUNC('YEAR', CURRENT_DATE) 
        GROUP BY package_id
    ),
    Nth_info AS (
        SELECT num_package_sold, price
        FROM Info_table
        ORDER BY num_package_sold DESC, price DESC
        LIMIT 1
        OFFSET N - 1
    )
    SELECT *
    FROM Info_table
    WHERE num_package_sold > SELECT MAX(num_package_sold) FROM Nth_info
        OR (num_package_sold = SELECT MAX(num_package_sold) FROM Nth_info
            AND price >= SELECT MAX(price) FROM Nth_info);
END;
$$ LANGUAGE plpgsql;

/* 28 */
CREATE OR REPLACE FUNCTION popular_courses() 
RETURNS TABLE (course_id INTEGER, course_title TEXT, course_area TEXT, 
    num_offerings INTEGER, num_reg_latest_off INTEGER) AS $$
BEGIN 
    RETURN QUERY
    WITH
    Curr_year_offerings AS (
        SELECT course_id, launch_date, start_date, 
            (SELECT COUNT(*) FROM Registers R WHERE R.course_id = O.course_id AND R.launch_date = O.launch_date) num_reg
        FROM Offerings O
        WHERE start_date >= DATE_TRUNC('YEAR', CURRENT_DATE)
    ),
    Multi_off_courses AS (
        SELECT course_id, COUNT(*) num_offerings, MAX(num_reg) num_reg_latest_off
        FROM Curr_year_offerings
        GROUP BY course_id
        HAVING COUNT(*) >= 2;
    )
    SELECT course_id, (SELECT title FROM Courses C WHERE C.course_id = M.course_id) course_title,
        (SELECT course_area_name FROM Courses C WHERE C.course_id = M.course_id) course_area,
        num_offerings, num_reg_latest_off
    FROM Multi_off_courses M
    WHERE NOT EXISTS (SELECT 1 FROM Curr_year_offerings A, Curr_year_offerings B
        WHERE M.course_id = A.course_id AND A.course_id = B.course_id AND A.launch_date <> B.launch_date
                AND A.start_date < B.start_date AND A.num_reg >= B.num_reg)
    ORDER BY num_reg_latest_off DESC, course_id ASC;
END;
$$ LANGUAGE plpgsql;


/* 29 */
CREATE OR REPLACE FUNCTION view_summary_report(num_month INTEGER) 
RETURNS TABLE (month INTEGER, year INTEGER, total_salary FLOAT, total_packages_sales_amt FLOAT, 
    total_reg_fees_card FLOAT, total_amt_refunded_fees FLOAT, total_num_reg_redeem INTEGER) AS $$
DECLARE
    first_day_of_month := DATE_TRUNC('MONTH', CURRENT_DATE);
    last_day_of_month := DATE_TRUNC('MONTH', CURRENT_DATE + INTERVAL '1 MONTH') - INTERVAL '1 DAY';
BEGIN
    FOR num_month_counter IN 1..num_month 
    LOOP
        month := SELECT EXTRACT ('MONTH' FROM first_day_of_month);
        year := SELECT EXTRACT ('YEAR' FROM first_day_of_month);
        total_salary := SELECT SUM(amt) FROM Pay_slips 
            WHERE payment_date BETWEEN first_day_of_month AND last_day_of_month;
        total_packages_sales_amt := 
            SELECT SUM(package_sale_amt) 
            FROM (
                SELECT (price * COUNT(*)) package_sale_amt
                FROM Buys NATURAL JOIN Course_packages
                WHERE b_date BETWEEN first_day_of_month AND last_day_of_month
                GROUP BY package_id, price);
        /* registration fees exclude paid/leftover fees of the early-cancelled registrations */
        total_reg_fees_card := SELECT SUM(offering_fees) FROM
            (SELECT COUNT(*) * (SELECT fees FROM Offerings O 
                    WHERE O.course_id = Rgst.course_id AND O.launch_date = Rgst.launch_date) offering_fees
            FROM Registers Rgst
            WHERE NOT EXISTS (SELECT 1 FROM Redeems Rdm 
                        WHERE Rdm.course_id = Rgst.course_id 
                            AND Rdm.launch_date = Rgst.launch_date 
                            AND Rdm.sid = Rgst.sid
                            AND Rdm.number = Rgst.number)
            GROUP BY course_id, launch_date);
        total_amt_refunded_fees := SELECT SUM(refund_amt) FROM Cancels
            WHERE c_date BETWEEN first_day_of_month AND last_day_of_month;
        total_num_reg_redeem := SELECT COUNT(*) FROM Redeems 
            WHERE r_date BETWEEN first_day_of_month AND last_day_of_month;
        RETURN NEXT;
        first_day_of_month := first_day_of_month - INTERVAL '1 MONTH';
        last_day_of_month := last_day_of_month - INTERVAL '1 MONTH';
    END LOOP;
END;
$$ LANGUAGE plpgsql;

/* 30 */
CREATE OR REPLACE FUNCTION 