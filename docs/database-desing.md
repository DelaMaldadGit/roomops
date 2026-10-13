# RoomOps — Diseño de la Base de Datos

## 1. Descripción general

RoomOps utiliza PostgreSQL como sistema de gestión de base de datos relacional.

Este documento define el diseño físico de la base de datos a partir del Diagrama Entidad-Relación (DER) conceptual.

El esquema garantizará la integridad de los datos mediante claves primarias, claves foráneas, restricciones de unicidad, restricciones de validación y tipos de datos adecuados.

Las reglas de negocio que involucren varios registros o sistemas externos también serán gestionadas desde el backend cuando corresponda.

## 2. Convenciones de la base de datos

### 2.1. Nomenclatura

- Los nombres de las tablas se escribirán en minúsculas y en formato `snake_case`.
- Los nombres de las columnas utilizarán `snake_case`.
- Las claves primarias seguirán la convención `<entidad>_id`.
- Las claves foráneas utilizarán el mismo nombre que la clave primaria a la que hacen referencia.

### 2.2. Identificadores

- Las claves primarias y foráneas utilizarán el tipo `BIGINT`.
- Los identificadores generados automáticamente utilizarán columnas de identidad de PostgreSQL.

### 2.3. Tipos de datos

- Los valores monetarios utilizarán `NUMERIC(12,2)`.
- Las fechas sin horario utilizarán `DATE`.
- Los instantes de tiempo utilizarán `TIMESTAMPTZ`.
- Las cantidades y duraciones utilizarán tipos enteros cuando corresponda.
- Los valores lógicos utilizarán `BOOLEAN`.

### 2.4. Integridad de los datos

- Los campos obligatorios utilizarán `NOT NULL`.
- Las relaciones entre entidades se implementarán mediante claves foráneas.
- Los valores o combinaciones que deban ser únicos utilizarán `UNIQUE`.
- Las restricciones simples sobre valores utilizarán `CHECK`.
- Los estados controlados se representarán mediante tipos enumerados de PostgreSQL u otra alternativa con restricciones explícitas.

## 3. Entidades y tablas

El esquema inicial incluirá las siguientes tablas:

- `users`
- `rooms`
- `room_prices`
- `customers`
- `reservations`
- `payments`
- `expenses`

El esquema físico conservará las relaciones definidas en el DER conceptual.

## 4. Aplicación de las reglas de negocio

Las reglas se implementarán en la capa que corresponda según su naturaleza.

- Las claves primarias identificarán cada registro de manera única.
- Las claves foráneas impedirán referencias a registros inexistentes.
- Las restricciones `CHECK` validarán condiciones que puedan comprobarse sobre una misma fila.
- Las restricciones `UNIQUE` evitarán duplicaciones donde corresponda.
- Las transacciones del backend coordinarán operaciones que afecten a varios registros.
- Se diseñarán protecciones a nivel de base de datos para las reglas críticas que puedan verse afectadas por operaciones simultáneas, especialmente los conflictos entre reservas.

## 5. Disponibilidad de las reservas

En la versión inicial, RoomOps no administrará un intervalo de preparación independiente.

Se asume que la plataforma externa de reservas es responsable de publicar los horarios disponibles y aplicar sus reglas de programación.

Cuando se implemente la integración, RoomOps deberá validar las operaciones de reservas mediante los mecanismos que admita la plataforma externa.

La base de datos conservará la información de las reservas necesaria para la gestión interna y el historial.

## 6. Integridad financiera

- El precio acordado de cada reserva se almacenará como una copia del precio vigente al momento correspondiente.
- Los importes de los pagos utilizarán tipos decimales exactos.
- Una reserva podrá tener múltiples pagos.
- Los pagos no podrán superar el saldo pendiente de la reserva.
- Las operaciones que afecten los saldos deberán coordinarse mediante transacciones.

La implementación deberá impedir que operaciones simultáneas vulneren las reglas financieras.

## 7. Estado del diseño

Este documento establece las convenciones iniciales del diseño físico.

Las definiciones definitivas de las tablas, restricciones, índices y scripts de migración se desarrollarán y probarán antes de considerar terminado el esquema.