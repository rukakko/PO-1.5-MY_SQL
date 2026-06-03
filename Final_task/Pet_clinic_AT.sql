create schema if not exists pet_clinic;

set search_path to pet_clinic;


drop table if exists payments cascade;
drop table if exists appointment_treatments cascade;
drop table if exists appointments cascade;
drop table if exists treatments cascade;
drop table if exists pets cascade;
drop table if exists veterinarians cascade;
drop table if exists owners cascade;



create table if not exists owners
(
    owner_id int generated always as identity primary key,
    first_name varchar(50) not null,
    last_name varchar(50) not null,
    email varchar(100) not null unique,
    phone varchar(20) not null,
    city varchar(50),
    registration_date date not null
        check (registration_date > date '2026-01-01')
);



create table if not exists veterinarians
(
    vet_id int generated always as identity primary key,
    first_name varchar(50) not null,
    last_name varchar(50) not null,
    specialization varchar(100),
    email varchar(100) not null unique,
    salary numeric(10,2) not null
        check (salary > 0),
    status varchar(20) default 'Active'
        check (status in ('Active','Inactive'))
);



create table if not exists pets
(
    pet_id int generated always as identity primary key,

    owner_id int not null,

    pet_name varchar(50) not null,

    species varchar(50) not null,

    gender varchar(10) not null
        check (gender in ('Male','Female')),

    birth_date date,

    weight numeric(5,2)
        check (weight > 0),

    constraint fk_pet_owner
        foreign key (owner_id)
        references owners(owner_id)
        on delete cascade
);



create table if not exists treatments
(
    treatment_id int generated always as identity primary key,

    treatment_name varchar(100) not null unique,

    cost numeric(10,2) not null
        check (cost >= 0),

    duration_minutes int not null
        check (duration_minutes > 0)
);



create table if not exists appointments
(
    appointment_id int generated always as identity primary key,

    vet_id int not null,

    pet_id int not null,

    appointment_date date not null
        check (appointment_date > date '2026-01-01'),

    appointment_time time not null,

    reason varchar(300),

    status varchar(20) default 'Scheduled'
        check (status in ('Scheduled','Completed','Cancelled')),

    constraint fk_appointment_vet
        foreign key (vet_id)
        references veterinarians(vet_id)
        on delete restrict,

    constraint fk_appointment_pet
        foreign key (pet_id)
        references pets(pet_id)
        on delete cascade
);



create table if not exists appointment_treatments
(
    appointment_id int not null,

    treatment_id int not null,

    quantity int default 1
        check (quantity > 0),

    unit_price numeric(10,2) not null
        check (unit_price >= 0),

    total_price numeric(10,2)
        generated always as (quantity * unit_price) stored,

    primary key (appointment_id, treatment_id),

    constraint fk_at_appointment
        foreign key (appointment_id)
        references appointments(appointment_id)
        on delete cascade,

    constraint fk_at_treatment
        foreign key (treatment_id)
        references treatments(treatment_id)
        on delete restrict
);



create table if not exists payments
(
    payment_id int generated always as identity primary key,

    appointment_id int not null unique,

    payment_date timestamp default current_timestamp,

    amount numeric(10,2) not null
        check (amount > 0),

    payment_method varchar(20) not null
        check (payment_method in ('Cash','Card','Transfer')),

    constraint fk_payment_appointment
        foreign key (appointment_id)
        references appointments(appointment_id)
        on delete cascade
);


-- Part 3: ALTER TABLE

-- international phone numbers may be longer
alter table owners
alter column phone type varchar(25);

-- track veterinarian phone numbers
alter table veterinarians
add column phone varchar(20);

-- clearer reporting column name
alter table appointments
rename column reason to visit_reason;

-- new appointments should default to scheduled
alter table appointments
alter column status set default 'Scheduled';

-- clinic stores additional medical notes about pets
alter table pets
add column species_notes varchar(255);

truncate table payments restart identity cascade;
truncate table appointment_treatments restart identity cascade;
truncate table appointments restart identity cascade;
truncate table treatments restart identity cascade;
truncate table pets restart identity cascade;
truncate table veterinarians restart identity cascade;
truncate table owners restart identity cascade;

insert into owners
(first_name,last_name,email,phone,city,registration_date)
values
('Aruzhan','Tulegenova','aruka.tul@email.com','77789005678','Atyrau','2026-02-02'),
('Asylai','Zhumakulova','asylaikakaka@email.com','7785678456','Atyrau','2026-02-03'),
('Aiken','Amanbai','ICan@email.com','7785643234','Almaty','2026-02-05'),
('Inabat','Kairakbai','k.inabat@email.com','7757864345','Astana','2026-02-06'),
('Diana','Chigrina','d.chigrina@email.com','7761234908','Karaganda','2026-02-08'),
('Assel','Balgabai','b.assel@email.com','7789067345','Taraz','2026-02-10'),
('Aruzhan','Khismetova','k.aru@email.com','7753423123','Aktobe','2026-02-12'),
('Raikhan','Sahtasheva','s.raikhan@email.com','7753423678','Atyrau','2026-02-14'),
('Asylai','Amirzhankyzy','a.asylai@email.com','7765634564','Kostanay','2026-02-16'),
('Moldir','Olzhabaeva','m.olzhabaeva@email.com','7796574324','Pavlodar','2026-02-18');

insert into veterinarians
(first_name,last_name,specialization,email,salary,status,phone)
values
('Rufina','Tulegenova','Surgery','rufi@vet.kz',650000,'Active','7767676767'),
('Dias','Ermekov','Oncology','dias@vet.kz',600000,'Active','7764523079'),
('Aigerim','Shpanova','Dermatology','aigerim@vet.kz',580000,'Active','7751005127'),
('Nurdaulet','Zhumabay','Ornithology','nurdaulet@vet.kz',550000,'Active','7754556890'),
('Aisha','Shumagaly','Intensive Care','aisha@vet.kz',700000,'Inactive','7765634874');


insert into treatments
(treatment_name,cost,duration_minutes)
values
('Vaccination',12000,15),
('Dental Cleaning',35000,60),
('Surgery',150000,180),
('Health Check',10000,20),
('X-Ray',25000,30);

insert into pets
(owner_id,pet_name,species,gender,birth_date,weight)
values
(
 (select owner_id from owners where email='aruka.tul@email.com'),
 'Bax','Dog','Male','2023-05-10',15.50
),
(
 (select owner_id from owners where email='asylaikakaka@email.com'),
 'Poti','Cat','Female','2022-09-12',4.20
),
(
 (select owner_id from owners where email='ICan@email.com'),
 'Aktus','Dog','Male','2021-11-01',20.00
),
(
 (select owner_id from owners where email='k.inabat@email.com'),
 'Mio','Cat','Female','2023-03-20',3.80
),
(
 (select owner_id from owners where email='d.chigrina@email.com'),
 'Abylai','Dog','Male','2022-07-07',18.30
),
(
 (select owner_id from owners where email='b.assel@email.com'),
 'Niko','Rabbit','Female','2024-01-10',2.10
),
(
 (select owner_id from owners where email='k.aru@email.com'),
 'James','Dog','Male','2023-08-15',11.50
),
(
 (select owner_id from owners where email='s.raikhan@email.com'),
 'Simba','Cat','Male','2022-12-01',5.20
),
(
 (select owner_id from owners where email='a.asylai@email.com'),
 'Ai','Dog','Female','2021-06-22',22.70
),
(
 (select owner_id from owners where email='m.olzhabaeva@email.com'),
 'Poco','Parrot','Female','2024-04-01',0.90
);

insert into appointments
(vet_id, pet_id, appointment_date, appointment_time, visit_reason, status)
values
(
 (select vet_id from veterinarians where email='rufi@vet.kz'),
 (select pet_id from pets where pet_name='Bax'),
 '2026-03-01','10:00','Vaccination','Scheduled'
),
(
 (select vet_id from veterinarians where email='dias@vet.kz'),
 (select pet_id from pets where pet_name='Poti'),
 '2026-03-02','11:00','Dental check','Scheduled'
),
(
 (select vet_id from veterinarians where email='aigerim@vet.kz'),
 (select pet_id from pets where pet_name='Aktus'),
 '2026-03-03','12:00','Skin infection','Completed'
),
(
 (select vet_id from veterinarians where email='nurdaulet@vet.kz'),
 (select pet_id from pets where pet_name='Mio'),
 '2026-03-04','13:00','Routine exam','Scheduled'
),
(
 (select vet_id from veterinarians where email='rufi@vet.kz'),
 (select pet_id from pets where pet_name='Abylai'),
 '2026-03-05','09:30','Surgery consultation','Scheduled'
),
(
 (select vet_id from veterinarians where email='dias@vet.kz'),
 (select pet_id from pets where pet_name='Niko'),
 '2026-03-06','10:30','Dental cleaning','Completed'
),
(
 (select vet_id from veterinarians where email='aigerim@vet.kz'),
 (select pet_id from pets where pet_name='James'),
 '2026-03-07','11:30','Vaccination','Scheduled'
),
(
 (select vet_id from veterinarians where email='nurdaulet@vet.kz'),
 (select pet_id from pets where pet_name='Simba'),
 '2026-03-08','14:00','Health check','Cancelled'
),
(
 (select vet_id from veterinarians where email='rufi@vet.kz'),
 (select pet_id from pets where pet_name='Ai'),
 '2026-03-09','15:00','X-Ray','Completed'
),
(
 (select vet_id from veterinarians where email='dias@vet.kz'),
 (select pet_id from pets where pet_name='Poco'),
 '2026-03-10','16:00','General check','Scheduled'
);

insert into appointment_treatments
(appointment_id, treatment_id, quantity, unit_price)
values
(
 (select appointment_id from appointments where visit_reason='Vaccination' and pet_id =
     (select pet_id from pets where pet_name='Bax')),
 (select treatment_id from treatments where treatment_name='Vaccination'),
 1, 12000
),
(
 (select appointment_id from appointments where visit_reason='Dental check' and pet_id =
     (select pet_id from pets where pet_name='Poti')),
 (select treatment_id from treatments where treatment_name='Dental Cleaning'),
 1, 35000
),
(
 (select appointment_id from appointments where visit_reason='Skin infection'),
 (select treatment_id from treatments where treatment_name='Health Check'),
 1, 10000
),
(
 (select appointment_id from appointments where visit_reason='Routine exam'),
 (select treatment_id from treatments where treatment_name='Health Check'),
 1, 10000
),
(
 (select appointment_id from appointments where visit_reason='X-Ray'),
 (select treatment_id from treatments where treatment_name='X-Ray'),
 1, 25000
);

insert into payments
(appointment_id, amount, payment_method)
select
    a.appointment_id,
    x.amount,
    x.method
from (
    values
    ('Bax','Vaccination',12000,'Card'),
    ('Poti','Dental check',35000,'Cash'),
    ('Aktus','Skin infection',10000,'Card'),
    ('Mio','Routine exam',10000,'Transfer'),
    ('Simba','X-Ray',25000,'Cash')
) as x(pet_name, reason, amount, method)

join pets p on p.pet_name = x.pet_name
join appointments a
    on a.pet_id = p.pet_id
   and a.visit_reason = x.reason;

-- update 
update appointments
set status = 'Completed'
where visit_reason in ('Vaccination','Dental check','X-Ray');


-- update payment amounts based on treatment totals
update payments p
set amount =
(
    select sum(at.unit_price * at.quantity)
    from appointment_treatments at
    where at.appointment_id = p.appointment_id
);

-- remove cancelled appointments for cleanup (reault= appointment_id = 8)
begin;

delete from appointments
where status = 'Cancelled'
returning appointment_id;

rollback;

-- grant / revoke
drop role if exists pet_clinic_readonly;
drop role if exists pet_clinic_writer;

create role pet_clinic_readonly;
create role pet_clinic_writer;

grant select on all tables in schema pet_clinic
to pet_clinic_readonly;

grant insert, update on appointments
to pet_clinic_writer;

-- writers may create appointment but cannot modify ones after removal
revoke update on appointments from pet_clinic_writer;

