-- Adding customers
CALL add_customer('Customer_01', 'caddress 1', 00000001, 'c1@mail.com', 12345678234231209, '2023-01-01', 123);
CALL add_customer('Customer_02', 'caddress 2', 00000002, 'c2@mail.com', 98420312340987434, '2023-05-01', 456);

-- Correct cases :
CALL update_credit_card(1, 1111111111111111, '2025-01-01', 999);