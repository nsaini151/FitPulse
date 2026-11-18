\# FitPulse: Dual-Architecture Gym Management \& Fitness Analytics Platform



FitPulse is an integrated data management and analytics project built to handle both structured operational data and high-velocity IoT fitness tracker metrics. The platform uses a hybrid architecture combining a relational MySQL backend for core business operations with a document-oriented MongoDB store for continuous workout logs.



\## Repository Structure



```text

FitPulse/

├── data/         # Raw source CSV files (members, plans, attendance, bookings, classes, etc.)

├── sql/          # Relational scripts (schema creation, mock data insertion, and analytical queries)

└── nosql/        # Document workflows (Jupyter notebooks for synthetic log generation and pipeline execution)

**Architecture Overview**


1\. Relational Core (MySQL)

* Design: Normalized to 3NF to ensure data integrity across members, memberships, class schedules, and facility rooms.



* Scale: Populated with over 47,000 operational records, including attendance check-ins and member bookings.



* Key Capabilities: Enforces business logic through custom constraints, automated triggers, and scheduled events, alongside optimized analytical queries tracking peak hours, class fill rates, and membership retention.



2\. Document Core (MongoDB)

* Design: Document-oriented schema designed to capture unstructured, high-frequency biometric streams (heart rate time-series, step counts, and GPS logs).



* Scale: Houses over 24,000 granular workout logs mapped across active tracker profiles.



* Key Capabilities: Implements flexible validation schemas, compound indexes for rapid timeline queries, and heavy aggregation pipelines linking daily workout volume and active minutes directly to membership churn and renewal patterns.



Getting Started


**Running the SQL Component**


1. Open MySQL Workbench and connect to your local server.

2. Run sql/schema.sql to initialize the database structure and constraints.

3. Run sql/data.sql to populate the tables.

4. Execute sql/queries.sql to review analytical views, triggers, and business metrics.



**Running the NoSQL Component**


1. Ensure a local MongoDB instance is running.



2\. Open the Jupyter Notebooks located in the nosql/ directory.



3\. Run the data generation and loading cells to populate the local document collections, then execute the aggregation scripts to test the time-series pipelines.

