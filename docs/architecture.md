# RoomOps — Technical Architecture

## 1. Overview

RoomOps is a web platform for managing the daily operations of escape-room businesses.

The system centralizes room management, customers, reservations, payments, expenses, and operational reporting.

The architecture separates the user interfaces, business logic, and data persistence to improve maintainability, testability, and future extensibility.

## 2. Technology Stack

### Frontend
- **React** — UI library for building the web interfaces.
- **TypeScript** — Adds static typing to JavaScript.

### Backend
- **Java 21** — Backend programming language and runtime.
- **Spring Boot** — Framework for building the backend application and REST API.

### Database
- **PostgreSQL** — Relational database for persistent application data.

### Development and Version Control
- **Git** — Version control.
- **GitHub** — Remote repository and collaboration platform.
- **Docker** — Reproducible development environment and service execution.

## 3. High-Level Architecture

RoomOps follows a client-server architecture.

The main components are:

1. **Public Booking Website:** A customer-facing interface where customers can view rooms, availability, and make reservations.
2. **Internal Management Panel:** An interface used by administrators and operators to manage daily business operations.
3. **Backend API:** A Spring Boot application that exposes endpoints, applies business rules, validates operations, and controls access.
4. **PostgreSQL Database:** Stores application data and enforces relational integrity.

Both interfaces can communicate with the same backend API. They do not access the database directly.

## 4. Responsibilities

### Frontend
- Render the user interfaces.
- Collect and validate user input for usability.
- Display data received from the backend.
- Send requests to the backend API.

The backend remains responsible for enforcing business rules and security.

### Backend
- Authenticate users and authorize actions according to their roles.
- Manage rooms, customers, reservations, payments, and expenses.
- Enforce business rules and validate operations.
- Expose REST API endpoints.
- Coordinate database operations.

### Database
- Persist application data.
- Enforce primary keys, foreign keys, uniqueness, and other applicable constraints.
- Maintain relationships between entities.

## 5. Architectural Principles

- Separate presentation, business logic, and persistence.
- Keep business rules in the backend rather than relying on frontend validation.
- Use a relational data model with explicit constraints.
- Store monetary values using appropriate decimal types, not floating-point types.
- Preserve reservation history, including the agreed price at the time of booking.
- Keep the system independent of any specific escape-room business.
- Prefer a modular, maintainable design over unnecessary complexity.

## 6. Initial Scope

The first version will include:

- Authentication and role-based access.
- Room and pricing management.
- Customer management.
- Reservation management.
- Payment registration.
- Expense registration.
- Dashboard and operational reservation grid.

Real payment processing, electronic invoicing, WhatsApp integration, and external booking-platform integrations are outside the initial scope.

## 7. Development Approach

Development will proceed incrementally:

1. Requirements and conceptual data modeling.
2. Technical architecture and physical database design.
3. Backend implementation and automated testing.
4. Frontend implementation and API integration.
5. End-to-end testing.
6. Deployment and documentation.

Each significant change will be versioned using Git and pushed to GitHub.

## 8. Current Status

- Requirements documented.
- Conceptual ERD created.
- Technology stack selected.
- Technical architecture documented.

The next step is to define the physical PostgreSQL schema and prepare the database implementation.