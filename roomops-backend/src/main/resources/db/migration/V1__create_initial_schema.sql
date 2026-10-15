
-- RoomOps - Migracion inicial
-- Crea las siete tablas del esquema V1.

CREATE TABLE users (
    user_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    display_name VARCHAR(80) NOT NULL,
    email VARCHAR(254) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT ck_users_display_name
        CHECK (BTRIM(display_name) <> ''),
    CONSTRAINT ck_users_role
        CHECK (role IN ('ADMIN', 'OPERATOR'))
);

CREATE UNIQUE INDEX uq_users_email_lower
    ON users (LOWER(email));


CREATE TABLE rooms (
    room_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    theme VARCHAR(80) NOT NULL,
    difficulty VARCHAR(20) NOT NULL,
    min_capacity INTEGER NOT NULL,
    max_capacity INTEGER NOT NULL,
    duration_minutes INTEGER NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT ck_rooms_name
        CHECK (BTRIM(name) <> ''),
    CONSTRAINT ck_rooms_theme
        CHECK (BTRIM(theme) <> ''),
    CONSTRAINT ck_rooms_difficulty
        CHECK (difficulty IN ('EASY', 'MEDIUM', 'HARD', 'EXPERT')),
    CONSTRAINT ck_rooms_min_capacity
        CHECK (min_capacity >= 1),
    CONSTRAINT ck_rooms_max_capacity
        CHECK (max_capacity >= min_capacity),
    CONSTRAINT ck_rooms_duration
        CHECK (duration_minutes > 0),
    CONSTRAINT ck_rooms_status
        CHECK (status IN ('ACTIVE', 'INACTIVE'))
);


CREATE TABLE room_prices (
    room_price_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    room_id BIGINT NOT NULL,
    players INTEGER NOT NULL,
    price NUMERIC(12,2) NOT NULL,

    CONSTRAINT fk_room_prices_room
        FOREIGN KEY (room_id)
        REFERENCES rooms (room_id)
        ON DELETE RESTRICT,
    CONSTRAINT ck_room_prices_players
        CHECK (players > 0),
    CONSTRAINT ck_room_prices_price
        CHECK (price >= 0),
    CONSTRAINT uq_room_prices_room_players
        UNIQUE (room_id, players)
);


CREATE TABLE customers (
    customer_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(80) NOT NULL,
    last_name VARCHAR(80) NOT NULL,
    phone VARCHAR(30) NOT NULL,
    email VARCHAR(254) NOT NULL,

    CONSTRAINT ck_customers_first_name
        CHECK (BTRIM(first_name) <> ''),
    CONSTRAINT ck_customers_last_name
        CHECK (BTRIM(last_name) <> ''),
    CONSTRAINT ck_customers_phone
        CHECK (BTRIM(phone) <> '')
);


CREATE TABLE reservations (
    reservation_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    room_id BIGINT NOT NULL,
    start_datetime TIMESTAMPTZ NOT NULL,
    players INTEGER NOT NULL,
    agreed_price NUMERIC(12,2) NOT NULL,
    status VARCHAR(20) NOT NULL,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_reservations_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers (customer_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_reservations_room
        FOREIGN KEY (room_id)
        REFERENCES rooms (room_id)
        ON DELETE RESTRICT,
    CONSTRAINT ck_reservations_players
        CHECK (players > 0),
    CONSTRAINT ck_reservations_agreed_price
        CHECK (agreed_price >= 0),
    CONSTRAINT ck_reservations_status
        CHECK (status IN ('CONFIRMED', 'COMPLETED', 'CANCELLED'))
);

CREATE INDEX ix_reservations_room_start
    ON reservations (room_id, start_datetime);

CREATE INDEX ix_reservations_customer
    ON reservations (customer_id);


CREATE TABLE payments (
    payment_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    reservation_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    amount NUMERIC(12,2) NOT NULL,
    payment_method VARCHAR(20) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_payments_reservation
        FOREIGN KEY (reservation_id)
        REFERENCES reservations (reservation_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_payments_user
        FOREIGN KEY (user_id)
        REFERENCES users (user_id)
        ON DELETE RESTRICT,
    CONSTRAINT ck_payments_amount
        CHECK (amount > 0),
    CONSTRAINT ck_payments_method
        CHECK (payment_method IN ('CASH', 'MERCADO_PAGO'))
);

CREATE INDEX ix_payments_reservation
    ON payments (reservation_id);


CREATE TABLE expenses (
    expense_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id BIGINT NOT NULL,
    expense_date DATE NOT NULL,
    concept VARCHAR(150) NOT NULL,
    amount NUMERIC(12,2) NOT NULL,
    category VARCHAR(20) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_expenses_user
        FOREIGN KEY (user_id)
        REFERENCES users (user_id)
        ON DELETE RESTRICT,
    CONSTRAINT ck_expenses_concept
        CHECK (BTRIM(concept) <> ''),
    CONSTRAINT ck_expenses_amount
        CHECK (amount > 0),
    CONSTRAINT ck_expenses_category
        CHECK (category IN ('INSUMOS', 'MANTENIMIENTO', 'VARIOS'))
);

CREATE INDEX ix_expenses_date
    ON expenses (expense_date);
