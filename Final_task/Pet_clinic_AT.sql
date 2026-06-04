CREATE SCHEMA IF NOT EXISTS pet_clinic;

SET search_path TO pet_clinic;

--part 2 - create 

CREATE TABLE IF NOT EXISTS owners
(
    owner_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(25) NOT NULL,
    city VARCHAR(50),
    registration_date DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS veterinarians
(
    vet_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    specialization VARCHAR(100),
    email VARCHAR(100) NOT NULL UNIQUE,
    salary NUMERIC(10,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'Active',
    phone VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS pets
(
    pet_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    owner_id INT NOT NULL,
    pet_name VARCHAR(50) NOT NULL,
    species VARCHAR(50) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    birth_date DATE,
    weight NUMERIC(5,2),
    species_notes VARCHAR(255),

    CONSTRAINT fk_pet_owner
        FOREIGN KEY (owner_id)
        REFERENCES owners(owner_id)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS treatments
(
    treatment_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    treatment_name VARCHAR(100) NOT NULL UNIQUE,
    cost NUMERIC(10,2) NOT NULL,
    duration_minutes INT NOT NULL
);

CREATE TABLE IF NOT EXISTS appointments
(
    appointment_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    vet_id INT NOT NULL,
    pet_id INT NOT NULL,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    visit_reason VARCHAR(300),
    status VARCHAR(20) DEFAULT 'Scheduled',

    CONSTRAINT fk_appointment_vet
        FOREIGN KEY (vet_id)
        REFERENCES veterinarians(vet_id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_appointment_pet
        FOREIGN KEY (pet_id)
        REFERENCES pets(pet_id)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS appointment_treatments
(
    appointment_id INT NOT NULL,
    treatment_id INT NOT NULL,

    quantity INT DEFAULT 1,
    unit_price NUMERIC(10,2) NOT NULL,

    total_price NUMERIC(10,2)
        GENERATED ALWAYS AS (quantity * unit_price) STORED,

    PRIMARY KEY (appointment_id, treatment_id),

    CONSTRAINT fk_at_appointment
        FOREIGN KEY (appointment_id)
        REFERENCES appointments(appointment_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_at_treatment
        FOREIGN KEY (treatment_id)
        REFERENCES treatments(treatment_id)
        ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS payments
(
    payment_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    appointment_id INT NOT NULL UNIQUE,

    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    amount NUMERIC(10,2) NOT NULL,

    payment_method VARCHAR(20) NOT NULL,

    CONSTRAINT fk_payment_appointment
        FOREIGN KEY (appointment_id)
        REFERENCES appointments(appointment_id)
        ON DELETE CASCADE
);


DO $$
BEGIN

    IF EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'owners_registration_date_chk'
    ) THEN
        ALTER TABLE owners DROP CONSTRAINT owners_registration_date_chk;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'veterinarians_salary_chk'
    ) THEN
        ALTER TABLE veterinarians DROP CONSTRAINT veterinarians_salary_chk;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'veterinarians_status_chk'
    ) THEN
        ALTER TABLE veterinarians DROP CONSTRAINT veterinarians_status_chk;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'pets_gender_chk'
    ) THEN
        ALTER TABLE pets DROP CONSTRAINT pets_gender_chk;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'pets_weight_chk'
    ) THEN
        ALTER TABLE pets DROP CONSTRAINT pets_weight_chk;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'treatments_cost_chk'
    ) THEN
        ALTER TABLE treatments DROP CONSTRAINT treatments_cost_chk;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'treatments_duration_chk'
    ) THEN
        ALTER TABLE treatments DROP CONSTRAINT treatments_duration_chk;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'appointments_date_chk'
    ) THEN
        ALTER TABLE appointments DROP CONSTRAINT appointments_date_chk;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'appointments_status_chk'
    ) THEN
        ALTER TABLE appointments DROP CONSTRAINT appointments_status_chk;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'at_quantity_chk'
    ) THEN
        ALTER TABLE appointment_treatments DROP CONSTRAINT at_quantity_chk;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'at_unit_price_chk'
    ) THEN
        ALTER TABLE appointment_treatments DROP CONSTRAINT at_unit_price_chk;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'payments_amount_chk'
    ) THEN
        ALTER TABLE payments DROP CONSTRAINT payments_amount_chk;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'payments_method_chk'
    ) THEN
        ALTER TABLE payments DROP CONSTRAINT payments_method_chk;
    END IF;

END $$;

-- part 3 - alter 
DO $$
BEGIN

    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'owners_registration_date_chk'
    ) THEN
        ALTER TABLE owners
        ADD CONSTRAINT owners_registration_date_chk
        CHECK (registration_date > DATE '2026-01-01');
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'veterinarians_salary_chk'
    ) THEN
        ALTER TABLE veterinarians
        ADD CONSTRAINT veterinarians_salary_chk
        CHECK (salary > 0);
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'veterinarians_status_chk'
    ) THEN
        ALTER TABLE veterinarians
        ADD CONSTRAINT veterinarians_status_chk
        CHECK (status IN ('Active','Inactive'));
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'pets_gender_chk'
    ) THEN
        ALTER TABLE pets
        ADD CONSTRAINT pets_gender_chk
        CHECK (gender IN ('Male','Female'));
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'pets_weight_chk'
    ) THEN
        ALTER TABLE pets
        ADD CONSTRAINT pets_weight_chk
        CHECK (weight > 0);
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'treatments_cost_chk'
    ) THEN
        ALTER TABLE treatments
        ADD CONSTRAINT treatments_cost_chk
        CHECK (cost >= 0);
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'treatments_duration_chk'
    ) THEN
        ALTER TABLE treatments
        ADD CONSTRAINT treatments_duration_chk
        CHECK (duration_minutes > 0);
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'appointments_date_chk'
    ) THEN
        ALTER TABLE appointments
        ADD CONSTRAINT appointments_date_chk
        CHECK (appointment_date > DATE '2026-01-01');
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'appointments_status_chk'
    ) THEN
        ALTER TABLE appointments
        ADD CONSTRAINT appointments_status_chk
        CHECK (status IN ('Scheduled','Completed','Cancelled'));
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'at_quantity_chk'
    ) THEN
        ALTER TABLE appointment_treatments
        ADD CONSTRAINT at_quantity_chk
        CHECK (quantity > 0);
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'at_unit_price_chk'
    ) THEN
        ALTER TABLE appointment_treatments
        ADD CONSTRAINT at_unit_price_chk
        CHECK (unit_price >= 0);
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'payments_amount_chk'
    ) THEN
        ALTER TABLE payments
        ADD CONSTRAINT payments_amount_chk
        CHECK (amount > 0);
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'payments_method_chk'
    ) THEN
        ALTER TABLE payments
        ADD CONSTRAINT payments_method_chk
        CHECK (payment_method IN ('Cash','Card','Transfer'));
    END IF;

END $$;

-- part 4 - insert

truncate table payments restart identity cascade;
truncate table appointment_treatments restart identity cascade;
truncate table appointments restart identity cascade;
truncate table treatments restart identity cascade;
truncate table pets restart identity cascade;
truncate table veterinarians restart identity cascade;
truncate table owners restart identity cascade;

INSERT INTO owners
(first_name,last_name,email,phone,city,registration_date)
SELECT *
FROM (
VALUES
('Aruzhan','Tulegenova','aruka.tul@email.com','77789005678','Atyrau','2026-02-02'::date),
('Asylai','Zhumakulova','asylaikakaka@email.com','7785678456','Atyrau','2026-02-03'::date),
('Aiken','Amanbai','ICan@email.com','7785643234','Almaty','2026-02-05'::date),
('Inabat','Kairakbai','k.inabat@email.com','7757864345','Astana','2026-02-06'::date),
('Diana','Chigrina','d.chigrina@email.com','7761234908','Karaganda','2026-02-08'::date),
('Assel','Balgabai','b.assel@email.com','7789067345','Taraz','2026-02-10'::date),
('Aruzhan','Khismetova','k.aru@email.com','7753423123','Aktobe','2026-02-12'::date),
('Raikhan','Sahtasheva','s.raikhan@email.com','7753423678','Atyrau','2026-02-14'::date),
('Asylai','Amirzhankyzy','a.asylai@email.com','7765634564','Kostanay','2026-02-16'::date),
('Moldir','Olzhabaeva','m.olzhabaeva@email.com','7796574324','Pavlodar','2026-02-18'::date)
) v(first_name,last_name,email,phone,city,registration_date)
WHERE NOT EXISTS (
    SELECT 1
    FROM owners o
    WHERE o.email = v.email
);

INSERT INTO veterinarians
(first_name,last_name,specialization,email,salary,status,phone)
SELECT *
FROM (
VALUES
('Rufina','Tulegenova','Surgery','rufi@vet.kz',650000,'Active','7767676767'),
('Dias','Ermekov','Oncology','dias@vet.kz',600000,'Active','7764523079'),
('Aigerim','Shpanova','Dermatology','aigerim@vet.kz',580000,'Active','7751005127'),
('Nurdaulet','Zhumabay','Ornithology','nurdaulet@vet.kz',550000,'Active','7754556890'),
('Aisha','Shumagaly','Intensive Care','aisha@vet.kz',700000,'Inactive','7765634874')
) v(first_name,last_name,specialization,email,salary,status,phone)
WHERE NOT EXISTS (
    SELECT 1
    FROM veterinarians vt
    WHERE vt.email = v.email
);

INSERT INTO treatments
(treatment_name,cost,duration_minutes)
SELECT *
FROM (
VALUES
('Vaccination',12000,15),
('Dental Cleaning',35000,60),
('Surgery',150000,180),
('Health Check',10000,20),
('X-Ray',25000,30)
) v(treatment_name,cost,duration_minutes)
WHERE NOT EXISTS (
    SELECT 1
    FROM treatments t
    WHERE t.treatment_name = v.treatment_name
);


INSERT INTO pets
(owner_id,pet_name,species,gender,birth_date,weight)
SELECT
    o.owner_id,
    v.pet_name,
    v.species,
    v.gender,
    v.birth_date,
    v.weight
FROM (
VALUES
('aruka.tul@email.com','Bax','Dog','Male','2023-05-10'::date,15.50),
('asylaikakaka@email.com','Poti','Cat','Female','2022-09-12'::date,4.20),
('ICan@email.com','Aktus','Dog','Male','2021-11-01'::date,20.00),
('k.inabat@email.com','Mio','Cat','Female','2023-03-20'::date,3.80),
('d.chigrina@email.com','Abylai','Dog','Male','2022-07-07'::date,18.30),
('b.assel@email.com','Niko','Rabbit','Female','2024-01-10'::date,2.10),
('k.aru@email.com','James','Dog','Male','2023-08-15'::date,11.50),
('s.raikhan@email.com','Simba','Cat','Male','2022-12-01'::date,5.20),
('a.asylai@email.com','Ai','Dog','Female','2021-06-22'::date,22.70),
('m.olzhabaeva@email.com','Poco','Parrot','Female','2024-04-01'::date,0.90)
) v(owner_email,pet_name,species,gender,birth_date,weight)
JOIN owners o
    ON o.email = v.owner_email
WHERE NOT EXISTS (
    SELECT 1
    FROM pets p
    WHERE p.pet_name = v.pet_name
      AND p.owner_id = o.owner_id
);


INSERT INTO appointments
(vet_id, pet_id, appointment_date, appointment_time, visit_reason, status)
SELECT
    vt.vet_id,
    p.pet_id,
    v.appointment_date,
    v.appointment_time,
    v.visit_reason,
    v.status
FROM (
VALUES
('rufi@vet.kz','Bax','2026-03-01'::date,'10:00'::time,'Vaccination','Scheduled'),
('dias@vet.kz','Poti','2026-03-02'::date,'11:00'::time,'Dental check','Scheduled'),
('aigerim@vet.kz','Aktus','2026-03-03'::date,'12:00'::time,'Skin infection','Completed'),
('nurdaulet@vet.kz','Mio','2026-03-04'::date,'13:00'::time,'Routine exam','Scheduled'),
('rufi@vet.kz','Abylai','2026-03-05'::date,'09:30'::time,'Surgery consultation','Scheduled'),
('dias@vet.kz','Niko','2026-03-06'::date,'10:30'::time,'Dental cleaning','Completed'),
('aigerim@vet.kz','James','2026-03-07'::date,'11:30'::time,'Vaccination','Scheduled'),
('nurdaulet@vet.kz','Simba','2026-03-08'::date,'14:00'::time,'Health check','Cancelled'),
('rufi@vet.kz','Ai','2026-03-09'::date,'15:00'::time,'X-Ray','Completed'),
('dias@vet.kz','Poco','2026-03-10'::date,'16:00'::time,'General check','Scheduled')
) v(vet_email,pet_name,appointment_date,appointment_time,visit_reason,status)
JOIN veterinarians vt
    ON vt.email = v.vet_email
JOIN pets p
    ON p.pet_name = v.pet_name
WHERE NOT EXISTS (
    SELECT 1
    FROM appointments a
    WHERE a.pet_id = p.pet_id
      AND a.appointment_date = v.appointment_date
      AND a.appointment_time = v.appointment_time
);


INSERT INTO appointment_treatments
(appointment_id, treatment_id, quantity, unit_price)
SELECT
    a.appointment_id,
    t.treatment_id,
    v.quantity,
    v.unit_price
FROM (
VALUES
('Bax','Vaccination','Vaccination',1,12000),
('Poti','Dental check','Dental Cleaning',1,35000),
('Aktus','Skin infection','Health Check',1,10000),
('Mio','Routine exam','Health Check',1,10000),
('Ai','X-Ray','X-Ray',1,25000)
) v(pet_name,visit_reason,treatment_name,quantity,unit_price)
JOIN pets p
    ON p.pet_name = v.pet_name
JOIN appointments a
    ON a.pet_id = p.pet_id
   AND a.visit_reason = v.visit_reason
JOIN treatments t
    ON t.treatment_name = v.treatment_name
WHERE NOT EXISTS (
    SELECT 1
    FROM appointment_treatments at
    WHERE at.appointment_id = a.appointment_id
      AND at.treatment_id = t.treatment_id
);


INSERT INTO payments
(appointment_id, amount, payment_method)
SELECT
    a.appointment_id,
    v.amount,
    v.payment_method
FROM (
VALUES
('Bax','Vaccination',12000,'Card'),
('Poti','Dental check',35000,'Cash'),
('Aktus','Skin infection',10000,'Card'),
('Mio','Routine exam',10000,'Transfer'),
('Ai','X-Ray',25000,'Cash')
) v(pet_name,visit_reason,amount,payment_method)
JOIN pets p
    ON p.pet_name = v.pet_name
JOIN appointments a
    ON a.pet_id = p.pet_id
   AND a.visit_reason = v.visit_reason
WHERE NOT EXISTS (
    SELECT 1
    FROM payments py
    WHERE py.appointment_id = a.appointment_id
);

-- part 5 - update

UPDATE appointments
SET status = 'Completed'
WHERE visit_reason IN ('Vaccination','Dental check','X-Ray');

UPDATE payments p
SET amount =
(
    SELECT COALESCE(SUM(at.quantity * at.unit_price),0)
    FROM appointment_treatments at
    WHERE at.appointment_id = p.appointment_id
);
-- remove cancelled appointments for cleanup (reault= appointment_id = 8)
-- appointment_id - 8

BEGIN;

DELETE FROM appointments
WHERE status = 'Cancelled'
RETURNING appointment_id;

ROLLBACK;

-- part 6 GRANT + REVOKE 
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_roles
        WHERE rolname = 'pet_clinic_readonly'
    ) THEN
        CREATE ROLE pet_clinic_readonly;
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_roles
        WHERE rolname = 'pet_clinic_writer'
    ) THEN
        CREATE ROLE pet_clinic_writer;
    END IF;
END $$;


GRANT USAGE ON SCHEMA pet_clinic
TO pet_clinic_readonly;

GRANT SELECT ON ALL TABLES IN SCHEMA pet_clinic
TO pet_clinic_readonly;

GRANT USAGE ON SCHEMA pet_clinic
TO pet_clinic_writer;

GRANT INSERT ON appointments
TO pet_clinic_writer;

-- writers may create appointment but cannot modify ones after removal

REVOKE UPDATE ON appointments
FROM pet_clinic_writer;
