PET CLINIC DATABASE

This project implements a database for a veterinary clinic. The system stores information about pet owners, pets, veterinarians, appointments, treatments, and payments. The database allows the clinic to manage visits, record medical procedures performed during appointments, and track payments.
Database Information

Database name: pet_clinic_db
Schema name: pet_clinic

What included in database:
Tables
owners
pets
veterinarians
appointments
treatments
appointment_treatments
payments

Relationships
One owner can own many pets.
One pet can have many appointments.
One veterinarian can conduct many appointments.
One appointment can have one payment.
Appointments and treatments have a many-to-many relationship resolved through the appointment_treatments junction table.

Run Instructions
Create and connect to the PostgreSQL database pet_clinic_db.
Run the script 02_final.sql.
The script automatically drops existing objects, recreates the schema, creates tables, applies constraints, inserts sample data, performs ALTER operations, executes UPDATE and DELETE examples, and configures roles and permissions.

Notes
All foreign key values in INSERT statements are resolved using subqueries.
The database is designed in Third Normal Form (3NF).
The appointment_treatments table resolves the many-to-many relationship between appointments and treatments.
