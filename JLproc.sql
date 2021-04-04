/* 25 */
CREATE OR REPLACE FUNCTION pay_salary()
RETURNS TABLE(eid INTEGER, ename TEXT, estatus TEXT, num_work_days INTEGER, 
	num_work_hours INTEGER, hourly_rate FLOAT, monthly_salary FLOAT, amount FLOAT)
AS $$
DECLARE
	curs CURSOR FOR (SELECT * FROM Employees WHERE depart_date IS NULL ORDER BY eid ASC);
	r RECORD;
    eid INTEGER;
    ename TEXT;
	partTime BOOLEAN;
	estatus TEXT;
	num_work_days INTEGER;
	num_work_hours INTEGER;
	hourly_rate FLOAT;
	monthly_salary FLOAT;
	amount FLOAT;
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

