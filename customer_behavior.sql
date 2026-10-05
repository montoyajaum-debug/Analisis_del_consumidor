-- =====================================================================
-- Análisis de comportamiento del cliente — consultas de negocio
-- Motor: PostgreSQL · Tabla: customer (datos limpios desde el notebook)
-- =====================================================================

-- Vista previa
SELECT * FROM customer LIMIT 20;

-- Q1. Ingresos por género (con participación y ticket promedio)
-- Se agrega el número de clientes y el promedio: el total por sí solo
-- refleja cuántos clientes hay de cada género, no cuánto gasta cada uno.
SELECT gender,
       COUNT(*)                                                       AS clientes,
       SUM(purchase_amount)                                           AS ingresos,
       ROUND(100.0 * SUM(purchase_amount) / SUM(SUM(purchase_amount)) OVER (), 1) AS pct_ingresos,
       ROUND(AVG(purchase_amount), 2)                                 AS ticket_promedio
FROM customer
GROUP BY gender;

-- Q2. Clientes que usaron descuento y aun así gastaron MÁS que el promedio
-- CORREGIDO: ">" en lugar de ">=" (la pregunta dice "más que").
SELECT customer_id, purchase_amount
FROM customer
WHERE discount_applied = 'Yes'
  AND purchase_amount > (SELECT AVG(purchase_amount) FROM customer);

-- Q3. Top 5 productos con mejor calificación promedio
SELECT item_purchased,
       ROUND(AVG(review_rating::numeric), 2) AS calificacion_promedio
FROM customer
GROUP BY item_purchased
ORDER BY calificacion_promedio DESC
LIMIT 5;

-- Q4. Ticket promedio: envío Standard vs Express
SELECT shipping_type,
       ROUND(AVG(purchase_amount), 2) AS ticket_promedio
FROM customer
WHERE shipping_type IN ('Standard', 'Express')
GROUP BY shipping_type;

-- Q5. ¿Los suscriptores gastan más?
SELECT subscription_status,
       COUNT(customer_id)              AS clientes,
       ROUND(AVG(purchase_amount), 2)  AS ticket_promedio,
       ROUND(SUM(purchase_amount), 2)  AS ingresos
FROM customer
GROUP BY subscription_status
ORDER BY ingresos DESC;

-- Q6. Top 5 productos con mayor % de compras con descuento
-- CORREGIDO: 100.0 en lugar de 100. Con enteros, PostgreSQL trunca la división
-- (49,66 % se mostraba como 49) y el ROUND(..., 2) no tenía efecto.
SELECT item_purchased,
       ROUND(100.0 * SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_con_descuento
FROM customer
GROUP BY item_purchased
ORDER BY pct_con_descuento DESC
LIMIT 5;

-- Q7. Segmentación por compras previas (New / Returning / Loyal)
-- NOTA: previous_purchases va de 1 a 50 con distribución casi uniforme, por lo que
-- con estos umbrales el ~80 % de los clientes queda como "Loyal" y el segmento
-- no discrimina. Ver Q7b para umbrales basados en la distribución.
WITH customer_type AS (
    SELECT customer_id,
           CASE
               WHEN previous_purchases = 1              THEN 'New'
               WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
               ELSE 'Loyal'
           END AS customer_segment
    FROM customer
)
SELECT customer_segment, COUNT(*) AS clientes
FROM customer_type
GROUP BY customer_segment
ORDER BY clientes DESC;

-- Q7b. Alternativa: tres segmentos de igual tamaño (terciles)
WITH t AS (
    SELECT customer_id, previous_purchases,
           NTILE(3) OVER (ORDER BY previous_purchases) AS tercil
    FROM customer
)
SELECT tercil,
       MIN(previous_purchases) AS desde,
       MAX(previous_purchases) AS hasta,
       COUNT(*)                AS clientes
FROM t
GROUP BY tercil
ORDER BY tercil;

-- Q8. Top 3 productos más comprados por categoría
-- CORREGIDO: RANK en lugar de ROW_NUMBER. Hay empates (p. ej. Blouse y Pants con
-- 171 compras) y ROW_NUMBER los ordenaba de forma arbitraria. Con RANK, los
-- productos empatados comparten posición y ninguno queda fuera sin criterio.
WITH item_counts AS (
    SELECT category,
           item_purchased,
           COUNT(customer_id) AS total_compras,
           RANK() OVER (PARTITION BY category ORDER BY COUNT(customer_id) DESC) AS posicion
    FROM customer
    GROUP BY category, item_purchased
)
SELECT posicion, category, item_purchased, total_compras
FROM item_counts
WHERE posicion <= 3
ORDER BY category, posicion;

-- Q9. Compradores recurrentes (más de 5 compras previas): ¿se suscriben?
SELECT subscription_status,
       COUNT(customer_id) AS compradores_recurrentes,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct
FROM customer
WHERE previous_purchases > 5
GROUP BY subscription_status;

-- Q10. Ingresos por grupo de edad
-- NOTA: age_group se creó con pd.qcut (4 grupos de igual tamaño), por lo que es
-- esperable que los ingresos se repartan de forma similar entre grupos.
SELECT age_group,
       SUM(purchase_amount) AS ingresos,
       ROUND(100.0 * SUM(purchase_amount) / SUM(SUM(purchase_amount)) OVER (), 1) AS pct_ingresos
FROM customer
GROUP BY age_group
ORDER BY ingresos DESC;

-- =====================================================================
-- Q11–Q12. Validación de la calidad del dataset
-- Antes de recomendar acciones, verificar que las variables no estén
-- determinadas artificialmente entre sí.
-- =====================================================================

-- Q11. Suscripción y descuento por género
SELECT gender, subscription_status, discount_applied, COUNT(*) AS clientes
FROM customer
GROUP BY gender, subscription_status, discount_applied
ORDER BY gender, subscription_status, discount_applied;

-- Q12. Distribución del monto de compra (¿uniforme?)
SELECT width_bucket(purchase_amount, 20, 101, 8) AS rango,
       MIN(purchase_amount) AS desde,
       MAX(purchase_amount) AS hasta,
       COUNT(*)             AS compras
FROM customer
GROUP BY rango
ORDER BY rango;
