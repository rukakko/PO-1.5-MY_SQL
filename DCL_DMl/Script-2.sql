set search_path to hotel_schema;

create role hotel_admin;
create role hotel_readonly;

grant usage on schema hotel_schema to hotel_admin;
grant usage on schema hotel_schema to hotel_readonly;

grant select, insert, update, delete
on all tables in schema hotel_schema
to hotel_admin;

grant select
on all tables in schema hotel_schema
to hotel_readonly;

grant usage, select
on all sequences in schema hotel_schema
to hotel_admin;

grant usage, select
on all sequences in schema hotel_schema
to hotel_readonly;

revoke update, delete
on all tables in schema hotel_schema
from hotel_readonly;


create user db_admin_user
with password 'admin123';

create user db_reader_user
with password 'reader123';

grant hotel_admin to db_admin_user;
grant hotel_readonly to db_reader_user;

revoke hotel_readonly
from db_admin_user;



truncate Booking_service cascade;
truncate Payment cascade;
truncate Guest cascade;
truncate Booking cascade;
truncate Staff cascade;
truncate Room cascade;
truncate Service cascade;
truncate Customer cascade;
truncate Room_type cascade;
truncate Hotel cascade;



insert into Hotel
(name,address,city,country,phone,email)
values
('Ritz Hotel','Abay 12','Almaty','Kazakhstan','87011111111','ritzhotel@mail.com'),
('Sky Hotel','Satpaev 21','Astana','Kazakhstan','87022222222','skyhotel@mail.com'),
('Grand Palace','Auezov 15','Atyrau','Kazakhstan','87033333333','grand@mail.com'),
('Elite Inn','Mira 17','Shymkent','Kazakhstan','87044444444','elite@mail.com'),
('Royal Stay','Tauelsizdik 8','Aktau','Kazakhstan','87055555555','royal@mail.com');


insert into Room_type
(type_name,price_per_night,max_capacity)
values
('Single',12000,1),
('Double',18000,2),
('Family',30000,4),
('Suite',45000,3),
('Luxury',70000,5);


insert into Room
(hotel_id,room_type_id,room_number,status)
values
(
(select hotel_id from hotel where name='Ritz Hotel'),
(select room_type_id from room_type where type_name='Single'),
'101',
'Available'
),

(
(select hotel_id from hotel where name='Sky Hotel'),
(select room_type_id from room_type where type_name='Double'),
'202',
'Occupied'
),

(
(select hotel_id from hotel where name='Grand Palace'),
(select room_type_id from room_type where type_name='Family'),
'303',
'Available'
),

(
(select hotel_id from hotel where name='Elite Inn'),
(select room_type_id from room_type where type_name='Suite'),
'404',
'Reserved'
),

(
(select hotel_id from hotel where name='Royal Stay'),
(select room_type_id from room_type where type_name='Luxury'),
'505',
'Available'
);


insert into Customer
(first_name,last_name,phone,email,passport_number)
values
('Aruzhan','Bekova','87071111111','aruzhan@mail.com','KZ123456'),
('Dias','Nurgali','87072222222','dias@mail.com','KZ123457'),
('Amina','Sultan','87073333333','amina@mail.com','KZ123458'),
('Adil','Serikov','87074444444','adil@mail.com','KZ123459'),
('Madina','Ermek','87075555555','madina@mail.com','KZ123460');


insert into Booking
(customer_id,room_id,check_in_date,check_out_date,status)
values
(
(select customer_id from customer where email='aruzhan@mail.com'),
(select room_id from room where room_number='101'),
'2026-06-01',
'2026-06-05',
'Reserved'
),

(
(select customer_id from customer where email='dias@mail.com'),
(select room_id from room where room_number='202'),
'2026-06-10',
'2026-06-14',
'Completed'
),

(
(select customer_id from customer where email='amina@mail.com'),
(select room_id from room where room_number='303'),
'2026-07-02',
'2026-07-06',
'Cancelled'
),

(
(select customer_id from customer where email='adil@mail.com'),
(select room_id from room where room_number='404'),
'2026-07-12',
'2026-07-15',
'Reserved'
),

(
(select customer_id from customer where email='madina@mail.com'),
(select room_id from room where room_number='505'),
'2026-08-01',
'2026-08-06',
'Reserved'
);


insert into Guest
(booking_id,first_name,last_name,passport_number,date_of_birth)
values
(
(select booking_id
from booking b
join customer c
on b.customer_id=c.customer_id
where c.email='aruzhan@mail.com'),
'Ali','Bekov','G123451','2001-05-01'
),

(
(select booking_id
from booking b
join customer c
on b.customer_id=c.customer_id
where c.email='dias@mail.com'),
'Dana','Nurgali','G123452','1998-02-10'
),

(
(select booking_id
from booking b
join customer c
on b.customer_id=c.customer_id
where c.email='amina@mail.com'),
'Mira','Sultan','G123453','2000-03-20'
),

(
(select booking_id
from booking b
join customer c
on b.customer_id=c.customer_id
where c.email='adil@mail.com'),
'Askar','Serikov','G123454','1995-07-11'
),

(
(select booking_id
from booking b
join customer c
on b.customer_id=c.customer_id
where c.email='madina@mail.com'),
'Aisha','Ermek','G123455','2002-09-18'
);

insert into Payment
(booking_id,amount,payment_method)
values
(
(select booking_id
from booking b
join customer c
on b.customer_id=c.customer_id
where c.email='aruzhan@mail.com'),
48000,
'Card'
),

(
(select booking_id
from booking b
join customer c
on b.customer_id=c.customer_id
where c.email='dias@mail.com'),
72000,
'Cash'
),

(
(select booking_id
from booking b
join customer c
on b.customer_id=c.customer_id
where c.email='amina@mail.com'),
120000,
'Card'
),

(
(select booking_id
from booking b
join customer c
on b.customer_id=c.customer_id
where c.email='adil@mail.com'),
135000,
'Transfer'
),

(
(select booking_id
from booking b
join customer c
on b.customer_id=c.customer_id
where c.email='madina@mail.com'),
350000,
'Card'
);

insert into Staff
(hotel_id,first_name,last_name,position,phone)
values
(
(select hotel_id
from hotel
where name='Ritz Hotel'),
'Nurlan','Aman','Manager','87770111111'
),

(
(select hotel_id
from hotel
where name='Sky Hotel'),
'Aruzhan','Kaiyr','Receptionist','87770222222'
),

(
(select hotel_id
from hotel
where name='Grand Palace'),
'Timur','Aset','Cleaner','87770333333'
),

(
(select hotel_id
from hotel
where name='Elite Inn'),
'Marat','Nuris','Security','87770444444'
),

(
(select hotel_id
from hotel
where name='Royal Stay'),
'Aida','Samat','Receptionist','87770555555'
);

insert into Service
(service_name,price)
values
('Spa',10000),
('Breakfast',5000),
('Airport Transfer',15000),
('Laundry',4000),
('Gym',6000);

insert into Booking_service
(booking_id,service_id,quantity)
values
(
(select booking_id
from booking b
join customer c
on b.customer_id=c.customer_id
where c.email='aruzhan@mail.com'),

(select service_id
from service
where service_name='Spa'),

1
),

(
(select booking_id
from booking b
join customer c
on b.customer_id=c.customer_id
where c.email='dias@mail.com'),

(select service_id
from service
where service_name='Breakfast'),

2
),

(
(select booking_id
from booking b
join customer c
on b.customer_id=c.customer_id
where c.email='amina@mail.com'),

(select service_id
from service
where service_name='Airport Transfer'),

1
),

(
(select booking_id
from booking b
join customer c
on b.customer_id=c.customer_id
where c.email='adil@mail.com'),

(select service_id
from service
where service_name='Laundry'),

2
),

(
(select booking_id
from booking b
join customer c
on b.customer_id=c.customer_id
where c.email='madina@mail.com'),

(select service_id
from service
where service_name='Gym'),

1
);

set role db_admin_user;
select current_user;
select count(*)
from Customer;
insert into Customer
(first_name,last_name,phone,email,passport_number)
values
('Admin','User','87779999991','admin@test.kz','ADMIN001')
returning *;

update customer
set first_name=first_name;

delete from customer
where email='admin@test.kz';

reset role;

set role db_reader_user;
select current_user;

select count(*)
from customer;

begin;

insert into customer
(first_name,last_name,phone,email,passport_number)
values
('Reader','User','87779999992','reader@test.kz','READ001');

rollback;

-- SQL Error [42501]: ERROR: permission denied for table customer

begin;

update customer 
set first_name = first_name;
rollback;

-- SQL Error [42501]: ERROR: permission denied for table customer

begin;
delete from customer
where customer_id=1;

rollback;

--SQL Error [42501]: ERROR: permission denied for table customer

reset role;

select *
from customer
where email ='aruzhan@mail.com';
-- row count 1

update customer
set phone='87070000000'
where email='aruzhan@mail.com';



select *
from Booking
where status='Reserved';

-- row count = 3

update booking
set status='Completed'
where booking_id=
(
select booking_id
from booking b
join customer c
on b.customer_id=c.customer_id
where c.email='adil@mail.com'
);

select b.booking_id,
       b.status,
       p.amount
from booking b
join payment p
on b.booking_id=p.booking_id;
-- row count = 5

update booking b
set status='Completed'
from payment p
where b.booking_id=p.booking_id
and p.amount>100000;

begin;

delete from booking
where status='Cancelled';

select count(*)
from booking;

rollback;