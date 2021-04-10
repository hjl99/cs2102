/* q18 */
SELECT * FROM get_my_registrations(1);
SELECT * FROM get_my_registrations(2);
SELECT * FROM get_my_registrations(3);
SELECT * FROM get_my_registrations(4);

/* q19 */
SELECT * FROM get_my_registrations(1);
Call update_course_session(1, 1, DATE'2021-05-01', 1);
Call update_course_session(1, 1, DATE'2021-05-01', 2);
SELECT * FROM get_my_registrations(1);
Call update_course_session(1, 1, DATE'2021-03-01', 2);

Call update_course_session(1, 1, DATE'2021-04-01', 2);

/* q20 */
CALL cancel_registration(1, 1, DATE'2021-03-01');
CALL cancel_registration(4, 2, DATE'2021-04-02');


SELECT * FROM Redeems;
SELECT * FROM Cancels;
SELECT * FROM Registers;
SELECT * FROM Buys;
SELECT * FROM Course_packages;

/*
cancel reg by credit card no refund - co launched, session starting tmr, no redeems 
cancel reg by credit card has refund - co launched, session starting after 7 days, no redeems 
cancel reg by redemption no package credit - co launched, session starting tmr, yes redeems 
cancel reg by redemption has package credit - co launched, session starting after 7 days, yes redeems */

CALL cancel_registration(3, 1, DATE'2021-03-01');
CALL cancel_registration(5, 1, DATE'2021-03-01');
CALL cancel_registration(6, 1, DATE'2021-03-01');
CALL cancel_registration(7, 1, DATE'2021-03-01');

SELECT * FROM Cancels;
