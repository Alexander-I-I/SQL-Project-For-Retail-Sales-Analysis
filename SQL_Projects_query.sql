-- Анализ розничных продаж на основе SQL
CREATE DATABASE project_sql;

-- Создание таблицы
DROP TABLE IF EXISTS retails_sales;
CREATE TABLE retails_sales
            (
                transactions_id INT PRIMARY KEY,	
                sale_date DATE,	 
                sale_time TIME,	
                customer_id	INT,
                gender	VARCHAR(15),
                age	INT,
                category VARCHAR(15),	
                quantity	INT,
                price_per_unit FLOAT,	
                cogs	FLOAT,
                total_sale FLOAT
            );

SELECT * 
FROM retails_sales
LIMIT 10;


SELECT COUNT(*) 
FROM retail_sales

-- -- Извлечение строк с пропущенными значениями (NULL) в ключевых столбцах для очистки данных
SELECT * FROM retails_sales
WHERE 
    sale_date IS NULL
    OR 
    sale_time IS NULL
    OR
    gender IS NULL
    OR
    category IS NULL
    OR
    quantity IS NULL
    OR
    cogs IS NULL
	OR
    total_sale IS NULL;


-- Удаление данных, если в одном из ключевых столбцов имеются пропуски (NULL)
DELETE FROM retails_sales
WHERE 
    transactions_id IS NULL
    OR
    sale_date IS NULL
    OR 
    sale_time IS NULL
    OR
    gender IS NULL
    OR
    category IS NULL
    OR
    quantity IS NULL
    OR
    cogs IS NULL
    OR
    total_sale IS NULL;


-- Производим анализ данных
-- Подсчёт общего количества всех продаж в таблице
SELECT COUNT(*) as total_sales
FROM retails_sales;

-- Подсчёт количества уникальных клиентов, совершивших покупки
SELECT COUNT(DISTINCT customer_id) as total_sales
FROM retails_sales;


-- Анализ данных для выявления ключевых бизнес-проблем и ответы на них:

-- Вопрос 1. Напишите SQL-запрос, чтобы получить все столбцы для продаж, совершенных в '2022-11-05
SELECT *
FROM retails_sales
WHERE sale_date = '2022-11-05';

-- Вопрос 2: Как извлечь все транзакции для категории "Clothing" (Одежда), где количество проданных товаров больше или равно 4, в ноябре 2022 года?
SELECT *
FROM retails_sales
WHERE category = 'Clothing' 
	  AND to_char(sale_date, 'YYYY-MM') = '2022-11'
	  AND quantity >= 4;

-- Вопрос 3. Напишите SQL-запрос для расчета общего объема продаж (total_sale) для каждой категории.

SELECT 
	category,
	sum(total_sale) as total_amount_by_category
FROM retails_sales
GROUP BY category
ORDER BY category DESC;

-- Вопрос 4. Напишите SQL-запрос, чтобы узнать средний возраст покупателей, которые приобрели товары из категории "Красота".
SELECT
	round(avg(age),2) as avg_age
FROM retails_sales
WHERE category = 'Beauty';

-- Вопрос 5. Напишите SQL-запрос, чтобы найти все транзакции, в которых общее количество продаж превышает 1000.
SELECT *
FROM retails_sales
WHERE total_sale > 1000;

-- Вопрос 6. Напишите SQL-запрос, чтобы узнать общее количество транзакций (transaction_id), совершенных каждым полом в каждой категории.
SELECT
	gender,
	category,
	COUNT(transactions_id)
FROM retails_sales
GROUP BY
	gender,
	category
ORDER BY gender;

-- Вопрос 7. Напишите SQL-запрос, чтобы рассчитать среднее количество продаж за каждый месяц. Найдите месяц с наибольшими продажами в каждом году
SELECT
	year,
	month,
	avg_total_sale
FROM(
	SELECT
		extract(year from sale_date) as year,
		extract(month from sale_date) as month,
		avg(total_sale) as avg_total_sale,
		rank() over(partition by extract(year from sale_date) order by avg(total_sale) desc) as ranks_year
	FROM retails_sales
	GROUP BY 
		extract(year from sale_date),
		extract(month from sale_date) 
	)
WHERE ranks_year = 1

-- Вопрос 8. Напишите SQL-запрос, чтобы определить 5 лучших клиентов на основе наибольшего общего объема продаж.
SELECT
	customer_id,
	sum(total_sale) as sum_total_sales
FROM retails_sales
GROUP BY customer_id
ORDER BY sum(total_sale) desc
LIMIT 5

-- Вопрос 9. Напишите SQL-запрос, чтобы найти количество уникальных клиентов, которые приобрели товары из каждой категории.
SELECT
	category,
	count(distinct customer_id) as unique_customer
FROM retails_sales
GROUP BY category

-- Вопрос 10. Напишите SQL-запрос, чтобы определить количество заказов для каждой смены: утро (до 12:00), день (с 12:00 до 17:00), и вечер (после 17:00).
WITH shifts_retails_sales as
(
	SELECT
		*,
		CASE
			WHEN extract(hour from sale_time) < 12 THEN 'Утро'
			WHEN extract(hour from sale_time) between 12 and 17 THEN 'День'
			ELSE 'Вечер'
		END as shift  
	FROM retails_sales
)
SELECT
	shift,
	count(shift) as count_shift
FROM shifts_retails_sales
GROUP BY shift
