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

/* 13 */
CREATE OR REPLACE FUNCTION buy_course_package(cid INTEGER, pid INTEGER)
RETURNS VOID AS $$
DECLARE
	cnum INTEGER;
	rnum INTEGER;
BEGIN
	cnum := (SELECT number FROM Credit_cards WHERE cust_id=cid ORDER BY from_date DESC LIMIT 1);
	IF NOT EXISTS (SELECT * FROM Buys WHERE number=cnum and num_remaining_redemptions > 0) and 
		(pid IN (SELECT package_id FROM get_course_packages())) THEN
		rnum := (SELECT num_free_registrations FROM get_course_packages() WHERE package_id=pid);
		INSERT INTO Buys (number, package_id, num_remaining_redemptions) VALUES (cnum, pid, rnum);
	END IF;
END;
$$ LANGUAGE plpgsql;

/* 25 */
CREATE OR REPLACE FUNCTION pay_salary()
RETURNS @salTable TABLE(eid INTEGER, ename TEXT, estatus TEXT, num_work_days INTEGER, 
	num_work_hours INTEGER, hourly_rate FLOAT, monthly_salary FLOAT, amount FLOAT)
AS 
BEGIN
	DECLARE @partTime BOOLEAN;
	SET @partTime = EXISTS(SELECT 1 FROM Part_time_emp PTE WHERE P.eid=PTE.eid);
	SELECT eid, 
		(SELECT name FROM Employees E WHERE E.eid=P.eid) name,
		(CASE 
			WHEN @partTime THEN 'part-time'
			ELSE THEN 'full-time') estatus,
		(CASE 
			WHEN @partTime THEN NULL
			ELSE THEN (SELECT )) estatus,
	FROM Pay_slips P
	ORDER BY eid ASC;
END;
$$ LANGUAGE plpgsql;

