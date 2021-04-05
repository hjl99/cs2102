/* 1 */
CREATE OR REPLACE FUNCTION customer_total_participation_func1() RETURNS TRIGGER AS $$
BEGIN
	IF (NEW.cust_id NOT IN (SELECT cust_id FROM Credit_cards)) THEN
		RAISE EXCEPTION 'Each Customer must own 1 or more credit cards!';
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER customer_total_participation_trigger
AFTER INSERT ON Customers
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW
EXECUTE FUNCTION customer_total_participation_func1();

CREATE OR REPLACE FUNCTION customer_total_participation_func2() RETURNS TRIGGER AS $$
BEGIN
	IF (OLD.cust_id NOT IN (SELECT cust_id FROM Credit_cards)) THEN
		RAISE EXCEPTION 'Each Customer must own 1 or more credit cards!';
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER customer_total_participation_trigger
AFTER DELETE ON Credit_cards
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW
EXECUTE FUNCTION customer_total_participation_func2();

/* Will consider combining the 2 functions for using TG_OP */
/* 2 */
CREATE OR REPLACE FUNCTION session_non_zero_func1() RETURNS TRIGGER AS $$
BEGIN
	IF ((SELECT count(*) FROM Sessions WHERE course_id=OLD.course_id and launch_date=OLD.launch_date and is_ongoing=true)=0) THEN
		RAISE EXCEPTION 'Each course offering must have one or more sessions!';
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER session_non_zero_trigger
AFTER INSERT ON Offerings
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW
EXECUTE FUNCTION session_non_zero_func1();

CREATE OR REPLACE FUNCTION session_non_zero_func2() RETURNS TRIGGER AS $$
BEGIN
	IF ((SELECT count(*) FROM Sessions WHERE course_id=OLD.course_id and launch_date=OLD.launch_date and is_ongoing=true)=0) THEN
		RAISE EXCEPTION 'Each course offering must have one or more sessions!';
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER session_non_zero_trigger
AFTER DELETE ON Sessions
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW
EXECUTE FUNCTION session_non_zero_func2();


/* 5 */
CREATE OR REPLACE FUNCTION concurrent_session_func() RETURNS TRIGGER AS $$
BEGIN
	IF EXISTS (SELECT * FROM Sessions S WHERE S.launch_date=NEW.launch_date and
			   S.course_id=NEW.course_id and S.s_date=NEW.s_date and S.start_time=NEW.start_time and is_ongoing=true) THEN
		RAISE EXCEPTION 'You cannot have more than 1 session per offering at the same date and time!';
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER concurrent_session_trigger
BEFORE INSERT ON Sessions
FOR EACH ROW
EXECUTE FUNCTION concurrent_session_func();


/* 6 */
CREATE OR REPLACE FUNCTION co_date_func() RETURNS TRIGGER AS $$
DECLARE
	r RECORD;
BEGIN
	SELECT * INTO r FROM Offerings O WHERE O.launch_date=NEW.launch_date and O.course_id=NEW.course_id;
	IF (NEW.s_date > r.end_date) THEN
		UPDATE Offerings O
		SET end_date=NEW.s_date WHERE O.launch_date=NEW.launch_date and O.course_id=NEW.course_id;
	ELSIF (NEW.s_date < r.start_date) THEN
		UPDATE Offerings O
		SET start_date=NEW.s_date WHERE O.launch_date=NEW.launch_date and O.course_id=NEW.course_id;
	END IF;
	RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER co_date_trigger
AFTER INSERT ON Sessions
FOR EACH ROW
EXECUTE FUNCTION co_date_func();

/* 8 */
CREATE OR REPLACE FUNCTION registration_func() RETURNS TRIGGER AS $$
DECLARE
BEGIN
	IF EXISTS (SELECT * FROM Registers R WHERE R.launch_date=NEW.launch_date and
		R.course_id=NEW.course_id and R.number=NEW.number) THEN
		RAISE EXCEPTION 'You cannot register for more than 1 session per offering!';
	ELSIF (NEW.r_date>(SELECT reg_deadline FROM Offerings O WHERE O.launch_date=NEW.launch_date and
		O.course_id=NEW.course_id)) THEN
		RAISE EXCEPTION 'You cannot register after the deadline!';
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER registration_trigger
BEFORE INSERT ON Registers
FOR EACH ROW
EXECUTE FUNCTION registration_func();

/* 9 */
CREATE OR REPLACE FUNCTION sum_capacity_func() RETURNS TRIGGER AS $$
BEGIN
	IF (TG_OP='INSERT') THEN
		UPDATE Offerings o
		SET seating_capacity=seating_capacity+(SELECT seating_capacity FROM Rooms R WHERE R.rid=NEW.rid)
		WHERE O.launch_date=NEW.launch_date and O.course_id=NEW.course_id;
	ELSIF (TG_OP='DELETE') THEN
		UPDATE Offerings o
		SET seating_capacity=seating_capacity-(SELECT seating_capacity FROM Rooms R WHERE R.rid=OLD.rid)
		WHERE O.launch_date=NEW.launch_date and O.course_id=NEW.course_id;
	ELSIF (TG_OP='UPDATE') THEN
		UPDATE Offerings o
		SET seating_capacity=seating_capacity+(SELECT seating_capacity FROM Rooms R WHERE R.rid=NEW.rid)-(SELECT seating_capacity FROM Rooms R WHERE R.rid=OLD.rid)
		WHERE O.launch_date=NEW.launch_date and O.course_id=NEW.course_id;
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER sum_capacity_trigger
AFTER INSERT OR DELETE OR UPDATE ON Sessions
FOR EACH ROW
EXECUTE FUNCTION sum_capacity_func();

/* 10 */
CREATE OR REPLACE FUNCTION registration_capacity_func() RETURNS TRIGGER AS $$
BEGIN
	IF (SELECT count(*) FROM Registers R WHERE R.launch_date=NEW.launch_date and
			   R.course_id=NEW.course_id and R.sid=NEW.sid and R.rid=NEW.rid and R.eid=NEW.eid) =
			   (SELECT seating_capacity FROM Rooms R WHERE R.rid=NEW.rid) THEN
		RAISE EXCEPTION 'The session is full!';
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER registration_capacity_trigger
BEFORE INSERT ON Registers
FOR EACH ROW
EXECUTE FUNCTION registration_capacity_func();

/* 11 */
CREATE OR REPLACE FUNCTION active_package_func() RETURNS TRIGGER AS $$
BEGIN
	IF EXISTS (SELECT * FROM Buys B WHERE B.number=NEW.number and B.num_remaining_redemptions > 0) THEN
		RAISE EXCEPTION 'You can only have 1 active or partially active package!';
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER active_package_trigger
BEFORE INSERT ON Buys
FOR EACH ROW
EXECUTE FUNCTION active_package_func();

/* 12 */
CREATE OR REPLACE FUNCTION package_redemption_check()
RETURNS TRIGGER AS $$
DECLARE
	customer_id INTEGER;
BEGIN
	SELECT C.cust_id INTO customer_id
	FROM Credit_cards C
	WHERE NEW.number = C.number;
	
	IF EXISTS (SELECT 1
			   FROM Redeems R NATURAL JOIN Buys B NATURAL JOIN Credit_cards C
			   WHERE C.cust_id = customer_id
			   and NEW.sid = R.sid
			   and NEW.course_id = R.course_id
			   and NEW.launch_date = R.launch_date
			   and NEW.rid = R.rid
			   and NEW.eid = R.eid) THEN
	 	RAISE EXCEPTION 'Course fee is paid by package redemption!';
		RETURN NULL;
	END IF;
	RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER course_fee_paid_by_redemption_trigger
BEFORE INSERT OR UPDATE ON Registers
FOR EACH ROW EXECUTE FUNCTION package_redemption_check();

CREATE OR REPLACE FUNCTION card_payment_check()
RETURNS TRIGGER AS $$
DECLARE
	customer_id INTEGER;
BEGIN
	SELECT C.cust_id INTO customer_id
	FROM Buys B NATURAL JOIN Credit_cards C
	WHERE NEW.package_id = B.package_id
	and NEW.number = B.number
	and NEW.b_date = B.b_date;
	
	IF EXISTS (SELECT 1
			   FROM Registers R NATURAL JOIN Credit_cards C
			   WHERE C.cust_id = customer_id
			   and NEW.sid = R.sid
			   and NEW.course_id = R.course_id
			   and NEW.launch_date = R.launch_date
			   and NEW.rid = R.rid
			   and NEW.eid = R.eid) THEN
		RAISE EXCEPTION 'Course fee is paid by credit card!';
		RETURN NULL;
	END IF;
	RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER course_fee_paid_by_card_trigger
BEFORE INSERT OR UPDATE ON Redeems
FOR EACH ROW EXECUTE FUNCTION card_payment_check();

/* 13 */
CREATE OR REPLACE FUNCTION emp_check()
RETURNS TRIGGER AS $$
DECLARE
    num INTEGER;
BEGIN
    num := 0;
    
	IF (NEW.eid IN (SELECT eid FROM Part_time_emp))
	THEN
		num := num + 1;
    ELSIF (NEW.eid IN (SELECT eid FROM Full_time_emp))
    THEN
        num := num + 1;
	END IF;

    IF (num <> 1) THEN 
        RAISE EXCEPTION 'Every employee must be either a part time or full time employee!';
        RETURN NULL;
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER emp_trigger
BEFORE INSERT OR UPDATE ON Employees
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION emp_check();

/* 14 */
CREATE OR REPLACE FUNCTION part_time_emp_check()
RETURNS TRIGGER AS $$
DECLARE
    num INTEGER;
BEGIN
    num := 0;
	IF (NEW.eid IN (SELECT eid FROM Part_time_instructors))
	THEN
		num := num + 1;
	END IF;

    IF (num <> 1) THEN
        RAISE EXCEPTION 'Every part time employee must be a part time instructor!';
        RETURN NULL;
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER part_time_emp_trigger
BEFORE INSERT OR UPDATE ON Part_time_emp
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION part_time_emp_check();

/* 15 */
CREATE OR REPLACE FUNCTION full_time_emp_check()
RETURNS TRIGGER AS $$
DECLARE
    num INTEGER;
BEGIN
    num := 0;
	IF (NEW.eid IN (SELECT eid FROM Full_time_instructors)) THEN
		num := num + 1;
    ELSIF (NEW.eid IN (SELECT eid FROM Administrators)) THEN
        num := num + 1;
    ELSIF (NEW.eid IN (SELECT eid FROM Managers)) THEN
        num := num + 1;
	END IF;

    IF (num <> 1) THEN
        RAISE EXCEPTION 'Every full time employee must be either a full time instructor, an administrator or a manager!';
        RETURN NULL;
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER full_time_emp_trigger
BEFORE INSERT OR UPDATE ON Full_time_emp
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION full_time_emp_check();

/* 16 */
CREATE OR REPLACE FUNCTION instructor_check()
RETURNS TRIGGER AS $$
DECLARE
    num INTEGER;
BEGIN
    num := 0;
	IF (NEW.eid IN (SELECT eid FROM Full_time_instructors)) THEN
		num := num + 1;
    ELSIF (NEW.eid IN (SELECT eid FROM Part_time_instructors)) THEN
        num := num + 1;
	END IF;

    IF (num <> 1) THEN
        RAISE EXCEPTION 'Every instructor must be either a part time or full time instructor!';
        RETURN NULL;
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER instructor_trigger
BEFORE INSERT OR UPDATE ON Instructors
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION instructor_check();

/* 17 */
CREATE OR REPLACE FUNCTION part_time_instructor_teaching_hour_check()
RETURNS TRIGGER AS $$
DECLARE
	total_hour INTEGER;
BEGIN
	SELECT SUM(DATE_PART('hour', S.end_time - S.start_time)) INTO total_hour
	FROM Sessions S NATURAL JOIN Part_time_instructors P
	WHERE NEW.eid = S.eid and DATE_PART('month', S.s_date) = DATE_PART('month', NEW.s_date) and is_ongoing=true;
	
	IF (total_hour > 30) THEN
		RAISE EXCEPTION 'The teaching hours of this part time instructor exceeds the limit for the month!';
	END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER part_time_instructor_teaching_hour_trigger
AFTER INSERT OR UPDATE ON Sessions
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION part_time_instructor_teaching_hour_check();

/* 18 */
CREATE OR REPLACE FUNCTION instructor_consecutive_sessions_check()
RETURNS TRIGGER AS $$
DECLARE
	num_of_consecutive_sessions INTEGER;
BEGIN
	SELECT COUNT(*)
	INTO num_of_consecutive_sessions
	FROM SESSIONS S
	WHERE S.s_date = NEW.s_date and 
		  ((NEW.start_time > S.end_time and DATE_PART('hour', NEW.start_time - S.end_time) < 1) and is_ongoing=true or
		  (S.start_time > NEW.end_time and DATE_PART('hour', S.start_time - NEW.end_time) < 1));
	
	IF (num_of_consecutive_sessions > 0) THEN
		RAISE EXCEPTION 'Each instructor must not be assigned to teach two consecutive course sessions!';
		RETURN NULL;
	END IF;
	RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER instructor_consecutive_sessions_trigger
BEFORE INSERT OR UPDATE ON Sessions
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION instructor_consecutive_sessions_check();

/* 19 */
CREATE OR REPLACE FUNCTION redeems_func() RETURNS TRIGGER AS $$
DECLARE
BEGIN
	UPDATE Buys B
	SET num_remaining_redemptions = num_remaining_redemptions - 1
	WHERE B.package_id=NEW.package_id and B.number=NEW.number and B.b_date=NEW.b_date;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER redeems_trigger
AFTER INSERT ON Redeems
FOR EACH ROW
EXECUTE FUNCTION redeems_func();

/* 21 */
CREATE OR REPLACE FUNCTION session_valid_bit_func() RETURNS TRIGGER AS $$
BEGIN
	IF NOT EXISTS (SELECT * FROM Sessions S WHERE S.launch_date=OLD.launch_date and
			   S.course_id=OLD.course_id and S.s_date=OLD.s_date and S.start_time=OLD.start_time and is_ongoing=true) THEN
		RAISE EXCEPTION 'Session to be deleted does not exist!';
	ELSE
		UPDATE Sessions S
		SET is_ongoing=false
		WHERE S.launch_date=OLD.launch_date and S.course_id=OLD.course_id and S.s_date=OLD.s_date and S.start_time=OLD.start_time;
		RETURN NULL;
	END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER session_valid_bit_trigger
BEFORE DELETE ON Sessions
FOR EACH ROW
EXECUTE FUNCTION session_valid_bit_func();