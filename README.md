# Проект: Анализ розничных продаж с использованием SQL 

Этот проект предназначен для демонстрации навыков работы с SQL и методов, обычно используемых аналитиками данных для изучения, очистки и анализа данных о розничных продажах. Проект включает в себя создание базы данных о розничных продажах, проведение исследовательского анализа данных (EDA) и ответы на конкретные бизнес-вопросы с помощью SQL-запросов. Этот проект идеально подходит для тех, кто только начинает свой путь в области анализа данных и хочет заложить прочную основу в SQL.

# Цели:
1. Настройка базы данных розничных продаж: Создание и заполнение базы данных на основе предоставленного набора данных.
2. Очистка данных: Выявление и удаление пропущенных или некорректных записей.
3. Исследовательский анализ данных (EDA): Анализ структуры и особенностей данных для их лучшего понимания.
4. Ответы на бизнес-вопросы: Построение SQL-запросов для извлечения бизнес-аналитики и ключевых выводов.

# Требования:
- PostgreSQL или другая СУБД, поддерживающая SQL.
- Среда разработки (например, pgAdmin, DBeaver или Jupyter Notebook с плагином для SQL).
- Набор данных о розничных продажах в формате CSV.

# Структура проекта:
1. **Настройка базы данных**
 - Создание базы данных: Проект начинается с создания базы данных с именем p1_retail_db.
 - Создание таблицы: Для хранения данных о продажах создается таблица с именем retail_sales. Структура таблицы включает столбцы для идентификатора транзакции, даты продажи, времени 
   продажи, идентификатора клиента, пола, возраста, категории продукта, количества проданных товаров, цены за единицу, себестоимости проданных товаров (COGS) и общей суммы продажи.

```sql
CREATE DATABASE project_sql;
```

```sql
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
```

2. **Анализ и очистка данных**
- Подсчет записей: Определение общего количества записей в наборе данных.
- Подсчет клиентов: Выяснение количества уникальных клиентов в наборе данных.
- Подсчет категорий: Определение всех уникальных категорий продуктов в наборе данных.
- Проверка нулевого значения: Проверьте наличие любых нулевых значений в наборе данных и удалите записи с отсутствующими данными.

```sql
SELECT COUNT(*) FROM retails_sales;
SELECT COUNT(DISTINCT customer_id) FROM retails_sales;
SELECT DISTINCT category FROM retail_sales;

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
```

3. **Анализ данных и выводы**
Анализ данных для выявления ключевых бизнес-проблем и ответы на них:

***Вопрос 1. Напишите SQL-запрос, чтобы получить все столбцы для продаж, совершенных в '2022-11-05***
```sql
SELECT *
FROM retails_sales
WHERE sale_date = '2022-11-05';
```

***Вопрос 2: Как извлечь все транзакции для категории "Clothing" (Одежда), где количество проданных товаров больше или равно 4, в ноябре 2022 года? ***
```sql
SELECT *
FROM retails_sales
WHERE category = 'Clothing' 
	  AND to_char(sale_date, 'YYYY-MM') = '2022-11'
	  AND quantity >= 4;
```

***Вопрос 3. Напишите SQL-запрос для расчета общего объема продаж (total_sale) для каждой категории.***
```sql
SELECT 
	category,
	sum(total_sale) as total_amount_by_category
FROM retails_sales
GROUP BY category
ORDER BY category DESC;
```

***Вопрос 4. Напишите SQL-запрос, чтобы узнать средний возраст покупателей, которые приобрели товары из категории "Красота".***
```sql
SELECT
	round(avg(age),2) as avg_age
FROM retails_sales
WHERE category = 'Beauty';
```

***Вопрос 5. Напишите SQL-запрос, чтобы найти все транзакции, в которых общее количество продаж превышает 1000.***
```sql
SELECT *
FROM retails_sales
WHERE total_sale > 1000;
```

***Вопрос 6. Напишите SQL-запрос, чтобы узнать общее количество транзакций (transaction_id), совершенных каждым полом в каждой категории.***
```sql
SELECT
	gender,
	category,
	COUNT(transactions_id)
FROM retails_sales
GROUP BY
	gender,
	category
ORDER BY gender;
```

***Вопрос 7. Напишите SQL-запрос, чтобы рассчитать среднее количество продаж за каждый месяц. Найдите месяц с наибольшими продажами в каждом году***
```sql
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
```

***Вопрос 8. Напишите SQL-запрос, чтобы определить 5 лучших клиентов на основе наибольшего общего объема продаж.***
```sql
SELECT
	customer_id,
	sum(total_sale) as sum_total_sales
FROM retails_sales
GROUP BY customer_id
ORDER BY sum(total_sale) desc
LIMIT 5
```

***Вопрос 9. Напишите SQL-запрос, чтобы найти количество уникальных клиентов, которые приобрели товары из каждой категории.***
```sql
SELECT
	category,
	count(distinct customer_id) as unique_customer
FROM retails_sales
GROUP BY category
```

***Вопрос 10. Напишите SQL-запрос, чтобы определить количество заказов для каждой смены: утро (до 12:00), день (с 12:00 до 17:00), и вечер (после 17:00).***
```sql
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
```

**Ключевые выводы:**
- **Демография клиентов:** Широкий разброс возрастных групп и гендерный баланс, с популярными категориями, такими как "Одежда" и "Красота".
- **Тенденции продаж:** Пики продаж приходятся на определённые месяцы, что указывает на сезонность.
- **Премиум-сегмент:** Транзакции стоимостью свыше 1000, что указывает на покупки премиум-класса.
- **Потребности клиентов:** Выявлены самые популярные категории и ключевые клиенты, приносящие наибольшую прибыль.

**Отчеты:**
- **Продажи по категориям:** Анализ общего объема продаж и популярных категорий.
- **Клиенты:** Анализ лучших клиентов и демографических особенностей.
- **Тренды:** Изменения продаж в зависимости от времени суток и месяца.



