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
        RETURN NULL;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER emp_trigger
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
        RETURN NULL;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER part_time_emp_trigger
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
        RETURN NULL;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER full_time_emp_trigger
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
        RETURN NULL;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER instructor_trigger
BEFORE INSERT OR UPDATE ON Instructors
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION instructor_check();