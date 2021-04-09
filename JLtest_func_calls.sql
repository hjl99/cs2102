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

