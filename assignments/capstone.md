Below is a comprehensive attempt to address all phases of the capstone project using the 
Smart Bus Booking System for Rwanda as the chosen project.

---

# Capstone Project Report: Smart Bus Booking System for Rwanda

This report outlines the complete development process for an Oracle PL/SQL database solution, 
following the three-phase structure as defined by the course requirements.

---

## Phase I: Problem Statement and Presentation

### 1. Problem Definition
- **Issue to Solve:**  
  The current manual ticketing system in Rwanda leads to terminal congestion and long waiting times.
   A digital solution is needed to automate ticket reservations, streamline bus scheduling,
    and improve overall service delivery.
  
- **Context of Use:**  
  The system will be deployed at bus terminals and accessed via mobile devices, transforming 
  the traditional ticketing process into a seamless digital experience.

- **Target Users:**  
  - **Passengers:** Individuals booking bus tickets for intercity travel.  
  - **Bus Operators:** Companies and staff managing fleet operations and terminal activities.

- **Project Goals:**  
  - Automate the booking process to reduce congestion at terminals.  
  - Provide real-time schedule and seat availability.  
  - Enable digital payments and booking confirmations.  
  - Equip operators with analytics and management tools to optimize schedules and resource allocation.

### 2. Presentation Requirements
- **Format:** PowerPoint presentation (up to 3 slides) with Helvetica font and bullet points.
- **Slide Outlines:**
  - **Slide 1:** *Smart Bus Booking System for Rwanda*  
    - Brief introduction of the problem, context, and project objective.
  - **Slide 2:** *Key Database Entities*  
    - List and brief description of entities: Users, Bus Terminals, Buses, Bookings, Routes & Schedules.
  - **Slide 3:** *Benefits and Impact*  
    - Highlights of reduced waiting times, improved customer experience, operational efficiency,
     and data-driven decision-making.

*This phase aligns with the guidelines provided in the AUCA capstone instructions for problem
 statement and presentation. citeturn1file0*

---

## Phase II: Business Process Modeling (BPM)

### 1. Define the Business Process
- **Process to Model:**  
  The end-to-end ticket booking process at a bus terminal from a user’s perspective through 
  to the operator’s management system.
  
- **Objectives & Expected Outcomes:**
  - Seamless online booking with real-time feedback.
  - Reduction in physical ticketing and terminal crowding.
  - Improved management of bus schedules and capacities.

### 2. Key Entities & Actors
- **Users (Passengers):**  
  Initiate booking requests via a mobile application.
- **Bus Operators/Terminal Staff:**  
  Oversee scheduling, manage capacities, and confirm bookings.
- **System (Digital Booking Platform):**  
  Processes transactions, updates booking records, and manages real-time data.
- **Payment Gateway:**  
  Handles digital payments and transaction verifications.

### 3. BPM Diagram Outline with Swimlanes
- **Swimlanes to Include:**  
  - **Passenger:** Starts the booking process, selects route, and makes payment.
  - **System:** Validates booking, checks seat availability, sends confirmation.
  - **Bus Operator:** Reviews and manages schedule, updates bus capacities.
  - **Payment Gateway:** Processes the transaction and confirms payment.

### 4. Diagram Description (One-Page Explanation)
- **Flow Summary:**  
  1. **Initiation:** Passenger logs into the mobile app and selects desired route and schedule.
  2. **Validation:** The system checks for seat availability and validates the booking.
  3. **Payment:** Passenger completes payment via the integrated payment gateway.
  4. **Confirmation:** On successful payment, the system confirms the booking and sends a notification.
  5. **Operator Interaction:** Bus operators review daily schedules and 
  update any changes to capacity or timing.
  
- **MIS Benefits:**  
  The BPM improves decision-making by providing real-time data on booking patterns
   and peak travel times. It also streamlines operations, reducing manual errors and 
   enhancing customer satisfaction.

*For diagram creation, tools like Lucidchart or draw.io are recommended. citeturn1file0*

---

## Phase III: Logical Model Design

### 1. Entity-Relationship (ER) Model

#### Key Entities and Attributes

1. **Users**
   - *Attributes:*  
     - User_ID (PK)  
     - First_Name  
     - Last_Name  
     - Email  
     - Phone_Number  
     - Travel_History (optional, as a separate table if needed)  
     - Payment_Details (encrypted/linked to payment service)
  
2. **Bus Terminals**
   - *Attributes:*  
     - Terminal_ID (PK)  
     - Location  
     - Operating_Hours  
     - Contact_Info

3. **Buses**
   - *Attributes:*  
     - Bus_ID (PK)  
     - Terminal_ID (FK)  
     - Seating_Capacity  
     - Service_Route  
     - Bus_Type

4. **Bookings**
   - *Attributes:*  
     - Booking_ID (PK)  
     - User_ID (FK)  
     - Bus_ID (FK)  
     - Route_ID (FK)  
     - Booking_Date  
     - Seat_Number  
     - Payment_Status

5. **Routes & Schedules**
   - *Attributes:*  
     - Route_ID (PK)  
     - Origin  
     - Destination  
     - Departure_Time  
     - Arrival_Time  
     - Frequency (e.g., daily, weekly)

### 2. Relationships & Constraints
- **Relationships:**
  - **Users–Bookings:** One-to-many (a user can have multiple bookings).
  - **Buses–Bookings:** One-to-many (a bus can have many bookings for a given schedule).
  - **Bus Terminals–Buses:** One-to-many (each terminal can manage multiple buses).
  - **Routes & Schedules–Bookings:** One-to-many (each route schedule is linked to several bookings).
  
- **Constraints:**
  - **Primary Keys (PKs):** Ensure entity uniqueness.
  - **Foreign Keys (FKs):** Enforce referential integrity between Users, Buses, Bus Terminals, 
  and Routes.
  - **Other Constraints:**  
    - NOT NULL on critical fields (e.g., User_ID, Booking_Date).  
    - UNIQUE constraint on attributes like Email in the Users entity.  
    - CHECK constraints for fields such as Payment_Status (e.g., values: 'Paid', 'Pending').

### 3. Normalization
- **Normalization:**  
  The design adheres to at least the Third Normal Form (3NF) to eliminate data redundancy. 
  Each entity contains attributes that are functionally dependent only on the primary key, 
  ensuring efficient storage and data integrity.

### 4. Handling Data Scenarios
- The model can handle scenarios such as:
  - Overbooking prevention by checking seat availability before confirming transactions.
  - Real-time schedule adjustments if a bus is delayed or overcapacity.
  - Dynamic updates to user travel history and booking status.

*This logical model is designed to meet the business requirements and technical guidelines
 outlined in the capstone project document. citeturn1file0*

---

## Final Notes

- **Repository & Version Control:**  
  The final report, along with all diagrams and SQL scripts, should be submitted via a 
  private GitHub repository. The repository name should follow the format:  
  `Grp_StudentID_ProjectName`  
  and must include regular updates and progress commits.

- **Quality and Creativity:**  
  Emphasis is placed on originality, clear documentation, and technical accuracy.
   The use of proper tools for diagram creation (e.g., Lucidchart or draw.io) and
    consistent file naming conventions is essential.

- **Time Management:**  
  Ensure strict adherence to deadlines as late submissions are not accepted.

This complete approach outlines every phase of the project—from identifying the problem and modeling the business process to designing the logical data model—thus fulfilling all requirements of the capstone project for Database Development with PL/SQL. 

Good luck with your project!

---