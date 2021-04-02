<<<<<<< HEAD




=======
>>>>>>> 25b2836dd94b48d9967e0c829000086f53f55067
/* 3 */
CREATE OR REPLACE FUNCTION add_customer(cname TEXT, caddress TEXT, cphone INTEGER, cemail TEXT, cnumber INTEGER, cexpiry_date DATE, ccvv INTEGER)
	RETURNS VOID 
AS $$
DECLARE 
	cid INTEGER;
BEGIN
    INSERT INTO Customers (name, address, phone, email)
    VALUES (cname, caddress, cphone, cemail) RETURNING cust_id INTO cid;
	INSERT INTO Credit_cards(number, expiry_date, CVV, cust_id)
	VALUES (cnumber, cexpiry_date, ccvv, cid);
END;
$$ LANGUAGE plpgsql;

/* 4 */
CREATE OR REPLACE FUNCTION update_credit_card(cid INTEGER, cnumber INTEGER, cexpiry_date DATE, ccvv INTEGER)
	RETURNS VOID 
AS $$
BEGIN
	INSERT INTO Credit_cards(number, expiry_date, CVV, cust_id)
	VALUES (cid, cexpiry_date, ccvv, cid);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION find_instructors(cid INTEGER, cnumber INTEGER, cexpiry_date DATE, ccvv INTEGER)
	RETURNS VOID 
AS $$
BEGIN
END;
$$ LANGUAGE plpgsql;

/* 12 */
CREATE OR REPLACE FUNCTION get_available_course_packages()
RETURNS TABLE (LIKE Course_packages) AS $$
	SELECT * 
	FROM Course_packages
	WHERE sale_end_date >= CURRENT_DATE and CURRENT_DATE >= sale_start_date;
$$ LANGUAGE sql;