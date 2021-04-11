/* routine 20 */
SELECT * FROM Cancels;
CALL cancel_registration(3, 1, DATE'2021-03-01');
SELECT * FROM Cancels;
CALL cancel_registration(5, 1, DATE'2021-03-01');
SELECT * FROM Cancels;
CALL cancel_registration(6, 1, DATE'2021-03-01');
SELECT * FROM Cancels;
CALL cancel_registration(7, 1, DATE'2021-03-01');
SELECT * FROM Cancels;
/* Then call with invalid customer number, or wrong course number, or wrong offering date
To result in no record found */


/* routine 25 */
SELECT * FROM pay_salary();

SELECT * FROM Pay_slips;
/* Salary records are input into the table */


/* routine 26 */
SELECT * FROM promote_courses();
/* part-time instructor 2 did not conduct any session this month, so the instructor is omitted from the output */


/* routine 27 */
SELECT * FROM top_packages(1);
SELECT * FROM top_packages(2);
SELECT * FROM top_packages(5);
/* invalid input */
SELECT * FROM top_packages(0);


/* routine 28 */
SELECT * FROM popular_courses();



/* routine 29 */
SELECT * FROM view_summary_report();


/* routine 30 */
SELECT * FROM view_manager_report();
