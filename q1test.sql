-- Correct insertions
CALL add_employee('Manager_01', 'maddress 1', 10000001, 'm1@mail.com', 15000, '2020-08-31', 'manager', ARRAY['CS']);
CALL add_employee('Part_time_instructor_01', 'ptiaddress 1', 20000001, 'pti1@mail.com', 80, '2021-01-01', 'part time instructor', ARRAY ['CS']);
CALL add_employee('Full_time_instructor_01', 'ftiaddress 1', 30000001, 'fti1@mail.com', 2000, '2021-01-01', 'full time instructor', ARRAY ['CS']);
CALL add_employee('Administrator_01', 'aaddress 1', 40000001, 'a1@mail.com', 2000, '2021-01-01', 'administrator');

-- Fail cases :
-- category is not correct
CALL add_employee('Fail', 'failaddress 1', 40400404, 'fail@mail.com', 404, '2020-08-31', 'jkoiua', ARRAY['CS']);
CALL add_employee('Fail', 'failaddress 1', 40400404, 'fail@mail.com', 404, '2020-08-31', 'man ager', ARRAY['CS']);

-- Manager's set of course areas is empty
CALL add_employee('Manager_FAIL', 'maddress 1', 40400404, 'm1@mail.com', 404, '2020-08-31', 'manager', ARRAY[]::TEXT[]);

-- Instructor's set of course areas is empty
CALL add_employee('Part_time_instructor_FAIL', 'ptiaddress 1', 20000001, 'pti1@mail.com', 80, '2021-01-01', 'part time instructor', ARRAY []::TEXT[]);
CALL add_employee('Full_time_instructor_FAIL', 'ftiaddress 1', 30000001, 'fti1@mail.com', 2000, '2021-01-01', 'full time instructor', ARRAY []::TEXT[]);

-- Administrator's set of course areas is not empty
CALL add_employee('Administrator_FAIL', 'aaddress 1', 40000001, 'a1@mail.com', 2000, '2021-01-01', 'administrator', ARRAY['CS']);