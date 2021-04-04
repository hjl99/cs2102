CREATE OR REPLACE FUNCTION customer_total_participation_func() RETURNS TRIGGER AS $$
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
EXECUTE FUNCTION customer_total_participation_func();