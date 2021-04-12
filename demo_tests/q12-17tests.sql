
/* routine 12 */
/* nothing much here, just listing */
select get_available_course_packages();

/* maybe */
select * from course_packages;

/* routine 13 */
select * from buys;
select * from credit_cards;
call buy_course_package(14,14);
select * from buys;

/* routine 14 */
select * from redeems;
select get_my_course_package(1);
select get_my_course_package(2);
select get_my_course_package(4);

/* routine 15 */
select * from offerings;
select get_available_course_offerings();


/* routine 16 */
select get_available_course_sessions(1, '2020-08-10');
select get_available_course_sessions(1, '2021-03-15');


/* routine 17 */
select * from registers;
call register_session(2, 5,  '2021-05-12', 1, 'redemption');

select get_my_course_package(2);