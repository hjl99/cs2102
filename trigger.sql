CREATE OR REPLACE FUNCTION customer_total_participation_func1() RETURNS TRIGGER AS $$
DECLARE
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
DECLARE
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


CREATE OR REPLACE FUNCTION session_non_zero_func1() RETURNS TRIGGER AS $$
DECLARE
BEGIN
	IF ((SELECT count(*) FROM Sessions WHERE course_id=OLD.course_id and launch_date=OLD.launch_date)=0) THEN
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