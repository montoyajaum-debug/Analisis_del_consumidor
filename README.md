📊 Proyecto de Análisis de Datos de Comportamiento del Cliente

🌟 Resumen (Overview)

Este proyecto de análisis de datos de extremo a extremo (end-to-end) evalúa el comportamiento de compra de los clientes utilizando técnicas avanzadas de análisis exploratorio, consultas relacionales en SQL y visualización de datos interactiva. El objetivo principal es extraer información clave sobre los patrones de gasto, el impacto de los descuentos y las preferencias de suscripción para optimizar las estrategias comerciales de la empresa.

📂 Conjunto de Datos (Dataset)

Fuente: Archivo customer_shopping_behavior.csv con $3,900$ registros y $18$ variables originales.Descripción: Contiene información detallada sobre las transacciones de los clientes, demografía, montos de compra, valoraciones de reseñas, métodos de pago y estado de suscripción.Variables Clave:customer_id: Identificador único del cliente.age: Edad del comprador.gender: Género del cliente.item_purchased: Producto adquirido.category: Categoría del producto (ropa, calzado, accesorios, etc.).purchase_amount: Monto pagado por la transacción (USD).review_rating: Calificación otorgada por el cliente.subscription_status: Estado de suscripción (Sí/No).discount_applied: Indicador de si se aplicó un descuento (Sí/No).

🛠️ Herramientas y Tecnologías (Tools)

Python: Pandas, NumPy, SQLAlchemy y Psycopg2 para la ingesta, limpieza, imputación de nulos y transformación de datos.
Base de Datos / SQL: PostgreSQL para el almacenamiento relacional y la ejecución de consultas analíticas avanzadas.
Visualización: Power BI para la construcción de un panel (dashboard) interactivo de negocio.
Reportes y Presentación: Creación de informes ejecutivos y diseño de una presentación interactiva utilizando Gamma.

👣 Pasos del Proyecto (Steps)

Carga y Análisis Exploratorio (EDA): Importación del conjunto de datos en Python, revisión de tipos de datos, estadísticas descriptivas y detección de valores nulos (específicamente $37$ valores faltantes en review_rating).Limpieza de Datos y Transformación:Imputación de los valores nulos en las valoraciones utilizando la mediana por categoría (df.groupby('category')['review_rating']).Normalización de nombres de columnas a minúsculas y reemplazo de espacios por guiones bajos.Detección y eliminación de columnas redundantes (como promo_code_used que era idéntica a discount_applied).Creación de nuevas características (Feature Engineering): rangos de edad (age_group) y frecuencia de compra en días (purchase_frequency_days).Consultas SQL Avanzadas: Ejecución de $10$ consultas de negocio en PostgreSQL para responder preguntas clave sobre ingresos, segmentación y rendimiento de productos.Dashboard y Reporte: Conexión de los datos limpios a Power BI para el diseño visual y desarrollo de diapositivas ejecutivas con Gamma.

📈 Panel Interactivo (Dashboard)

El panel desarrollado en Power BI (customer_shopping_behavior.pbix) incluye:KPIs Principales: Ingresos totales ($Total Revenue$), gasto promedio por cliente y número total de transacciones.Filtros Dinámicos: Segmentación por categoría de producto, género, estación y estado de suscripción.Visuales Clave: Gráficos de barras para los productos más vendidos, análisis de ingresos por grupo de edad y comportamiento de envíos.

📊 Resultados y Hallazgos (Results)A través de las consultas SQL y el análisis en Python, se obtuvieron las siguientes conclusiones clave:Q1 (Ingresos por Género): Se identificó la contribución económica exacta segmentada por género, mostrando diferencias notables en el volumen de compras.Q2 & Q6 (Descuentos): El análisis de los productos con mayor porcentaje de descuentos aplicados demostró cómo las promociones impactan el volumen de transacciones sin disminuir drásticamente el gasto promedio.Q5 (Suscripciones): Los clientes suscritos muestran patrones de retención y un nivel de gasto diferenciado en comparación con los no suscriptores.Q8 (Productos Top por Categoría): Mediante funciones de ventana (ROW_NUMBER() OVER(PARTITION BY category)), se determinaron los $3$ productos más vendidos dentro de cada categoría de negocio.Q10 (Grupos de Edad): El desglose por rangos etarios reveló qué segmento poblacional aporta el mayor volumen de ingresos a la compañía.🚀 Cómo Ejecutar el Proyecto (How to Run)Para replicar este proyecto en tu entorno local, sigue estos pasos:Clonar el repositorio:git clone https://github.com/tu-usuario/proyecto-analisis-datos.gitu
Ejecutar el pipeline de Python:Abre el entorno de Google Colab o Jupyter Notebook.Ejecuta el script de limpieza con el archivo customer_shopping_behavior.csv.Configurar la Base de Datos:Crea una base de datos en PostgreSQL.Carga los datos limpios y ejecuta las consultas ubicadas en la sección de SQL (Q1 a Q10).Visualizar el Dashboard:Abre el archivo correspondiente en Power BI Desktop para interactuar con las métricas del negocio.
