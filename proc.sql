CREATE OR REPLACE ROUTINE add_course()





CREATE OR REPLACE PROCEDURE add_customer(name TEXT, address TEXT, phone INTEGER, email TEXT, number INTEGER, expiry_date DATE, cvv INTEGER)
RETURNS VOID AS $$
    INSERT INTO Customers(name, address, phone, email)
    VALUES (name, address, phone, email);
	INSERT INTO Credit_cards(number, expiry_date, CVV, cust_id, from_date)
	VALUES (number, expiry_date, cvv, )