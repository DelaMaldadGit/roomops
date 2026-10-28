
-- RoomOps - Ajustes de restricciones del esquema

-- Todas las salas deben admitir al menos 2 jugadores.
ALTER TABLE rooms
    DROP CONSTRAINT ck_rooms_min_capacity;

ALTER TABLE rooms
    ADD CONSTRAINT ck_rooms_min_capacity
    CHECK (min_capacity >= 2);

-- Los emails obligatorios no pueden estar vacíos ni contener solo espacios.
ALTER TABLE users
    ADD CONSTRAINT ck_users_email_not_blank
    CHECK (BTRIM(email) <> '');

ALTER TABLE customers
    ADD CONSTRAINT ck_customers_email_not_blank
    CHECK (BTRIM(email) <> '');
