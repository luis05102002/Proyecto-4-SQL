--1. Escribe una consulta que recupere los Vuelos (flights) y su identificador que figuren con status On Time.

SELECT flight_id,            -- identificador del vuelo
       flight_no             -- número del vuelo (opcional, pero útil)
FROM   bookings.flights
WHERE  status = 'On Time';

--2. Escribe una consulta que extraiga todas las columnas de la tabla bookings y refleje todas las reservas que han supuesto una cantidad total mayor a 1.000.000 (Unidades monetarias).

SELECT *
FROM bookings.bookings
WHERE total_amount > 1000000;

--3. Escribe una consulta que extraiga todas las columnas de los datos de los modelos de aviones disponibles (aircraft_data). Puede que os aparezca en alguna actualización como "aircrafts_data", revisad las tablas y elegid la que corresponda.

SELECT *
FROM bookings.aircrafts_data;


--4. Con el resultado anterior visualizado previamente, escribe una consulta que extraiga los identificadores de vuelo que han volado con un Boeing 737. (Código Modelo Avión = 733)


SELECT DISTINCT f.flight_id, f.flight_no, f.scheduled_departure, f.departure_airport, f.arrival_airport
FROM bookings.flights f
WHERE f.aircraft_code = '733';

--5. Escribe una consulta que te muestre la información detallada de los tickets que han comprado las personas que se llaman Irina.

SELECT 
    t.ticket_no,
    t.book_ref,
    t.passenger_id,
    t.passenger_name,
    t.contact_data,
    b.book_date,
    b.total_amount,
    tf.flight_id,
    tf.fare_conditions,
    tf.amount AS segment_amount,
    f.flight_no,
    f.scheduled_departure,
    f.scheduled_arrival,
    dep.city AS departure_city,
    arr.city AS arrival_city
FROM bookings.tickets t
JOIN bookings.bookings b ON t.book_ref = b.book_ref
JOIN bookings.ticket_flights tf ON t.ticket_no = tf.ticket_no
JOIN bookings.flights f ON tf.flight_id = f.flight_id
JOIN bookings.airports dep ON f.departure_airport = dep.airport_code
JOIN bookings.airports arr ON f.arrival_airport = arr.airport_code
WHERE t.passenger_name ILIKE 'Irina%'
   OR t.passenger_name ILIKE '% Irina %'
   OR t.passenger_name ILIKE '% Irina';


--6. Mostrar las ciudades con más de un aeropuerto.

SELECT 
    city,
    COUNT(*) AS airport_count
FROM bookings.airports
GROUP BY city
HAVING COUNT(*) > 1
ORDER BY airport_count DESC, city;

--7. Mostrar el número de vuelos por modelo de avión.

SELECT 
    a.aircraft_code,
    (a.model ->> 'en') AS model_en,
    (a.model ->> 'ru') AS model_ru,
    COUNT(f.flight_id) AS flight_count
FROM bookings.aircrafts_data a
LEFT JOIN bookings.flights f ON a.aircraft_code = f.aircraft_code
GROUP BY 
    a.aircraft_code, 
    a.model
ORDER BY 
    flight_count DESC, 
    a.aircraft_code;

--8. Reservas con más de un billete (varios pasajeros).

SELECT 
    b.book_ref,
    b.book_date,
    b.total_amount,
    COUNT(t.ticket_no) AS ticket_count,
    STRING_AGG(t.passenger_name, '; ') AS passengers
FROM bookings.bookings b
JOIN bookings.tickets t ON b.book_ref = t.book_ref
GROUP BY 
    b.book_ref, 
    b.book_date, 
    b.total_amount
HAVING 
    COUNT(t.ticket_no) > 1
ORDER BY 
    ticket_count DESC, 
    b.book_date DESC;


--9. Vuelos con retraso de salida superior a una hora.

SELECT 
    f.flight_id,
    f.flight_no,
    f.departure_airport,
    f.arrival_airport,
    f.scheduled_departure,
    f.actual_departure,
    (f.actual_departure - f.scheduled_departure) AS delay
FROM bookings.flights f
WHERE 
    f.actual_departure IS NOT NULL
    AND f.actual_departure > f.scheduled_departure + INTERVAL '1 hour'
ORDER BY delay DESC;
