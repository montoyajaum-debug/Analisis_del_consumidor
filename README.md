# Comportamiento del cliente en retail: por qué este dataset no sustenta decisiones comerciales

**Python · PostgreSQL · Power BI**

## Resumen ejecutivo

**Problema:** una empresa de retail quiere saber si debe orientar sus campañas por género, suscripción o descuentos, a partir de 3.900 transacciones.

**Hallazgo principal:** el ticket promedio es prácticamente igual entre géneros, suscriptores, compras con descuento y tipos de envío (diferencias de 2 USD o menos sobre un ticket promedio de 59,76 USD), y el dataset presenta artefactos que no ocurren en datos reales: el 100 % de los suscriptores son hombres y el 100 % de ellos recibió descuento.

**Recomendación:** no basar campañas segmentadas en estos datos. Validar primero el origen y el proceso de captura, y medir con un experimento controlado antes de invertir.

<!-- [COMPLETAR: subir la captura del dashboard a images/dashboard.png y descomentar la línea siguiente]
![Dashboard](images/dashboard.png)
-->

## Contexto y preguntas de negocio

El análisis parte de 10 preguntas de negocio sobre ingresos, descuentos, suscripción, segmentación de clientes y productos. Al responderlas, las diferencias entre segmentos resultaron mínimas y aparecieron patrones imposibles en datos reales. Por eso el proyecto incluye una **validación de la calidad del dataset** antes de emitir recomendaciones: un análisis que lleva a una mala decisión es peor que ningún análisis.

## Datos

| Aspecto | Detalle |
|---|---|
| Fuente | `customer_shopping_behavior.csv` [COMPLETAR: origen del dataset y enlace] |
| Tamaño | 3.900 transacciones, 18 variables |
| Granularidad | Una fila por cliente/transacción |
| Calidad | 37 valores nulos en `review_rating`, imputados con la mediana por categoría. `promo_code_used` era idéntica a `discount_applied` y se eliminó |

## Enfoque

1. **Limpieza y transformación (Python/pandas):** imputación de nulos, normalización de nombres de columnas, eliminación de la columna redundante, creación de `age_group` (cuartiles de edad) y `purchase_frequency_days`.
2. **Carga en PostgreSQL** con SQLAlchemy y respuesta a 10 preguntas de negocio en SQL.
3. **Validación de calidad:** consultas adicionales para detectar relaciones artificiales entre variables (Q11–Q12).
4. **Dashboard en Power BI** con KPIs de ingresos, ticket promedio y transacciones, filtrable por categoría, género, estación y suscripción.

## Hallazgos

1. **El género no explica el gasto.** Los hombres generan el 67,7 % de los ingresos, pero solo porque son el 68 % de los clientes. El ticket promedio es casi igual: 59,54 USD (hombres) vs. 60,25 USD (mujeres).
2. **La suscripción no aumenta el ticket.** Los suscriptores gastan 59,49 USD por compra frente a 59,87 USD de los no suscriptores.
3. **El descuento no cambia el gasto.** Ticket de 59,28 USD con descuento vs. 60,13 USD sin descuento.
4. **La recurrencia no se asocia a la suscripción.** Entre los clientes con más de 5 compras previas, el 27,6 % está suscrito, casi igual al 27,0 % del total.
5. **Ropa concentra el 44,7 % de los ingresos**, seguida de Accesorios (31,8 %), Calzado (15,5 %) y Abrigos (7,9 %). Es la única diferencia relevante, y se explica por volumen de compras, no por ticket.
6. **El dataset tiene artefactos:** todos los suscriptores son hombres, todos recibieron descuento, ninguna mujer tiene suscripción ni descuento, y los montos se distribuyen de forma casi uniforme entre 20 y 100 USD. Estos patrones indican datos generados o un error en la captura.

## Recomendaciones

| Recomendación | Basada en | Prioridad |
|---|---|---|
| No lanzar campañas segmentadas por género o suscripción con estos datos | Hallazgos 1, 2 y 6 | Alta |
| Auditar el proceso de captura de suscripción y descuentos antes de reutilizar los datos | Hallazgo 6 | Alta |
| Si se quiere medir el efecto del descuento, hacerlo con un experimento A/B y no con datos históricos | Hallazgo 3 | Media |
| Priorizar inventario y visibilidad de Ropa y Accesorios, que suman el 76,5 % de los ingresos | Hallazgo 5 | Media |

## Mejoras técnicas aplicadas al SQL

En la revisión del código se corrigieron tres errores que no generaban error pero sí resultados incorrectos:

| Consulta | Problema | Corrección |
|---|---|---|
| Q6 | División entera en PostgreSQL: 49,66 % se mostraba como 49 | `100.0` en lugar de `100` |
| Q8 | `ROW_NUMBER` ordenaba arbitrariamente productos empatados (Blouse y Pants con 171 compras) | `RANK()` |
| Q2 | `>=` incluía compras iguales al promedio cuando la pregunta pedía "más que" | `>` |

Además, la segmentación de Q7 dejaba al ~80 % de los clientes como "Loyal"; se agregó una alternativa por terciles (Q7b).

## Limitaciones

- Los hallazgos describen este dataset, no un comportamiento de mercado real.
- No hay fechas de transacción, lo que impide analizar tendencias o estacionalidad real más allá de la variable `season`.
- `age_group` se construyó por cuartiles, por lo que los grupos tienen el mismo tamaño por diseño y sus ingresos son comparables solo en ticket, no en volumen.

## Estructura del repositorio

```
├── customer_shopping_behavior.csv      # datos originales
├── customer_shopping_behavior.ipynb    # limpieza y transformación (Python)
├── customer_behavior.sql               # 12 consultas de negocio y validación (PostgreSQL)
├── customer_behavior_dashboard.pbix    # dashboard (Power BI)
└── images/                             # capturas
```

## Cómo reproducir

1. Clona el repositorio:
   ```bash
   git clone https://github.com/montoyajaum-debug/Analisis_del_consumidor.git
   ```
2. Ejecuta `customer_shopping_behavior.ipynb` (Jupyter o Google Colab) para limpiar los datos y cargarlos en PostgreSQL. Ajusta la cadena de conexión a tu base de datos.
3. Ejecuta `customer_behavior.sql` en PostgreSQL.
4. Abre `customer_behavior_dashboard.pbix` en Power BI Desktop.

## Autor

**Jhon Alexander Urrea Montoya** · [LinkedIn](https://www.linkedin.com/in/jhon-urrea-data) · montoyajaum@gmail.com
