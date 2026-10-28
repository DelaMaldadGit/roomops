# RoomOps — Diseño de la Base de Datos

## 1. Objetivo

RoomOps utiliza PostgreSQL como base de datos relacional. El esquema inicial contiene siete tablas: `users`, `rooms`, `room_prices`, `customers`, `reservations`, `payments` y `expenses`.

Las reglas que dependen de varios registros deben validarse desde el backend mediante transacciones. Las reglas de disponibilidad de V1 se basarán en las reservas guardadas en RoomOps.

## 2. Convenciones

- Nombres de tablas y columnas en minúsculas y `snake_case`.
- Claves primarias `BIGINT GENERATED ALWAYS AS IDENTITY`.
- Claves foráneas con el mismo nombre que la clave primaria referenciada.
- Importes monetarios `NUMERIC(12,2)`.
- Instantes de tiempo `TIMESTAMPTZ`; fechas sin hora `DATE`.
- Campos obligatorios declarados como `NOT NULL`.
- Restricciones `CHECK` para validar condiciones que dependen de una fila.
- Las referencias históricas deben conservarse; evitar eliminaciones físicas que borren historial operativo.

## 3. Definición de tablas

### 3.1. `users`

| Columna | Tipo | Restricciones |
|---|---|---|
| `user_id` | `BIGINT` | PK, identidad |
| `display_name` | `VARCHAR(80)` | NOT NULL, no vacío |
| `email` | `VARCHAR(254)` | NOT NULL |
| `password_hash` | `VARCHAR(255)` | NOT NULL |
| `role` | `VARCHAR(20)` | NOT NULL, `ADMIN` u `OPERATOR` |
| `active` | `BOOLEAN` | NOT NULL, DEFAULT TRUE |

El email será el identificador de inicio de sesión y será único sin distinguir entre mayúsculas y minúsculas, además será obligatorio y no puede estar vacío. El backend deberá normalizarlo. Las contraseñas se almacenarán como hashes seguros, nunca en texto plano. Los usuarios inactivos no podrán iniciar sesión.

### 3.2. `rooms`

| Columna | Tipo | Restricciones |
|---|---|---|
| `room_id` | `BIGINT` | PK, identidad |
| `name` | `VARCHAR(100)` | NOT NULL, no vacío |
| `description` | `TEXT` | NULL permitido |
| `theme` | `VARCHAR(80)` | NOT NULL, no vacío |
| `difficulty` | `VARCHAR(20)` | NOT NULL, `EASY`, `MEDIUM`, `HARD` o `EXPERT` |
| `min_capacity` | `INTEGER` | NOT NULL, mayor o igual que 2 |
| `max_capacity` | `INTEGER` | NOT NULL, mayor o igual que `min_capacity` |
| `duration_minutes` | `INTEGER` | NOT NULL, mayor que 0 |
| `status` | `VARCHAR(20)` | NOT NULL, DEFAULT `ACTIVE`; `ACTIVE` o `INACTIVE` |

La duración representa la duración de la experiencia. V1 no tendrá un atributo de intervalo de preparación por sala. Una sala inactiva no podrá recibir nuevas reservas, pero conservará su historial.

### 3.3. `room_prices`

| Columna | Tipo | Restricciones |
|---|---|---|
| `room_price_id` | `BIGINT` | PK, identidad |
| `room_id` | `BIGINT` | NOT NULL, FK → `rooms.room_id` |
| `players` | `INTEGER` | NOT NULL, mayor que 0 |
| `price` | `NUMERIC(12,2)` | NOT NULL, mayor o igual que 0 |

Debe existir una restricción `UNIQUE (room_id, players)`, para que cada sala tenga como máximo un precio configurado para cada cantidad de jugadores.

Los cambios en esta tabla no modificarán el precio histórico de reservas existentes. `reservations.agreed_price` conservará el precio acordado para cada reserva.

### 3.4. `customers`

| Columna | Tipo | Restricciones |
|---|---|---|
| `customer_id` | `BIGINT` | PK, identidad |
| `first_name` | `VARCHAR(80)` | NOT NULL, no vacío |
| `last_name` | `VARCHAR(80)` | NOT NULL, no vacío |
| `phone` | `VARCHAR(30)` | NOT NULL, no vacío |
| `email` | `VARCHAR(254)` | NOT NULL |

El email es obligatorio, y no único. El teléfono se almacena como texto para conservar prefijos, signos y ceros iniciales. No se deben eliminar físicamente clientes que tengan reservas asociadas.

### 3.5. `reservations`

| Columna | Tipo | Restricciones |
|---|---|---|
| `reservation_id` | `BIGINT` | PK, identidad |
| `customer_id` | `BIGINT` | NOT NULL, FK → `customers.customer_id` |
| `room_id` | `BIGINT` | NOT NULL, FK → `rooms.room_id` |
| `start_datetime` | `TIMESTAMPTZ` | NOT NULL |
| `players` | `INTEGER` | NOT NULL, mayor que 0 |
| `agreed_price` | `NUMERIC(12,2)` | NOT NULL, mayor o igual que 0 |
| `status` | `VARCHAR(20)` | NOT NULL, `CONFIRMED`, `COMPLETED` o `CANCELLED` |
| `notes` | `TEXT` | NULL permitido |
| `created_at` | `TIMESTAMPTZ` | NOT NULL, DEFAULT `CURRENT_TIMESTAMP` |

El backend deberá validar la capacidad, el estado de la sala y la disponibilidad antes de confirmar una reserva. La cancelación actualizará el estado y conservará la reserva y sus pagos.

V1 no incluye sincronización con Booknetic. Por ello, el esquema representa las reservas registradas en RoomOps y no puede reflejar por sí solo las reservas externas que no se hayan ingresado manualmente.

### 3.6. `payments`

| Columna | Tipo | Restricciones |
|---|---|---|
| `payment_id` | `BIGINT` | PK, identidad |
| `reservation_id` | `BIGINT` | NOT NULL, FK → `reservations.reservation_id` |
| `user_id` | `BIGINT` | NOT NULL, FK → `users.user_id` |
| `amount` | `NUMERIC(12,2)` | NOT NULL, mayor que 0 |
| `payment_method` | `VARCHAR(20)` | NOT NULL, `CASH` o `MERCADO_PAGO` |
| `created_at` | `TIMESTAMPTZ` | NOT NULL, DEFAULT `CURRENT_TIMESTAMP` |

Una reserva podrá tener múltiples pagos. RoomOps solo registrará pagos realizados externamente; no procesará cobros reales en V1.

El total pagado no podrá superar `agreed_price`. Esta regla depende de varios registros y no puede implementarse mediante un `CHECK` simple. El backend deberá verificar el saldo e insertar el pago dentro de una transacción que impida que dos operaciones simultáneas excedan el importe permitido. Los pagos se conservarán aunque se cancele la reserva.

### 3.7. `expenses`

| Columna | Tipo | Restricciones |
|---|---|---|
| `expense_id` | `BIGINT` | PK, identidad |
| `user_id` | `BIGINT` | NOT NULL, FK → `users.user_id` |
| `expense_date` | `DATE` | NOT NULL |
| `concept` | `VARCHAR(150)` | NOT NULL, no vacío |
| `amount` | `NUMERIC(12,2)` | NOT NULL, mayor que 0 |
| `category` | `VARCHAR(20)` | NOT NULL, `INSUMOS`, `MANTENIMIENTO` o `VARIOS` |
| `created_at` | `TIMESTAMPTZ` | NOT NULL, DEFAULT `CURRENT_TIMESTAMP` |

`expense_date` representa cuándo ocurrió el gasto y `created_at`, cuándo se registró en RoomOps.

## 4. Relaciones

- `rooms` 1:N `room_prices`
- `customers` 1:N `reservations`
- `rooms` 1:N `reservations`
- `reservations` 1:N `payments`
- `users` 1:N `payments`
- `users` 1:N `expenses`

Las claves foráneas deben impedir referencias a registros inexistentes. Las eliminaciones físicas de registros referenciados deberán restringirse para preservar el historial.

## 5. Índices recomendados

```sql
CREATE UNIQUE INDEX uq_users_email_lower
    ON users (LOWER(email));

CREATE INDEX ix_reservations_room_start
    ON reservations (room_id, start_datetime);

CREATE INDEX ix_reservations_customer
    ON reservations (customer_id);

CREATE INDEX ix_payments_reservation
    ON payments (reservation_id);

CREATE INDEX ix_expenses_date
    ON expenses (expense_date);
```

No se deberán crear índices duplicados si las restricciones `UNIQUE` ya generan índices equivalentes.

## 6. Integridad transaccional

El backend deberá coordinar mediante transacciones las operaciones que afecten varios registros. En particular:

- Crear o modificar una reserva y guardar su precio acordado.
- Verificar el saldo pendiente y registrar un pago.
- Impedir que pagos concurrentes superen el precio acordado.
- Validar conflictos de horario al crear o modificar reservas.

La prevención de conflictos debe contemplar solicitudes simultáneas; una consulta previa sin protección transaccional no es suficiente.

Para crear o modificar una reserva, el backend deberá serializar las operaciones de disponibilidad de una misma sala mediante un bloqueo transaccional de la fila de la sala o un mecanismo equivalente.

Dentro de la transacción deberá validar el estado de la sala, la capacidad y los intervalos horarios de las reservas confirmadas, y guardar la operación únicamente si no existe un conflicto.

El intervalo ocupado se calculará a partir de `start_datetime` y `rooms.duration_minutes`. Las reservas canceladas no bloquearán horarios.

La transacción deberá impedir que dos solicitudes concurrentes confirmen reservas incompatibles para la misma sala.

## 7. Seguridad

- Almacenar únicamente hashes de contraseñas.
- No incluir contraseñas ni hashes en logs.
- Aplicar autorización por rol en el backend.
- No versionar credenciales ni tokens secretos.

## 8. Estado del diseño

Este documento define el esquema inicial, pero no reemplaza las migraciones SQL. Antes de considerar terminado el diseño deberán prepararse migraciones versionadas y pruebas de restricciones, claves foráneas, conflictos de horario y pagos concurrentes.