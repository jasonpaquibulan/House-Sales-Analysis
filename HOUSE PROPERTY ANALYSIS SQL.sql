
-- LOADING DATASET sale_date
-- since the sale_date can't be load as DATE datatype I've decided to load it under varchar
-- then change it to date data type in SQL.

CREATE TABLE sale_date(
	sale_date VARCHAR,
	order_number INT,
	"type" VARCHAR,
	bedrooms INT
)

SELECT * FROM sale_date

-- Changing sale_date datatype from varchar to DATE

SELECT TO_DATE(sale_date, 'DD-MM-YYY') FROM sale_date

UPDATE sale_date
SET sale_date = TO_DATE(sale_date, 'DD-MM-YYYY')

ALTER TABLE sale_date
ALTER COLUMN sale_date TYPE DATE
USING (sale_date :: DATE)


-- LOADING DATA SET sold_date...

CREATE TABLE sold_date(
	"datesold" DATE,
	"postcode" BIGINT,
	"price" BIGINT,
	"propertyType" VARCHAR,
	"bedrooms" INT
)

SELECT * FROM sold_date

ALTER TABLE sold_date
RENAME datesold to date_sold

ALTER TABLE sold_date
RENAME "propertyType" to property_type


-- DATA EXPLORATION(CHECKING NULL VALUES AND MISPELLINGS) - sale_date tale

SELECT * FROM sale_date

ALTER TABLE sale_date
RENAME "type" to property_type

SELECT sale_date FROM sale_date
WHERE sale_date ISNULL

SELECT order_number FROM sale_date
WHERE order_number ISNULL

SELECT property_type FROM sale_date
WHERE property_type ISNULL

SELECT bedrooms FROM sale_date
WHERE bedrooms ISNULL

-- NO NULL VALUES UPON CHECKING

-- CHECKING FOR MISPELLINGS

SELECT property_type FROM sale_date
GROUP BY property_type

SELECT * FROM sale_date


-- DATA EXPLORATION(CHECKING NULL VALUES AND MISPELLINGS) - sold_date tale

SELECT * FROM sold_date

SELECT date_sold FROM sold_date
WHERE date_sold ISNULL

SELECT postcode FROM sold_date
WHERE postcode ISNULL

SELECT price FROM sold_date
WHERE price ISNULL

SELECT property_type FROM sold_date
WHERE property_type ISNULL

SELECT bedrooms FROM sold_date
WHERE bedrooms ISNULL

-- UPON CHECKING NO NULL VALUES

-- CHECKING SPELLING

SELECT property_type FROM sold_date
GROUP BY property_type

-- NO MISSPELLING

SELECT * FROM sale_date

SELECT * FROM sold_date

-- CHECKING FOR AN OUTLIER ON PRICE - TABLE sold_date

SELECT *, ((price - AVG(price) over())/ STDDEV(price) over()) as outlier_test FROM sold_date

SELECT * FROM (
SELECT *, ((price - AVG(price) over())/ STDDEV(price) over()) as outlier_test FROM sold_date
)x
WHERE x.outlier_test < -2.576 or x.outlier_test > 2.576 

-- UPON CHECKING THERE ARE 685 OUTLIERS
-- SELECTING DATA WITHOUT THE OUTLIERS

SELECT * FROM (
SELECT *, ((price - AVG(price) over())/ STDDEV(price) over()) as outlier_test FROM sold_date
)x
WHERE x.outlier_test < 2.576 AND x.outlier_test > -2.576 

-- SELECTING DATA WITHOUT DUPLICATE VALUES AND WITHOUT OUTLIERS

SELECT DISTINCT * FROM (
SELECT *, ((price - AVG(price) over())/ STDDEV(price) over()) as outlier_test FROM sold_date
)x
WHERE x.outlier_test < 2.576 AND x.outlier_test > -2.576

-- CREATING TABLE WITH CLEANED DATA SET 

CREATE TABLE sold_date_cleaned AS SELECT DISTINCT * FROM (
SELECT *, ((price - AVG(price) over())/ STDDEV(price) over()) as outlier_test FROM sold_date
)x
WHERE x.outlier_test < 2.576 AND x.outlier_test > -2.576

SELECT * FROM sold_date_cleaned


-- REMOVING DUPLICATES FROM TABLE sale_date

SELECT DISTINCT * FROM sale_date

-- CREATING TABLE...

CREATE TABLE sale_date_cleaned AS SELECT DISTINCT * FROM sale_date

-- USING THESE TABLES TO ANSWER THE FOLLOWING BUSINESS QUESITONS

SELECT * FROM sold_date_cleaned

SELECT * FROM sale_date_cleaned

-- TO FORMULATE BUSINESS QUESTIONS THESE ARE THE THINGS I ASK MYSELF
-- IF I'M TASK BY A REAL ESTATE COMPANY TO ANALYZE THESE DATA SO THAT THEY CAN MAKE
-- MORE MONEY. WHAT WOULD I SHOW THEM??

1. WHAT DATE HAS THE MOST AMOUNT SOLD IN REAL ESTATE
2. WHAT POSTCODE HAS THE MOST AMOUNT SOLD IN REAL ESTATE
3. WHAT IS THE AVG PURCHASE OF A HOUSE?
4. WHAT IS THE AVG PURCHASE OF A UNIT
5. HOW MANY BEDROOMS SOLD THE MOST AMOUNT OF HOUSE
6. HOW MANY BEDROOMS SOLD THE MOST AMOUNT OF UNIT
7. WHAT POSTCODE HAS THE MOST AMOUNT SOLD OF HOUSE
8. WHAT POSTCODE HAS THE MOST AMOUNT SOLD OF UNIT
9. WHAT YEAR WITH THE MOST AMOUNT OF HOUSE SOLD
10. WHAT YEAR WITH MOST AMOUNT OF UNIT SOLD

-- ANSWERING BUSINESS QUESTIONS USING SQL QUERIES

1. WHAT DATA TREND THAT HAS THE MOST AMOUNT SOLD IN REAL ESTATE

SELECT * FROM sold_date_cleaned

SELECT date_sold, SUM(price) AS total_purchased FROM sold_date_cleaned
GROUP BY date_sold
ORDER BY date_sold ASC

2. WHAT POSTCODE HAS THE MOST AMOUNT SOLD IN REAL ESTATE

SELECT postcode, sum(price) as total_purchased FROM sold_date_cleaned
GROUP BY postcode
ORDER BY total_purchased DESC

3. WHAT IS THE AVG PURCHASE OF A HOUSE? OF UNIT?

SELECT property_type, ROUND(AVG(price)) as avg_purchased FROM sold_date_cleaned
GROUP BY property_type
ORDER BY avg_purchased desc

5. HOW MANY BEDROOMS SOLD THE MOST AMOUNT OF HOUSE

SELECT * FROM (SELECT property_type,bedrooms, sum(price) as total_purchased FROM sold_Date_cleaned
GROUP BY property_type,bedrooms)x
WHERE x.property_type = 'house'
ORDER BY x.total_purchased desc

6. HOW MANY BEDROOMS SOLD THE MOST AMOUNT OF UNIT

SELECT * FROM (SELECT property_type,bedrooms, sum(price) as total_purchased FROM sold_Date_cleaned
GROUP BY property_type,bedrooms)x
WHERE x.property_type = 'unit'
ORDER BY x.total_purchased desc

7. WHAT POSTCODE HAS THE MOST AMOUNT SOLD OF HOUSE

SELECT * FROM (
SELECT postcode,property_type, sum(price) total_purchased FROM sold_date_cleaned
GROUP BY postcode,property_type)x
WHERE x.property_type = 'house'
ORDER BY x.total_purchased desc

8. WHAT POSTCODE HAS THE MOST AMOUNT SOLD OF UNIT

SELECT * FROM (
SELECT postcode,property_type, sum(price) total_purchased FROM sold_date_cleaned
GROUP BY postcode,property_type)x
WHERE x.property_type = 'unit'
ORDER BY x.total_purchased desc

9. WHAT YEAR WITH THE MOST AMOUNT OF HOUSE SOLD

-- TO ANSWER THIS WE EXTRACT THE YEAR OF THE COLUMN DATE SOLD AND 
-- PUT IT IN A SEPARATE COLUMN

ALTER TABLE sold_date_cleaned
ADD COLUMN year_sold BIGINT

SELECT extract(YEAR FROM date_sold) FROM sold_date_cleaned

UPDATE sold_date_cleaned 
SET year_sold = extract(YEAR FROM date_sold)

SELECT * FROM (SELECT property_type, year_sold, SUM(price) AS total_purchased FROM sold_date_cleaned
GROUP BY property_type, year_sold)x
WHERE x.property_type = 'house'
ORDER BY total_purchased DESC


10. WHAT YEAR WITH MOST AMOUNT OF UNIT SOLD

SELECT * FROM (SELECT property_type, year_sold, SUM(price) AS total_purchased FROM sold_date_cleaned
GROUP BY property_type, year_sold)x
WHERE x.property_type = 'unit'
ORDER BY total_purchased DESC