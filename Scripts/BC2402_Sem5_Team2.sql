/*
Question 1
How many countries are captured in [owid_energy_data]?
Note: Be careful! The devil is in the details.
*/

#Answer (1 row(s) returned)
SELECT COUNT(DISTINCT(iso_code)) AS 'Number of countries'
FROM owid_energy_data
where iso_code NOT LIKE 'OWID%'
AND iso_code != '';

# Created a view for future references in other questions asking for country specific
Create VIEW cleaned_owid_energy_data AS
SELECT *
FROM owid_energy_data
where iso_code NOT LIKE 'OWID%'
AND iso_code != '';

/*
Question 2 
Find the earliest and latest year in [owid_energy_data]. What are the countries 
having a record in <owid_energy_data> every year throughout the entire period (from 
the earliest year to the latest year)?
Note: The output must provide evidence that the countries have the same number of 
records.
*/

#Answer (44 row(s) returned)
SELECT a.country,MIN(year) AS earliest_year, MAX(year) AS latest_year, year_count
From owid_energy_data AS a,
(SELECT country, COUNT(year) AS year_count
FROM owid_energy_data
where iso_code NOT LIKE 'OWID%'
AND iso_code != ''
GROUP BY country
HAVING COUNT(year)=(SELECT MAX(year)-MIN(year)+1 FROM owid_energy_data)) AS b
where  a.country = b.country
GROUP BY a.country;

/* 
Question 3 
Specific to Singapore, in which year does <fossil_share_energy> stop being the full 
source of energy (i.e., <100)? Accordingly, show the new sources of energy.
*/

/*
Sources of Energy
biofuel, fossil, hydro, nuclear, other_renewables, solar, wind
*/

# Answer (35 row(s) returned)
SELECT country, year, fossil_share_energy, biofuel_share_energy, hydro_share_energy, nuclear_share_energy, other_renewables_share_energy, solar_share_energy, wind_share_energy
FROM owid_energy_data
WHERE country = 'Singapore'
AND fossil_share_energy<100
AND fossil_share_energy != '';

/*
Question 4 
Compute the average <GDP> of each ASEAN country from 2000 to 2021 (inclusive 
of both years). Display the list of countries based on the descending average GDP 
value.
*/

# Answer (10 row(s) returned)
SELECT country, AVG(CAST(NULLIF(gdp,0) AS float)) AS 'Average GDP from 2000 to 2021'
FROM owid_energy_data
WHERE year BETWEEN '2000' AND '2022'
AND country IN ('Brunei','Cambodia','Indonesia','Laos','Malaysia','Myanmar','Philippines','Singapore','Thailand','Vietnam')
GROUP BY country
ORDER BY AVG(gdp) DESC;

/*
Question 5
(Without creating additional tables/collections) 
a) For each ASEAN country, from 2000 to 2021 (inclusive of both years), 
compute the 3-year moving average of <oil_consumption> 
(e.g., 1st: average oil consumption from 2000 to 2002, 
2nd: average oil consumption from 2001 to 2003, etc.). 
b) Based on the 3-year moving averages, identify instances of negative changes (e.g., An instance of negative 
change is detected when 1st 3-yo average = 74.232, 2nd 3-yo average = 70.353). 
c) Based on the pair of 3-year averages, compute the corresponding 3-year moving 
averages in GDP.
*/

#Included year 1999 to find moving difference for year 2000

# Brunei
# a) and b) [21 row(s) returned] 
SELECT * 
FROM (SELECT year, oil_consumption, `3-year oil_consumption average`, 
`3-year oil_consumption average` - LAG(`3-year oil_consumption average`) OVER (ORDER BY year) as moving_difference,
gdp, `3-year gdp average`
FROM (SELECT year, 
oil_consumption, 
AVG(CAST(NULLIF(oil_consumption,0) AS float)) OVER(ORDER BY year
ROWS BETWEEN CURRENT ROW  AND 2 FOLLOWING)
AS '3-year oil_consumption average',
gdp,
AVG(CAST(NULLIF(gdp,0) AS float)) OVER(ORDER BY year
ROWS BETWEEN CURRENT ROW  AND 2 FOLLOWING)
AS '3-year gdp average'
FROM owid_energy_data
WHERE year BETWEEN '1999' AND '2021'
AND country = 'Brunei')a
WHERE year BETWEEN '1999' AND '2021')b
WHERE year BETWEEN '2000' AND '2021';

# c) [0 row(s) returned] 
SELECT *
FROM (SELECT year, oil_consumption, `3-year oil_consumption average`, 
`3-year oil_consumption average` - LAG(`3-year oil_consumption average`) OVER (ORDER BY year) as moving_difference,
gdp, `3-year gdp average`
FROM (SELECT year, 
oil_consumption, 
AVG(CAST(NULLIF(oil_consumption,0) AS float)) OVER(ORDER BY year
ROWS BETWEEN CURRENT ROW  AND 2 FOLLOWING)
AS '3-year oil_consumption average',
gdp,
AVG(CAST(NULLIF(gdp,0) AS float)) OVER(ORDER BY year
ROWS BETWEEN CURRENT ROW  AND 2 FOLLOWING)
AS '3-year gdp average'
FROM owid_energy_data
WHERE year BETWEEN '1999' AND '2021'
AND country = 'Brunei')a
WHERE year BETWEEN '1999' AND '2021')b
WHERE year BETWEEN '2000' AND '2021'
AND moving_difference<0;

# Cambodia
# a) and b) [21 row(s) returned] 
SELECT * 
FROM (SELECT year, oil_consumption, `3-year oil_consumption average`, 
`3-year oil_consumption average` - LAG(`3-year oil_consumption average`) OVER (ORDER BY year) as moving_difference,
gdp, `3-year gdp average`
FROM (SELECT year, 
oil_consumption, 
AVG(CAST(NULLIF(oil_consumption,0) AS float)) OVER(ORDER BY year
ROWS BETWEEN CURRENT ROW  AND 2 FOLLOWING)
AS '3-year oil_consumption average',
gdp,
AVG(CAST(NULLIF(gdp,0) AS float)) OVER(ORDER BY year
ROWS BETWEEN CURRENT ROW  AND 2 FOLLOWING)
AS '3-year gdp average'
FROM owid_energy_data
WHERE year BETWEEN '1999' AND '2021'
AND country = 'Cambodia')a
WHERE year BETWEEN '1999' AND '2021')b
WHERE year BETWEEN '2000' AND '2021';

# c) [0 row(s) returned] 
SELECT *
FROM (SELECT year, oil_consumption, `3-year oil_consumption average`, 
`3-year oil_consumption average` - LAG(`3-year oil_consumption average`) OVER (ORDER BY year) as moving_difference,
gdp, `3-year gdp average`
FROM (SELECT year, 
oil_consumption, 
AVG(CAST(NULLIF(oil_consumption,0) AS float)) OVER(ORDER BY year
ROWS BETWEEN CURRENT ROW  AND 2 FOLLOWING)
AS '3-year oil_consumption average',
gdp,
AVG(CAST(NULLIF(gdp,0) AS float)) OVER(ORDER BY year
ROWS BETWEEN CURRENT ROW  AND 2 FOLLOWING)
AS '3-year gdp average'
FROM owid_energy_data
WHERE year BETWEEN '1999' AND '2021'
AND country = 'Cambodia')a
WHERE year BETWEEN '1999' AND '2021')b
WHERE year BETWEEN '2000' AND '2021'
AND moving_difference<0;

#Indonesia
# a) and b) [21 row(s) returned] 
SELECT * 
FROM (SELECT year, oil_consumption, `3-year oil_consumption average`, 
`3-year oil_consumption average` - LAG(`3-year oil_consumption average`) OVER (ORDER BY year) as moving_difference,
gdp, `3-year gdp average`
FROM (SELECT year, 
oil_consumption, 
AVG(CAST(NULLIF(oil_consumption,0) AS float)) OVER(ORDER BY year
ROWS BETWEEN CURRENT ROW  AND 2 FOLLOWING)
AS '3-year oil_consumption average',
gdp,
AVG(CAST(NULLIF(gdp,0) AS float)) OVER(ORDER BY year
ROWS BETWEEN CURRENT ROW  AND 2 FOLLOWING)
AS '3-year gdp average'
FROM owid_energy_data
WHERE year BETWEEN '1999' AND '2021'
AND country = 'Indonesia')a
WHERE year BETWEEN '1999' AND '2021')b
WHERE year BETWEEN '2000' AND '2021';

# c) [6 row(s) returned] 
SELECT *
FROM (SELECT year, oil_consumption, `3-year oil_consumption average`, 
`3-year oil_consumption average` - LAG(`3-year oil_consumption average`) OVER (ORDER BY year) as moving_difference,
gdp, `3-year gdp average`
FROM (SELECT year, 
oil_consumption, 
AVG(CAST(NULLIF(oil_consumption,0) AS float)) OVER(ORDER BY year
ROWS BETWEEN CURRENT ROW  AND 2 FOLLOWING)
AS '3-year oil_consumption average',
gdp,
AVG(CAST(NULLIF(gdp,0) AS float)) OVER(ORDER BY year
ROWS BETWEEN CURRENT ROW  AND 2 FOLLOWING)
AS '3-year gdp average'
FROM owid_energy_data
WHERE year BETWEEN '1999' AND '2021'
AND country = 'Indonesia')a
WHERE year BETWEEN '1999' AND '2021')b
WHERE year BETWEEN '2000' AND '2021'
AND moving_difference<0;

#Laos
# a) and b) [21 row(s) returned] 
SELECT * 
FROM (SELECT year, oil_consumption, `3-year oil_consumption average`, 
`3-year oil_consumption average` - LAG(`3-year oil_consumption average`) OVER (ORDER BY year) as moving_difference,
gdp, `3-year gdp average`
FROM (SELECT year, 
oil_consumption, 
AVG(CAST(NULLIF(oil_consumption,0) AS float)) OVER(ORDER BY year
ROWS BETWEEN CURRENT ROW  AND 2 FOLLOWING)
AS '3-year oil_consumption average',
gdp,
AVG(CAST(NULLIF(gdp,0) AS float)) OVER(ORDER BY year
ROWS BETWEEN CURRENT ROW  AND 2 FOLLOWING)
AS '3-year gdp average'
FROM owid_energy_data
WHERE year BETWEEN '1999' AND '2021'
AND country = 'Laos')a
WHERE year BETWEEN '1999' AND '2021')b
WHERE year BETWEEN '2000' AND '2021';

# c) [0 row(s) returned] 
SELECT *
FROM (SELECT year, oil_consumption, `3-year oil_consumption average`, 
`3-year oil_consumption average` - LAG(`3-year oil_consumption average`) OVER (ORDER BY year) as moving_difference,
gdp, `3-year gdp average`
FROM (SELECT year, 
oil_consumption, 
AVG(CAST(NULLIF(oil_consumption,0) AS float)) OVER(ORDER BY year
ROWS BETWEEN CURRENT ROW  AND 2 FOLLOWING)
AS '3-year oil_consumption average',
gdp,
AVG(CAST(NULLIF(gdp,0) AS float)) OVER(ORDER BY year
ROWS BETWEEN CURRENT ROW  AND 2 FOLLOWING)
AS '3-year gdp average'
FROM owid_energy_data
WHERE year BETWEEN '1999' AND '2021'
AND country = 'Laos')a
WHERE year BETWEEN '1999' AND '2021')b
WHERE year BETWEEN '2000' AND '2021'
AND moving_difference<0;

#Malaysia
# a) and b) [21 row(s) returned] 
SELECT * 
FROM (SELECT year, oil_consumption, `3-year oil_consumption average`, 
`3-year oil_consumption average` - LAG(`3-year oil_consumption average`) OVER (ORDER BY year) as moving_difference,
gdp, `3-year gdp average`
FROM (SELECT year, 
oil_consumption, 
AVG(CAST(NULLIF(oil_consumption,0) AS float)) OVER(ORDER BY year
ROWS BETWEEN CURRENT ROW  AND 2 FOLLOWING)
AS '3-year oil_consumption average',
gdp,
AVG(CAST(NULLIF(gdp,0) AS float)) OVER(ORDER BY year
ROWS BETWEEN CURRENT ROW  AND 2 FOLLOWING)
AS '3-year gdp average'
FROM owid_energy_data
WHERE year BETWEEN '1999' AND '2021'
AND country = 'Malaysia')a
WHERE year BETWEEN '1999' AND '2021')b
WHERE year BETWEEN '2000' AND '2021';

# c) [7 row(s) returned] 
SELECT *
FROM (SELECT year, oil_consumption, `3-year oil_consumption average`, 
`3-year oil_consumption average` - LAG(`3-year oil_consumption average`) OVER (ORDER BY year) as moving_difference,
gdp, `3-year gdp average`
FROM (SELECT year, 
oil_consumption, 
AVG(CAST(NULLIF(oil_consumption,0) AS float)) OVER(ORDER BY year
ROWS BETWEEN CURRENT ROW  AND 2 FOLLOWING)
AS '3-year oil_consumption average',
gdp,
AVG(CAST(NULLIF(gdp,0) AS float)) OVER(ORDER BY year
ROWS BETWEEN CURRENT ROW  AND 2 FOLLOWING)
AS '3-year gdp average'
FROM owid_energy_data
WHERE year BETWEEN '1999' AND '2021'
AND country = 'Malaysia')a
WHERE year BETWEEN '1999' AND '2021')b
WHERE year BETWEEN '2000' AND '2021'
AND moving_difference<0;

#Myanmar
# a) and b) [21 row(s) returned] 
SELECT * 
FROM (SELECT year, oil_consumption, `3-year oil_consumption average`, 
`3-year oil_consumption average` - LAG(`3-year oil_consumption average`) OVER (ORDER BY year) as moving_difference,
gdp, `3-year gdp average`
FROM (SELECT year, 
oil_consumption, 
AVG(CAST(NULLIF(oil_consumption,0) AS float)) OVER(ORDER BY year
ROWS BETWEEN CURRENT ROW  AND 2 FOLLOWING)
AS '3-year oil_consumption average',
gdp,
AVG(CAST(NULLIF(gdp,0) AS float)) OVER(ORDER BY year
ROWS BETWEEN CURRENT ROW  AND 2 FOLLOWING)
AS '3-year gdp average'
FROM owid_energy_data
WHERE year BETWEEN '1999' AND '2021'
AND country = 'Myanmar')a
WHERE year BETWEEN '1999' AND '2021')b
WHERE year BETWEEN '2000' AND '2021';

# c) [0 row(s) returned] 
SELECT *
FROM (SELECT year, oil_consumption, `3-year oil_consumption average`, 
`3-year oil_consumption average` - LAG(`3-year oil_consumption average`) OVER (ORDER BY year) as moving_difference,
gdp, `3-year gdp average`
FROM (SELECT year, 
oil_consumption, 
AVG(CAST(NULLIF(oil_consumption,0) AS float)) OVER(ORDER BY year
ROWS BETWEEN CURRENT ROW  AND 2 FOLLOWING)
AS '3-year oil_consumption average',
gdp,
AVG(CAST(NULLIF(gdp,0) AS float)) OVER(ORDER BY year
ROWS BETWEEN CURRENT ROW  AND 2 FOLLOWING)
AS '3-year gdp average'
FROM owid_energy_data
WHERE year BETWEEN '1999' AND '2021'
AND country = 'Myanmar')a
WHERE year BETWEEN '1999' AND '2021')b
WHERE year BETWEEN '2000' AND '2021'
AND moving_difference<0;

#Philippines
# a) and b) [22 row(s) returned]
SELECT * 
FROM (SELECT year, oil_consumption, `3-year oil_consumption average`, 
`3-year oil_consumption average` - LAG(`3-year oil_consumption average`) OVER (ORDER BY year) as moving_difference,
gdp, `3-year gdp average`
FROM (SELECT year, 
oil_consumption, 
AVG(CAST(NULLIF(oil_consumption,0) AS float)) OVER(ORDER BY year
ROWS BETWEEN CURRENT ROW  AND 2 FOLLOWING)
AS '3-year oil_consumption average',
gdp,
AVG(CAST(NULLIF(gdp,0) AS float)) OVER(ORDER BY year
ROWS BETWEEN CURRENT ROW  AND 2 FOLLOWING)
AS '3-year gdp average'
FROM owid_energy_data
WHERE year BETWEEN '1999' AND '2021'
AND country = 'Philippines')a
WHERE year BETWEEN '1999' AND '2021')b
WHERE year BETWEEN '2000' AND '2021';

# c) [10 row(s) returned]
SELECT *
FROM (SELECT year, oil_consumption, `3-year oil_consumption average`, 
`3-year oil_consumption average` - LAG(`3-year oil_consumption average`) OVER (ORDER BY year) as moving_difference,
gdp, `3-year gdp average`
FROM (SELECT year, 
oil_consumption, 
AVG(CAST(NULLIF(oil_consumption,0) AS float)) OVER(ORDER BY year
ROWS BETWEEN CURRENT ROW  AND 2 FOLLOWING)
AS '3-year oil_consumption average',
gdp,
AVG(CAST(NULLIF(gdp,0) AS float)) OVER(ORDER BY year
ROWS BETWEEN CURRENT ROW  AND 2 FOLLOWING)
AS '3-year gdp average'
FROM owid_energy_data
WHERE year BETWEEN '1999' AND '2021'
AND country = 'Philippines')a
WHERE year BETWEEN '1999' AND '2021')b
WHERE year BETWEEN '2000' AND '2021'
AND moving_difference<0;

#Singapore
# a) and b) [22 row(s) returned]
SELECT * 
FROM (SELECT year, oil_consumption, `3-year oil_consumption average`, 
`3-year oil_consumption average` - LAG(`3-year oil_consumption average`) OVER (ORDER BY year) as moving_difference,
gdp, `3-year gdp average`
FROM (SELECT year, 
oil_consumption, 
AVG(CAST(NULLIF(oil_consumption,0) AS float)) OVER(ORDER BY year
ROWS BETWEEN CURRENT ROW  AND 2 FOLLOWING)
AS '3-year oil_consumption average',
gdp,
AVG(CAST(NULLIF(gdp,0) AS float)) OVER(ORDER BY year
ROWS BETWEEN CURRENT ROW  AND 2 FOLLOWING)
AS '3-year gdp average'
FROM owid_energy_data
WHERE year BETWEEN '1999' AND '2021'
AND country = 'Singapore')a
WHERE year BETWEEN '1999' AND '2021')b
WHERE year BETWEEN '2000' AND '2021';

# c) [4 row(s) returned] 
SELECT *
FROM (SELECT year, oil_consumption, `3-year oil_consumption average`, 
`3-year oil_consumption average` - LAG(`3-year oil_consumption average`) OVER (ORDER BY year) as moving_difference,
gdp, `3-year gdp average`
FROM (SELECT year, 
oil_consumption, 
AVG(CAST(NULLIF(oil_consumption,0) AS float)) OVER(ORDER BY year
ROWS BETWEEN CURRENT ROW  AND 2 FOLLOWING)
AS '3-year oil_consumption average',
gdp,
AVG(CAST(NULLIF(gdp,0) AS float)) OVER(ORDER BY year
ROWS BETWEEN CURRENT ROW  AND 2 FOLLOWING)
AS '3-year gdp average'
FROM owid_energy_data
WHERE year BETWEEN '1999' AND '2021'
AND country = 'Singapore')a
WHERE year BETWEEN '1999' AND '2021')b
WHERE year BETWEEN '2000' AND '2021'
AND moving_difference<0;

#Thailand
# a) and b) [22 row(s) returned]
SELECT * 
FROM (SELECT year, oil_consumption, `3-year oil_consumption average`, 
`3-year oil_consumption average` - LAG(`3-year oil_consumption average`) OVER (ORDER BY year) as moving_difference,
gdp, `3-year gdp average`
FROM (SELECT year, 
oil_consumption, 
AVG(CAST(NULLIF(oil_consumption,0) AS float)) OVER(ORDER BY year
ROWS BETWEEN CURRENT ROW  AND 2 FOLLOWING)
AS '3-year oil_consumption average',
gdp,
AVG(CAST(NULLIF(gdp,0) AS float)) OVER(ORDER BY year
ROWS BETWEEN CURRENT ROW  AND 2 FOLLOWING)
AS '3-year gdp average'
FROM owid_energy_data
WHERE year BETWEEN '1999' AND '2021'
AND country = 'Thailand')a
WHERE year BETWEEN '1999' AND '2021')b
WHERE year BETWEEN '2000' AND '2021';

# c) [5 row(s) returned] 
SELECT *
FROM (SELECT year, oil_consumption, `3-year oil_consumption average`, 
`3-year oil_consumption average` - LAG(`3-year oil_consumption average`) OVER (ORDER BY year) as moving_difference,
gdp, `3-year gdp average`
FROM (SELECT year, 
oil_consumption, 
AVG(CAST(NULLIF(oil_consumption,0) AS float)) OVER(ORDER BY year
ROWS BETWEEN CURRENT ROW  AND 2 FOLLOWING)
AS '3-year oil_consumption average',
gdp,
AVG(CAST(NULLIF(gdp,0) AS float)) OVER(ORDER BY year
ROWS BETWEEN CURRENT ROW  AND 2 FOLLOWING)
AS '3-year gdp average'
FROM owid_energy_data
WHERE year BETWEEN '1999' AND '2021'
AND country = 'Thailand')a
WHERE year BETWEEN '1999' AND '2021')b
WHERE year BETWEEN '2000' AND '2021'
AND moving_difference<0;

#Vietnam
# a) and b) [22 row(s) returned]
SELECT * 
FROM (SELECT year, oil_consumption, `3-year oil_consumption average`, 
`3-year oil_consumption average` - LAG(`3-year oil_consumption average`) OVER (ORDER BY year) as moving_difference,
gdp, `3-year gdp average`
FROM (SELECT year, 
oil_consumption, 
AVG(CAST(NULLIF(oil_consumption,0) AS float)) OVER(ORDER BY year
ROWS BETWEEN CURRENT ROW  AND 2 FOLLOWING)
AS '3-year oil_consumption average',
gdp,
AVG(CAST(NULLIF(gdp,0) AS float)) OVER(ORDER BY year
ROWS BETWEEN CURRENT ROW  AND 2 FOLLOWING)
AS '3-year gdp average'
FROM owid_energy_data
WHERE year BETWEEN '1999' AND '2021'
AND country = 'Vietnam')a
WHERE year BETWEEN '1999' AND '2021')b
WHERE year BETWEEN '2000' AND '2021';

# c)[1 row(s) returned]
SELECT *
FROM (SELECT year, oil_consumption, `3-year oil_consumption average`, 
`3-year oil_consumption average` - LAG(`3-year oil_consumption average`) OVER (ORDER BY year) as moving_difference,
gdp, `3-year gdp average`
FROM (SELECT year, 
oil_consumption, 
AVG(CAST(NULLIF(oil_consumption,0) AS float)) OVER(ORDER BY year
ROWS BETWEEN CURRENT ROW  AND 2 FOLLOWING)
AS '3-year oil_consumption average',
gdp,
AVG(CAST(NULLIF(gdp,0) AS float)) OVER(ORDER BY year
ROWS BETWEEN CURRENT ROW  AND 2 FOLLOWING)
AS '3-year gdp average'
FROM owid_energy_data
WHERE year BETWEEN '1999' AND '2021'
AND country = 'Vietnam')a
WHERE year BETWEEN '1999' AND '2021')b
WHERE year BETWEEN '2000' AND '2021'
AND moving_difference<0;

/*
Question 6 (DONE)
For each <energy_products> and <sub_products>, display the overall average of 
<value_ktoe> from [importsofenergyproducts] and [exportsofenergyproducts].
*/

#Answer [12 rows returned] 
SELECT energy_products, sub_products, avg(value_ktoe)
FROM
(SELECT * FROM exportsofenergyproducts
UNION
SELECT * FROM importsofenergyproducts)a
GROUP BY energy_products, sub_products;

/*
Question 7
a) For each combination of <energy_products> and <sub_products>, find the yearly 
difference in <value_ktoe> from [importsofenergyproducts] and 
[exportsofenergyproducts]. 
b) Identify those years where more than 4 instances of 
export value > import value can be detected.
*/

# Answer
#a) [192 row(s) returned]
SELECT a.year, a.energy_products, a.sub_products, (b.value_ktoe - a.value_ktoe) AS difference
FROM importsofenergyproducts a LEFT JOIN exportsofenergyproducts b
ON a.year = b.year
AND a.energy_products = b.energy_products
AND a.sub_products = b.sub_products; 

#b) [1 row(s) returned]
SELECT year, COUNT(difference) as difference
FROM (SELECT a.year, a.energy_products, a.sub_products, (b.value_ktoe - a.value_ktoe) AS difference
FROM importsofenergyproducts a LEFT JOIN exportsofenergyproducts b
ON a.year = b.year
AND a.energy_products = b.energy_products
AND a.sub_products = b.sub_products
AND (b.value_ktoe - a.value_ktoe) > 0) a
GROUP BY year
HAVING COUNT(difference)>4;

/* 
Question 8 (DONE)
In [householdelectricityconsumption], for each <region>, excluding “overall”, 
generate the yearly average <kwh_per_acc>.
*/

# Answer [85 row(s) returned]
SELECT Region, year, AVG(kwh_per_acc) AS 'yearly_average'
FROM householdelectricityconsumption
WHERE Region != 'Overall' AND month != 'Annual'
AND kwh_per_acc != 's\r'
GROUP BY Region, year;

/*
Question 9 (DONE) 
Who are the energy-saving stars? 
a) Compute the yearly average of <kwh_per_acc> in each region, excluding “overall”. 
b) Generate the moving 2-year average difference (i.e.,
year 1 average kwh_per_acc for the central region = 1223, year 2 = 1000, the 
moving 2-year average difference = -223). 
c) Display the top 3 regions with the most instances of negative 2-year averages.
*/

#Answer 
# a) [85 row(s) returned]
SELECT Region, year, AVG(kwh_per_acc) 
FROM householdelectricityconsumption
WHERE Region != 'Overall' AND month != 'Annual'
AND kwh_per_acc != 's\r'
GROUP BY Region, year;

# b) [85 row(s) returned]
SELECT Region, year, AVG(kwh_per_acc) AS average,
LAG(AVG(kwh_per_acc)) OVER (PARTITION BY Region ORDER BY year) AS previous_average,
AVG(kwh_per_acc) - LAG(AVG(kwh_per_acc)) OVER (PARTITION BY Region ORDER BY year)  AS moving_difference
FROM householdelectricityconsumption
WHERE Region != 'Overall' AND month != 'Annual'
AND kwh_per_acc != 's\r'
GROUP BY Region, year;

# c) [3 row(s) returned] 
SELECT Region,COUNT(moving_difference) as 'negative 2-year averages'
FROM (SELECT Region, year, AVG(kwh_per_acc) AS average,
LAG(AVG(kwh_per_acc)) OVER (PARTITION BY Region ORDER BY year) AS previous_average,
AVG(kwh_per_acc) - LAG(AVG(kwh_per_acc)) OVER (PARTITION BY Region ORDER BY year)  AS moving_difference
FROM householdelectricityconsumption
WHERE Region != 'Overall' 
AND month != 'Annual'
AND kwh_per_acc NOT LIKE '%s%'
GROUP BY Region, year)a
WHERE moving_difference<0
GROUP BY Region
ORDER BY COUNT(moving_difference) DESC
LIMIT 3;

/*
Question 10
Are there any seasonal (quarterly) effects on energy consumption? Visualizations are 
typically required to eyeball the effects. For each region, in each year, compute the 
quarterly average in <kwh_per_acc>. Exclude “Overall” in <region>.
Note: 1st quarter = January, February, and March, 2nd quarter = April, May, and June, 
and so on.
*/

# Answer [85 row(s) returned]
SELECT a.Region, a.year, first_quarter, second_quarter, third_quarter, fourth_quarter
FROM(
SELECT Region, year, AVG(kwh_per_acc) AS first_quarter
FROM householdelectricityconsumption
WHERE Region != 'Overall' 
AND month != 'Annual'
AND month IN ('1','2','3')
AND kwh_per_acc != 's\r'
GROUP BY Region, year) a 
LEFT JOIN
(SELECT Region, year, AVG(kwh_per_acc) AS second_quarter
FROM householdelectricityconsumption
WHERE Region != 'Overall' 
AND month != 'Annual'
AND month IN ('4','5','6')
AND kwh_per_acc != 's\r'
GROUP BY Region, year) b ON a.Region = b.Region AND a.year = b.year
LEFT JOIN
(SELECT Region, year, AVG(kwh_per_acc) AS third_quarter
FROM householdelectricityconsumption
WHERE Region != 'Overall' 
AND month != 'Annual'
AND month IN ('7','8','9')
AND kwh_per_acc != 's\r'
GROUP BY Region, year) c ON b.Region = c.Region AND b.year = c.year
LEFT JOIN
(SELECT Region, year, AVG(kwh_per_acc) AS fourth_quarter
FROM householdelectricityconsumption
WHERE Region != 'Overall' 
AND month != 'Annual'
AND month IN ('10','11','12')
AND kwh_per_acc != 's\r'
GROUP BY Region, year) d ON c.Region = d.Region AND c.year = d.year
ORDER BY a.Region, a.year;

/*
Question 11
Consider [householdtowngasconsumption]. Are there any seasonal (quarterly) effects 
on town gas consumption? For each <sub_housing_type>, in each year, compute the 
quarterly average in <avg_mthly_hh_tg_consp_kwh>. Exclude “Overall” in < 
sub_housing_type>.
*/

#Answer [136 row(s) returned] 
SELECT a.sub_housing_type, a.year, first_quarter, second_quarter, third_quarter, fourth_quarter
FROM(SELECT sub_housing_type, year, AVG(avg_mthly_hh_tg_consp_kwh) AS first_quarter
FROM householdtowngasconsumption
WHERE sub_housing_type != 'Overall' 
AND month != 'Annual'
AND month IN ('1','2','3')
GROUP BY sub_housing_type, year)a 
LEFT JOIN
(SELECT sub_housing_type, year, AVG(avg_mthly_hh_tg_consp_kwh) AS second_quarter
FROM householdtowngasconsumption
WHERE sub_housing_type != 'Overall' 
AND month != 'Annual'
AND month IN ('4','5','6')
GROUP BY sub_housing_type, year)b ON a.sub_housing_type = b.sub_housing_type AND a.year = b.year
LEFT JOIN
(SELECT sub_housing_type, year, AVG(avg_mthly_hh_tg_consp_kwh) AS third_quarter
FROM householdtowngasconsumption
WHERE sub_housing_type != 'Overall' 
AND month != 'Annual'
AND month IN ('7','8','9')
GROUP BY sub_housing_type, year)c ON b.sub_housing_type = c.sub_housing_type AND b.year = c.year
LEFT JOIN
(SELECT sub_housing_type, year, AVG(avg_mthly_hh_tg_consp_kwh) AS fourth_quarter
FROM householdtowngasconsumption
WHERE sub_housing_type != 'Overall' 
AND month != 'Annual'
AND month IN ('10','11','12')
GROUP BY sub_housing_type, year)d ON c.sub_housing_type = d.sub_housing_type AND c.year = d.year
ORDER BY a.sub_housing_type, a.year;

/*
Question 12
*Open-ended question* 
How has Singapore been performing in terms of energy consumption? 
Find a comparable reference(s) to illustrate changes in energy per capita, energy per GDP, 
and various types of energy (e.g., solar, gas, and oil) over the years.
*/
# 1965-1974
#Population 
(SELECT country, AVG(population) AS avg_population
FROM owid_energy_data
WHERE year between 1965 AND 1974
AND population != ''
GROUP BY country
HAVING AVG(population)>(SELECT AVG(population)
FROM owid_energy_data
where country = 'Singapore'
AND year between 1965 AND 1974)
ORDER BY AVG(population) ASC
LIMIT 5)
UNION
(SELECT country, AVG(population) AS avg_population
FROM owid_energy_data
WHERE year between 1965 AND 1974
AND population != ''
GROUP BY country
HAVING AVG(population)<=(SELECT AVG(population)
FROM owid_energy_data
where country = 'Singapore'
AND year between 1965 AND 1974)
ORDER BY AVG(population) DESC
LIMIT 6)
ORDER BY avg_population DESC;

#GDP 
(SELECT country, AVG(population) AS avg_population, AVG(gdp) AS avg_gdp
FROM owid_energy_data
WHERE year between 1965 AND 1974
AND gdp != ''
GROUP BY country
HAVING AVG(gdp)>(SELECT AVG(gdp)
FROM owid_energy_data
where country = 'Singapore'
AND year between 1965 AND 1974)
ORDER BY AVG(gdp) ASC
LIMIT 5)
UNION
(SELECT country, AVG(population) AS avg_population, AVG(gdp) AS avg_gdp
FROM owid_energy_data
WHERE year between 1965 AND 1974
AND gdp != ''
GROUP BY country
HAVING AVG(gdp)<=(SELECT AVG(gdp)
FROM owid_energy_data
where country = 'Singapore'
AND year between 1965 AND 1974)
ORDER BY AVG(gdp) DESC
LIMIT 6)
ORDER BY avg_gdp DESC;

#GDP per Capita
(SELECT country, AVG(gdp) AS avg_gdp, AVG(population) AS avg_population, AVG(gdp/population) AS avg_gdp_per_capita
FROM owid_energy_data
WHERE year between 1965 AND 1974
AND population != ''
AND gdp != ''
GROUP BY country
HAVING AVG(gdp/population)>(SELECT AVG(gdp/population)
FROM owid_energy_data
where country = 'Singapore'
AND year between 1965 AND 1974)
ORDER BY AVG(gdp/population) ASC
LIMIT 5)
UNION
(SELECT country, AVG(gdp) AS avg_gdp, AVG(population) AS avg_population, AVG(gdp/population) AS avg_gdp_per_capita
FROM owid_energy_data
WHERE year between 1965 AND 1974
AND population != ''
AND gdp != ''
GROUP BY country
HAVING AVG(gdp/population)<=(SELECT AVG(gdp/population)
FROM owid_energy_data
where country = 'Singapore'
AND year between 1965 AND 1974)
ORDER BY AVG(gdp/population) DESC
LIMIT 6)
ORDER BY avg_gdp_per_capita DESC;

# 1975-1984
#Population 
(SELECT country, AVG(population) AS avg_population, AVG(gdp) AS avg_gdp
FROM owid_energy_data
WHERE year between 1975 AND 1984
AND population != ''
GROUP BY country
HAVING AVG(population)>(SELECT AVG(population)
FROM owid_energy_data
where country = 'Singapore'
AND year between 1975 AND 1984)
ORDER BY AVG(population) ASC
LIMIT 5)
UNION
(SELECT country, AVG(population) AS avg_population, AVG(gdp) AS avg_gdp
FROM owid_energy_data
WHERE year between 1975 AND 1984
AND population != ''
GROUP BY country
HAVING AVG(population)<=(SELECT AVG(population)
FROM owid_energy_data
where country = 'Singapore'
AND year between 1975 AND 1984)
ORDER BY AVG(population) DESC
LIMIT 6)
ORDER BY avg_population DESC;

#GDP 
(SELECT country, AVG(population) AS avg_population, AVG(gdp) AS avg_gdp
FROM owid_energy_data
WHERE year between 1975 AND 1984
AND gdp != ''
GROUP BY country
HAVING AVG(gdp)>(SELECT AVG(gdp)
FROM owid_energy_data
where country = 'Singapore'
AND year between 1975 AND 1984)
ORDER BY AVG(gdp) ASC
LIMIT 5)
UNION
(SELECT country, AVG(population) AS avg_population, AVG(gdp) AS avg_gdp
FROM owid_energy_data
WHERE year between 1975 AND 1984
AND gdp != ''
GROUP BY country
HAVING AVG(gdp)<=(SELECT AVG(gdp)
FROM owid_energy_data
where country = 'Singapore'
AND year between 1975 AND 1984)
ORDER BY AVG(gdp) DESC
LIMIT 6)
ORDER BY avg_gdp DESC;

#GDP per Capita
(SELECT country, AVG(gdp) AS avg_gdp, AVG(population) AS avg_population, AVG(gdp/population) AS avg_gdp_per_capita
FROM owid_energy_data
WHERE year between 1975 AND 1984
AND population != ''
AND gdp != ''
GROUP BY country
HAVING AVG(gdp/population)>(SELECT AVG(gdp/population)
FROM owid_energy_data
where country = 'Singapore'
AND year between 1975 AND 1984)
ORDER BY AVG(gdp/population) ASC
LIMIT 5)
UNION
(SELECT country, AVG(gdp) AS avg_gdp, AVG(population) AS avg_population, AVG(gdp/population) AS avg_gdp_per_capita
FROM owid_energy_data
WHERE year between 1975 AND 1984
AND population != ''
AND gdp != ''
GROUP BY country
HAVING AVG(gdp/population)<=(SELECT AVG(gdp/population)
FROM owid_energy_data
where country = 'Singapore'
AND year between 1975 AND 1984)
ORDER BY AVG(gdp/population) DESC
LIMIT 6)
ORDER BY avg_gdp_per_capita DESC;

# 1985-1994
#Population 
(SELECT country, AVG(population) AS avg_population, AVG(gdp) AS avg_gdp
FROM owid_energy_data
WHERE year between 1985 AND 1994
AND population != ''
GROUP BY country
HAVING AVG(population)>(SELECT AVG(population)
FROM owid_energy_data
where country = 'Singapore'
AND year between 1985 AND 1994)
ORDER BY AVG(population) ASC
LIMIT 5)
UNION
(SELECT country, AVG(population) AS avg_population, AVG(gdp) AS avg_gdp
FROM owid_energy_data
WHERE year between 1985 AND 1994
AND population != ''
GROUP BY country
HAVING AVG(population)<=(SELECT AVG(population)
FROM owid_energy_data
where country = 'Singapore'
AND year between 1985 AND 1994)
ORDER BY AVG(population) DESC
LIMIT 6)
ORDER BY avg_population DESC;

#GDP 
(SELECT country, AVG(population) AS avg_population, AVG(gdp) AS avg_gdp
FROM owid_energy_data
WHERE year between 1985 AND 1994
AND gdp != ''
GROUP BY country
HAVING AVG(gdp)>(SELECT AVG(gdp)
FROM owid_energy_data
where country = 'Singapore'
AND year between 1985 AND 1994)
ORDER BY AVG(gdp) ASC
LIMIT 5)
UNION
(SELECT country, AVG(population) AS avg_population, AVG(gdp) AS avg_gdp
FROM owid_energy_data
WHERE year between 1985 AND 1994
AND gdp != ''
GROUP BY country
HAVING AVG(gdp)<=(SELECT AVG(gdp)
FROM owid_energy_data
where country = 'Singapore'
AND year between 1985 AND 1994)
ORDER BY AVG(gdp) DESC
LIMIT 6)
ORDER BY avg_gdp DESC;

#GDP per Capita
(SELECT country, AVG(gdp) AS avg_gdp, AVG(population) AS avg_population, AVG(gdp/population) AS avg_gdp_per_capita
FROM owid_energy_data
WHERE year between 1985 AND 1994
AND population != ''
AND gdp != ''
GROUP BY country
HAVING AVG(gdp/population)>(SELECT AVG(gdp/population)
FROM owid_energy_data
where country = 'Singapore'
AND year between 1985 AND 1994)
ORDER BY AVG(gdp/population) ASC
LIMIT 5)
UNION
(SELECT country, AVG(gdp) AS avg_gdp, AVG(population) AS avg_population, AVG(gdp/population) AS avg_gdp_per_capita
FROM owid_energy_data
WHERE year between 1985 AND 1994
AND population != ''
AND gdp != ''
GROUP BY country
HAVING AVG(gdp/population)<=(SELECT AVG(gdp/population)
FROM owid_energy_data
where country = 'Singapore'
AND year between 1985 AND 1994)
ORDER BY AVG(gdp/population) DESC
LIMIT 6)
ORDER BY avg_gdp_per_capita DESC;

# 1995-2004
#Population 
(SELECT country, AVG(population) AS avg_population, AVG(gdp) AS avg_gdp
FROM owid_energy_data
WHERE year between 1995 AND 2004
AND population != ''
GROUP BY country
HAVING AVG(population)>(SELECT AVG(population)
FROM owid_energy_data
where country = 'Singapore'
AND year between 1995 AND 2004)
ORDER BY AVG(population) ASC
LIMIT 5)
UNION
(SELECT country, AVG(population) AS avg_population, AVG(gdp) AS avg_gdp
FROM owid_energy_data
WHERE year between 1995 AND 2004
AND population != ''
GROUP BY country
HAVING AVG(population)<=(SELECT AVG(population)
FROM owid_energy_data
where country = 'Singapore'
AND year between 1995 AND 2004)
ORDER BY AVG(population) DESC
LIMIT 6)
ORDER BY avg_population DESC;

#GDP 
(SELECT country, AVG(population) AS avg_population, AVG(gdp) AS avg_gdp
FROM owid_energy_data
WHERE year between 1995 AND 2004
AND gdp != ''
GROUP BY country
HAVING AVG(gdp)>(SELECT AVG(gdp)
FROM owid_energy_data
where country = 'Singapore'
AND year between 1995 AND 2004)
ORDER BY AVG(gdp) ASC
LIMIT 5)
UNION
(SELECT country, AVG(population) AS avg_population, AVG(gdp) AS avg_gdp
FROM owid_energy_data
WHERE year between 1995 AND 2004
AND gdp != ''
GROUP BY country
HAVING AVG(gdp)<=(SELECT AVG(gdp)
FROM owid_energy_data
where country = 'Singapore'
AND year between 1995 AND 2004)
ORDER BY AVG(gdp) DESC
LIMIT 6)
ORDER BY avg_gdp DESC;

#GDP per Capita
(SELECT country, AVG(gdp) AS avg_gdp, AVG(population) AS avg_population, AVG(gdp/population) AS avg_gdp_per_capita
FROM owid_energy_data
WHERE year between 1995 AND 2004
AND population != ''
AND gdp != ''
GROUP BY country
HAVING AVG(gdp/population)>(SELECT AVG(gdp/population)
FROM owid_energy_data
where country = 'Singapore'
AND year between 1995 AND 2004)
ORDER BY AVG(gdp/population) ASC
LIMIT 5)
UNION
(SELECT country, AVG(gdp) AS avg_gdp, AVG(population) AS avg_population, AVG(gdp/population) AS avg_gdp_per_capita
FROM owid_energy_data
WHERE year between 1995 AND 2004
AND population != ''
AND gdp != ''
GROUP BY country
HAVING AVG(gdp/population)<=(SELECT AVG(gdp/population)
FROM owid_energy_data
where country = 'Singapore'
AND year between 1995 AND 2004)
ORDER BY AVG(gdp/population) DESC
LIMIT 6)
ORDER BY avg_gdp_per_capita DESC;

# 2005-2014
#Population 
(SELECT country, AVG(population) AS avg_population, AVG(gdp) AS avg_gdp
FROM owid_energy_data
WHERE year between 2005 AND 2014
AND population != ''
GROUP BY country
HAVING AVG(population)>(SELECT AVG(population)
FROM owid_energy_data
where country = 'Singapore'
AND year between 2005 AND 2014)
ORDER BY AVG(population) ASC
LIMIT 5)
UNION
(SELECT country, AVG(population) AS avg_population, AVG(gdp) AS avg_gdp
FROM owid_energy_data
WHERE year between 2005 AND 2014
AND population != ''
GROUP BY country
HAVING AVG(population)<=(SELECT AVG(population)
FROM owid_energy_data
where country = 'Singapore'
AND year between 2005 AND 2014)
ORDER BY AVG(population) DESC
LIMIT 6)
ORDER BY avg_population DESC;

#GDP 
(SELECT country, AVG(population) AS avg_population, AVG(gdp) AS avg_gdp
FROM owid_energy_data
WHERE year between 2005 AND 2014
AND gdp != ''
GROUP BY country
HAVING AVG(gdp)>(SELECT AVG(gdp)
FROM owid_energy_data
where country = 'Singapore'
AND year between 2005 AND 2014)
ORDER BY AVG(gdp) ASC
LIMIT 5)
UNION
(SELECT country, AVG(population) AS avg_population, AVG(gdp) AS avg_gdp
FROM owid_energy_data
WHERE year between 2005 AND 2014
AND gdp != ''
GROUP BY country
HAVING AVG(gdp)<=(SELECT AVG(gdp)
FROM owid_energy_data
where country = 'Singapore'
AND year between 2005 AND 2014)
ORDER BY AVG(gdp) DESC
LIMIT 6)
ORDER BY avg_gdp DESC;

#GDP per Capita
(SELECT country, AVG(gdp) AS avg_gdp, AVG(population) AS avg_population, AVG(gdp/population) AS avg_gdp_per_capita
FROM owid_energy_data
WHERE year between 2005 AND 2014
AND population != ''
AND gdp != ''
GROUP BY country
HAVING AVG(gdp/population)>(SELECT AVG(gdp/population)
FROM owid_energy_data
where country = 'Singapore'
AND year between 2005 AND 2014)
ORDER BY AVG(gdp/population) ASC
LIMIT 5)
UNION
(SELECT country, AVG(gdp) AS avg_gdp, AVG(population) AS avg_population, AVG(gdp/population) AS avg_gdp_per_capita
FROM owid_energy_data
WHERE year between 2005 AND 2014
AND population != ''
AND gdp != ''
GROUP BY country
HAVING AVG(gdp/population)<=(SELECT AVG(gdp/population)
FROM owid_energy_data
where country = 'Singapore'
AND year between 2005 AND 2014)
ORDER BY AVG(gdp/population) DESC
LIMIT 6)
ORDER BY avg_gdp_per_capita DESC;

# 2015-2021
SELECT country, AVG(population) AS sing_population, AVG(CAST(NULLIF(gdp,0) AS float)) AS sing_gdp
FROM owid_energy_data
where country = 'Singapore'
AND year between 2015 AND 2021;

#Population 
(SELECT country, AVG(population) AS avg_population, AVG(gdp) AS avg_gdp
FROM owid_energy_data
WHERE year between 2015 AND 2021
AND population != ''
GROUP BY country
HAVING AVG(population)>(SELECT AVG(population)
FROM owid_energy_data
where country = 'Singapore'
AND year between 2015 AND 2021)
ORDER BY AVG(population) ASC
LIMIT 5)
UNION
(SELECT country, AVG(population) AS avg_population, AVG(gdp) AS avg_gdp
FROM owid_energy_data
WHERE year between 2015 AND 2021
AND population != ''
GROUP BY country
HAVING AVG(population)<=(SELECT AVG(population)
FROM owid_energy_data
where country = 'Singapore'
AND year between 2015 AND 2021)
ORDER BY AVG(population) DESC
LIMIT 6)
ORDER BY avg_population DESC;

#GDP 
(SELECT country, AVG(population) AS avg_population, AVG(gdp) AS avg_gdp
FROM owid_energy_data
WHERE year between 2015 AND 2018
AND gdp != ''
GROUP BY country
HAVING AVG(gdp)>(SELECT AVG(gdp)
FROM owid_energy_data
where country = 'Singapore'
AND year between 2015 AND 2018)
ORDER BY AVG(gdp) ASC
LIMIT 5)
UNION
(SELECT country, AVG(population) AS avg_population, AVG(gdp) AS avg_gdp
FROM owid_energy_data
WHERE year between 2015 AND 2018
AND gdp != ''
GROUP BY country
HAVING AVG(gdp)<=(SELECT AVG(gdp)
FROM owid_energy_data
where country = 'Singapore'
AND year between 2015 AND 2018)
ORDER BY AVG(gdp) DESC
LIMIT 6)
ORDER BY avg_gdp DESC;

#GDP per Capita
(SELECT country, AVG(gdp) AS avg_gdp, AVG(population) AS avg_population, AVG(gdp/population) AS avg_gdp_per_capita
FROM owid_energy_data
WHERE year between 2015 AND 2018
AND population != ''
AND gdp != ''
GROUP BY country
HAVING AVG(gdp/population)>(SELECT AVG(gdp/population)
FROM owid_energy_data
where country = 'Singapore'
AND year between 2015 AND 2018)
ORDER BY AVG(gdp/population) ASC
LIMIT 5)
UNION
(SELECT country, AVG(gdp) AS avg_gdp, AVG(population) AS avg_population, AVG(gdp/population) AS avg_gdp_per_capita
FROM owid_energy_data
WHERE year between 2015 AND 2018
AND population != ''
AND gdp != ''
GROUP BY country
HAVING AVG(gdp/population)<=(SELECT AVG(gdp/population)
FROM owid_energy_data
where country = 'Singapore'
AND year between 2015 AND 2018)
ORDER BY AVG(gdp/population) DESC
LIMIT 6)
ORDER BY avg_gdp_per_capita DESC;

#Population
SELECT DISTINCT(country), COUNT(*) 
FROM(
(SELECT country, AVG(population) AS avg_population, AVG(gdp) AS avg_gdp
FROM owid_energy_data
WHERE year between 1965 AND 1974
AND population != ''
GROUP BY country
HAVING AVG(population)>(SELECT AVG(population)
FROM owid_energy_data
where country = 'Singapore'
AND year between 1965 AND 1974)
ORDER BY AVG(population) ASC
LIMIT 5)
UNION
(SELECT country, AVG(population) AS avg_population, AVG(gdp) AS avg_gdp
FROM owid_energy_data
WHERE year between 1965 AND 1974
AND population != ''
GROUP BY country
HAVING AVG(population)<=(SELECT AVG(population)
FROM owid_energy_data
where country = 'Singapore'
AND year between 1965 AND 1974)
ORDER BY AVG(population) DESC
LIMIT 6)
UNION
(SELECT country, AVG(population) AS avg_population, AVG(gdp) AS avg_gdp
FROM owid_energy_data
WHERE year between 1975 AND 1984
AND population != ''
GROUP BY country
HAVING AVG(population)>(SELECT AVG(population)
FROM owid_energy_data
where country = 'Singapore'
AND year between 1975 AND 1984)
ORDER BY AVG(population) ASC
LIMIT 5)
UNION
(SELECT country, AVG(population) AS avg_population, AVG(gdp) AS avg_gdp
FROM owid_energy_data
WHERE year between 1975 AND 1984
AND population != ''
GROUP BY country
HAVING AVG(population)<=(SELECT AVG(population)
FROM owid_energy_data
where country = 'Singapore'
AND year between 1975 AND 1984)
ORDER BY AVG(population) DESC
LIMIT 6)
UNION
(SELECT country, AVG(population) AS avg_population, AVG(gdp) AS avg_gdp
FROM owid_energy_data
WHERE year between 1985 AND 1994
AND population != ''
GROUP BY country
HAVING AVG(population)>(SELECT AVG(population)
FROM owid_energy_data
where country = 'Singapore'
AND year between 1985 AND 1994)
ORDER BY AVG(population) ASC
LIMIT 5)
UNION
(SELECT country, AVG(population) AS avg_population, AVG(gdp) AS avg_gdp
FROM owid_energy_data
WHERE year between 1985 AND 1994
AND population != ''
GROUP BY country
HAVING AVG(population)<=(SELECT AVG(population)
FROM owid_energy_data
where country = 'Singapore'
AND year between 1985 AND 1994)
ORDER BY AVG(population) DESC
LIMIT 6)
UNION
(SELECT country, AVG(population) AS avg_population, AVG(gdp) AS avg_gdp
FROM owid_energy_data
WHERE year between 1995 AND 2004
AND population != ''
GROUP BY country
HAVING AVG(population)>(SELECT AVG(population)
FROM owid_energy_data
where country = 'Singapore'
AND year between 1995 AND 2004)
ORDER BY AVG(population) ASC
LIMIT 5)
UNION
(SELECT country, AVG(population) AS avg_population, AVG(gdp) AS avg_gdp
FROM owid_energy_data
WHERE year between 1995 AND 2004
AND population != ''
GROUP BY country
HAVING AVG(population)<=(SELECT AVG(population)
FROM owid_energy_data
where country = 'Singapore'
AND year between 1995 AND 2004)
ORDER BY AVG(population) DESC
LIMIT 6)
UNION
(SELECT country, AVG(population) AS avg_population, AVG(gdp) AS avg_gdp
FROM owid_energy_data
WHERE year between 2005 AND 2014
AND population != ''
GROUP BY country
HAVING AVG(population)>(SELECT AVG(population)
FROM owid_energy_data
where country = 'Singapore'
AND year between 2005 AND 2014)
ORDER BY AVG(population) ASC
LIMIT 5)
UNION
(SELECT country, AVG(population) AS avg_population, AVG(gdp) AS avg_gdp
FROM owid_energy_data
WHERE year between 2005 AND 2014
AND population != ''
GROUP BY country
HAVING AVG(population)<=(SELECT AVG(population)
FROM owid_energy_data
where country = 'Singapore'
AND year between 2005 AND 2014)
ORDER BY AVG(population) DESC
LIMIT 6)
UNION
(SELECT country, AVG(population) AS avg_population, AVG(gdp) AS avg_gdp
FROM owid_energy_data
WHERE year between 2015 AND 2021
AND population != ''
GROUP BY country
HAVING AVG(population)>(SELECT AVG(population)
FROM owid_energy_data
where country = 'Singapore'
AND year between 2015 AND 2021)
ORDER BY AVG(population) ASC
LIMIT 5)
UNION
(SELECT country, AVG(population) AS avg_population, AVG(gdp) AS avg_gdp
FROM owid_energy_data
WHERE year between 2015 AND 2021
AND population != ''
GROUP BY country
HAVING AVG(population)<=(SELECT AVG(population)
FROM owid_energy_data
where country = 'Singapore'
AND year between 2015 AND 2021)
ORDER BY AVG(population) DESC
LIMIT 6)
)a
GROUP BY country
ORDER BY COUNT(*) DESC;

#GDP
SELECT DISTINCT(country), COUNT(*) 
FROM(
(SELECT country, AVG(population) AS avg_population, AVG(gdp) AS avg_gdp
FROM owid_energy_data
WHERE year between 1965 AND 1974
AND gdp != ''
GROUP BY country
HAVING AVG(gdp)>(SELECT AVG(gdp)
FROM owid_energy_data
where country = 'Singapore'
AND year between 1965 AND 1974)
ORDER BY AVG(gdp) ASC
LIMIT 5)
UNION
(SELECT country, AVG(population) AS avg_population, AVG(gdp) AS avg_gdp
FROM owid_energy_data
WHERE year between 1965 AND 1974
AND gdp != ''
GROUP BY country
HAVING AVG(gdp)<=(SELECT AVG(gdp)
FROM owid_energy_data
where country = 'Singapore'
AND year between 1965 AND 1974)
ORDER BY AVG(gdp) DESC
LIMIT 6)
UNION
(SELECT country, AVG(population) AS avg_population, AVG(gdp) AS avg_gdp
FROM owid_energy_data
WHERE year between 1975 AND 1984
AND gdp != ''
GROUP BY country
HAVING AVG(gdp)>(SELECT AVG(gdp)
FROM owid_energy_data
where country = 'Singapore'
AND year between 1975 AND 1984)
ORDER BY AVG(gdp) ASC
LIMIT 5)
UNION
(SELECT country, AVG(population) AS avg_population, AVG(gdp) AS avg_gdp
FROM owid_energy_data
WHERE year between 1975 AND 1984
AND gdp != ''
GROUP BY country
HAVING AVG(gdp)<=(SELECT AVG(gdp)
FROM owid_energy_data
where country = 'Singapore'
AND year between 1975 AND 1984)
ORDER BY AVG(gdp) DESC
LIMIT 6)
UNION
(SELECT country, AVG(population) AS avg_population, AVG(gdp) AS avg_gdp
FROM owid_energy_data
WHERE year between 1985 AND 1994
AND gdp != ''
GROUP BY country
HAVING AVG(gdp)>(SELECT AVG(gdp)
FROM owid_energy_data
where country = 'Singapore'
AND year between 1985 AND 1994)
ORDER BY AVG(gdp) ASC
LIMIT 5)
UNION
(SELECT country, AVG(population) AS avg_population, AVG(gdp) AS avg_gdp
FROM owid_energy_data
WHERE year between 1985 AND 1994
AND gdp != ''
GROUP BY country
HAVING AVG(gdp)<=(SELECT AVG(gdp)
FROM owid_energy_data
where country = 'Singapore'
AND year between 1985 AND 1994)
ORDER BY AVG(gdp) DESC
LIMIT 6)
UNION
(SELECT country, AVG(population) AS avg_population, AVG(gdp) AS avg_gdp
FROM owid_energy_data
WHERE year between 1995 AND 2004
AND gdp != ''
GROUP BY country
HAVING AVG(gdp)>(SELECT AVG(gdp)
FROM owid_energy_data
where country = 'Singapore'
AND year between 1995 AND 2004)
ORDER BY AVG(gdp) ASC
LIMIT 5)
UNION
(SELECT country, AVG(population) AS avg_population, AVG(gdp) AS avg_gdp
FROM owid_energy_data
WHERE year between 1995 AND 2004
AND gdp != ''
GROUP BY country
HAVING AVG(gdp)<=(SELECT AVG(gdp)
FROM owid_energy_data
where country = 'Singapore'
AND year between 1995 AND 2004)
ORDER BY AVG(gdp) DESC
LIMIT 6)
UNION
(SELECT country, AVG(population) AS avg_population, AVG(gdp) AS avg_gdp
FROM owid_energy_data
WHERE year between 2005 AND 2014
AND gdp != ''
GROUP BY country
HAVING AVG(gdp)>(SELECT AVG(gdp)
FROM owid_energy_data
where country = 'Singapore'
AND year between 2005 AND 2014)
ORDER BY AVG(gdp) ASC
LIMIT 5)
UNION
(SELECT country, AVG(population) AS avg_population, AVG(gdp) AS avg_gdp
FROM owid_energy_data
WHERE year between 2005 AND 2014
AND gdp != ''
GROUP BY country
HAVING AVG(gdp)<=(SELECT AVG(gdp)
FROM owid_energy_data
where country = 'Singapore'
AND year between 2005 AND 2014)
ORDER BY AVG(gdp) DESC
LIMIT 6)
UNION
(SELECT country, AVG(population) AS avg_population, AVG(gdp) AS avg_gdp
FROM owid_energy_data
WHERE year between 2015 AND 2018
AND gdp != ''
GROUP BY country
HAVING AVG(gdp)>(SELECT AVG(gdp)
FROM owid_energy_data
where country = 'Singapore'
AND year between 2015 AND 2018)
ORDER BY AVG(gdp) ASC
LIMIT 5)
UNION
(SELECT country, AVG(population) AS avg_population, AVG(gdp) AS avg_gdp
FROM owid_energy_data
WHERE year between 2015 AND 2018
AND gdp != ''
GROUP BY country
HAVING AVG(gdp)<=(SELECT AVG(gdp)
FROM owid_energy_data
where country = 'Singapore'
AND year between 2015 AND 2018)
ORDER BY AVG(gdp) DESC
LIMIT 6)
)a
GROUP BY country
ORDER BY COUNT(*) DESC;

#GDP per Capita
SELECT DISTINCT(country), COUNT(*)
FROM(
(SELECT country, AVG(gdp) AS avg_gdp, AVG(population) AS avg_population, AVG(gdp/population) AS avg_gdp_per_capita
FROM owid_energy_data
WHERE year between 1965 AND 1974
AND population != ''
AND gdp != ''
GROUP BY country
HAVING AVG(gdp/population)>(SELECT AVG(gdp/population)
FROM owid_energy_data
where country = 'Singapore'
AND year between 1965 AND 1974)
ORDER BY AVG(gdp/population) ASC
LIMIT 5)
UNION
(SELECT country, AVG(gdp) AS avg_gdp, AVG(population) AS avg_population, AVG(gdp/population) AS avg_gdp_per_capita
FROM owid_energy_data
WHERE year between 1965 AND 1974
AND population != ''
AND gdp != ''
GROUP BY country
HAVING AVG(gdp/population)<=(SELECT AVG(gdp/population)
FROM owid_energy_data
where country = 'Singapore'
AND year between 1965 AND 1974)
ORDER BY AVG(gdp/population) DESC
LIMIT 6)
UNION
(SELECT country, AVG(gdp) AS avg_gdp, AVG(population) AS avg_population, AVG(gdp/population) AS avg_gdp_per_capita
FROM owid_energy_data
WHERE year between 1975 AND 1984
AND population != ''
AND gdp != ''
GROUP BY country
HAVING AVG(gdp/population)>(SELECT AVG(gdp/population)
FROM owid_energy_data
where country = 'Singapore'
AND year between 1975 AND 1984)
ORDER BY AVG(gdp/population) ASC
LIMIT 5)
UNION
(SELECT country, AVG(gdp) AS avg_gdp, AVG(population) AS avg_population, AVG(gdp/population) AS avg_gdp_per_capita
FROM owid_energy_data
WHERE year between 1975 AND 1984
AND population != ''
AND gdp != ''
GROUP BY country
HAVING AVG(gdp/population)<=(SELECT AVG(gdp/population)
FROM owid_energy_data
where country = 'Singapore'
AND year between 1975 AND 1984)
ORDER BY AVG(gdp/population) DESC
LIMIT 6)
UNION
(SELECT country, AVG(gdp) AS avg_gdp, AVG(population) AS avg_population, AVG(gdp/population) AS avg_gdp_per_capita
FROM owid_energy_data
WHERE year between 1985 AND 1994
AND population != ''
AND gdp != ''
GROUP BY country
HAVING AVG(gdp/population)>(SELECT AVG(gdp/population)
FROM owid_energy_data
where country = 'Singapore'
AND year between 1985 AND 1994)
ORDER BY AVG(gdp/population) ASC
LIMIT 5)
UNION
(SELECT country, AVG(gdp) AS avg_gdp, AVG(population) AS avg_population, AVG(gdp/population) AS avg_gdp_per_capita
FROM owid_energy_data
WHERE year between 1985 AND 1994
AND population != ''
AND gdp != ''
GROUP BY country
HAVING AVG(gdp/population)<=(SELECT AVG(gdp/population)
FROM owid_energy_data
where country = 'Singapore'
AND year between 1985 AND 1994)
ORDER BY AVG(gdp/population) DESC
LIMIT 6)
UNION
(SELECT country, AVG(gdp) AS avg_gdp, AVG(population) AS avg_population, AVG(gdp/population) AS avg_gdp_per_capita
FROM owid_energy_data
WHERE year between 1995 AND 2004
AND population != ''
AND gdp != ''
GROUP BY country
HAVING AVG(gdp/population)>(SELECT AVG(gdp/population)
FROM owid_energy_data
where country = 'Singapore'
AND year between 1995 AND 2004)
ORDER BY AVG(gdp/population) ASC
LIMIT 5)
UNION
(SELECT country, AVG(gdp) AS avg_gdp, AVG(population) AS avg_population, AVG(gdp/population) AS avg_gdp_per_capita
FROM owid_energy_data
WHERE year between 1995 AND 2004
AND population != ''
AND gdp != ''
GROUP BY country
HAVING AVG(gdp/population)<=(SELECT AVG(gdp/population)
FROM owid_energy_data
where country = 'Singapore'
AND year between 1995 AND 2004)
ORDER BY AVG(gdp/population) DESC
LIMIT 6)
UNION
(SELECT country, AVG(gdp) AS avg_gdp, AVG(population) AS avg_population, AVG(gdp/population) AS avg_gdp_per_capita
FROM owid_energy_data
WHERE year between 2005 AND 2014
AND population != ''
AND gdp != ''
GROUP BY country
HAVING AVG(gdp/population)>(SELECT AVG(gdp/population)
FROM owid_energy_data
where country = 'Singapore'
AND year between 2005 AND 2014)
ORDER BY AVG(gdp/population) ASC
LIMIT 5)
UNION
(SELECT country, AVG(gdp) AS avg_gdp, AVG(population) AS avg_population, AVG(gdp/population) AS avg_gdp_per_capita
FROM owid_energy_data
WHERE year between 2005 AND 2014
AND population != ''
AND gdp != ''
GROUP BY country
HAVING AVG(gdp/population)<=(SELECT AVG(gdp/population)
FROM owid_energy_data
where country = 'Singapore'
AND year between 2005 AND 2014)
ORDER BY AVG(gdp/population) DESC
LIMIT 6)
UNION
(SELECT country, AVG(gdp) AS avg_gdp, AVG(population) AS avg_population, AVG(gdp/population) AS avg_gdp_per_capita
FROM owid_energy_data
WHERE year between 2015 AND 2018
AND population != ''
AND gdp != ''
GROUP BY country
HAVING AVG(gdp/population)>(SELECT AVG(gdp/population)
FROM owid_energy_data
where country = 'Singapore'
AND year between 2015 AND 2018)
ORDER BY AVG(gdp/population) ASC
LIMIT 5)
UNION
(SELECT country, AVG(gdp) AS avg_gdp, AVG(population) AS avg_population, AVG(gdp/population) AS avg_gdp_per_capita
FROM owid_energy_data
WHERE year between 2015 AND 2018
AND population != ''
AND gdp != ''
GROUP BY country
HAVING AVG(gdp/population)<=(SELECT AVG(gdp/population)
FROM owid_energy_data
where country = 'Singapore'
AND year between 2015 AND 2018)
ORDER BY AVG(gdp/population) DESC
LIMIT 6)
)a
GROUP BY country
ORDER by COUNT(*) DESC;

#energy per capita, energy per GDP, and various types of energy (e.g. solar, gas, and oil) 
SELECT country, year, population, gdp, (CAST(NULLIF(gdp/population,0) AS float)) AS gdp_per_capita, primary_energy_consumption,  energy_per_capita, energy_per_gdp, 
coal_cons_per_capita, coal_consumption, coal_share_energy, 
gas_energy_per_capita, gas_consumption, gas_share_energy,
oil_energy_per_capita, oil_consumption, oil_share_energy,
other_renewables_energy_per_capita, other_renewable_consumption, other_renewables_share_energy,
biofuel_cons_per_capita, biofuel_consumption, biofuel_share_energy,
hydro_energy_per_capita, hydro_consumption, hydro_share_energy,
solar_energy_per_capita, solar_consumption, solar_share_energy,
wind_energy_per_capita, wind_consumption, wind_share_energy
FROM owid_energy_data
WHERE country in ('Singapore', 'Lebanon', 'Costa Rica')
AND year BETWEEN 1965 AND 2021;

SELECT country,  year, population, gdp, (CAST(NULLIF(gdp/population,0) AS float)) AS gdp_per_capita, primary_energy_consumption,  energy_per_capita, energy_per_gdp, 
coal_cons_per_capita, coal_consumption, coal_share_energy, 
gas_energy_per_capita, gas_consumption, gas_share_energy,
oil_energy_per_capita, oil_consumption, oil_share_energy,
other_renewables_energy_per_capita, other_renewable_consumption, other_renewables_share_energy,
biofuel_cons_per_capita, biofuel_consumption, biofuel_share_energy,
hydro_energy_per_capita, hydro_consumption, hydro_share_energy,
solar_energy_per_capita, solar_consumption, solar_share_energy,
wind_energy_per_capita, wind_consumption, wind_share_energy
FROM owid_energy_data
WHERE country in ('Singapore', 'Peru', 'Kazakhstan')
AND year BETWEEN 1965 AND 2021;

SELECT country,  year, population, gdp, (CAST(NULLIF(gdp/population,0) AS float)) AS gdp_per_capita, primary_energy_consumption,  energy_per_capita, energy_per_gdp, 
coal_cons_per_capita, coal_consumption, coal_share_energy, 
gas_energy_per_capita, gas_consumption, gas_share_energy,
oil_energy_per_capita, oil_consumption, oil_share_energy,
other_renewables_energy_per_capita, other_renewable_consumption, other_renewables_share_energy,
biofuel_cons_per_capita, biofuel_consumption, biofuel_share_energy,
hydro_energy_per_capita, hydro_consumption, hydro_share_energy,
solar_energy_per_capita, solar_consumption, solar_share_energy,
wind_energy_per_capita, wind_consumption, wind_share_energy
FROM owid_energy_data
WHERE country in ('Singapore', 'Ireland', 'United States')
AND year BETWEEN 1965 AND 2021; 


/*
Question 13
*Open-ended question* 
Can renewable energy adequately power continued economic growth?
*/

#Find countries with highest maximum renewables share energy from 2000 [217 row(s) returned] 
SELECT country, max(CAST(renewables_share_energy AS float)) AS 'maximum_renewables_share_energy'
FROM cleaned_owid_energy_data 
WHERE year>=2000
GROUP BY country
ORDER BY max(CAST(renewables_share_energy AS float)) DESC;

/*
Perspective 1 
Observing the relationship between GDP growth and renewables_share_energy growth to 
determine if it positively or negatively impacts GDP, and whether the supply of energy from 
renewables can meet energy demands and therefore be adequate to sustain economic growth.
*/
#[252 row(s) returned] 
SELECT country, year, gdp, renewables_share_energy
FROM cleaned_owid_energy_data
WHERE country in ("Iceland", "Norway", "Sweden", "New Zealand", "Brazil", "Ecuador", "Colombia", "Peru", "Sri Lanka", "Vietnam", "Philippines", "Pakistan")
AND renewables_share_energy != ''
AND year>=2000;

/*
Perspective 2 
Observing the consistency of electricity generation from renewables (renewables_electricity) to 
determine if renewables is a stable source to be relied upon for economic growth.
*/
#[260 row(s) returned] 
SELECT country, year, renewables_electricity
FROM cleaned_owid_energy_data
WHERE year>=2000
AND country in ("Iceland", "Norway", "Sweden", "New Zealand", "Brazil", "Ecuador", "Colombia", "Peru", "Sri Lanka", "Vietnam", "Philippines", "Pakistan");

/*
Question 14. 
*Open-ended question* 
Say micro-nuclear reactors (see https://energypost.eu/micro- nuclear-reactors-up-to-20mw-portable-safer/) 
have become environmentally viable and economically feasible for Singapore. 
Shall we go nuclear? Why / why not? 
Substantiate your team’s opinion with the data provided.
*/

#Examine the percentage change in solar energy consumption across the years
SELECT solar_cons_change_pct,solar_share_energy,year 
FROM owid_energy_data 
WHERE country='Singapore'
AND year>=2009;

#Obtain the average energy change in solar energy consumption
SELECT AVG(solar_cons_change_pct) 
FROM owid_energy_data 
WHERE country='Singapore' 
AND year>=2009;

#See natural gas imports for electricity from 2008
SELECT gas_share_elec,year 
FROM owid_energy_data 
WHERE country='Singapore' 
AND year>=2008;

#Obtain the countries where fossil fuel and nuclear share is greater than 95%
SELECT country, year, carbon_intensity_elec,nuclear_share_energy,fossil_share_energy
FROM owid_energy_data,
(SELECT DISTINCT(country) AS shortlist
FROM owid_energy_data
WHERE nuclear_share_energy!='' AND nuclear_share_energy!='0'
AND carbon_intensity_elec != ''
AND fossil_share_energy != '' AND fossil_share_energy != '0'
GROUP BY country
HAVING AVG(CAST(NULLIF(nuclear_share_energy,0) AS float)+CAST(NULLIF(fossil_share_energy,0) AS float))>95)a
WHERE country=shortlist
AND carbon_intensity_elec!=''
AND nuclear_share_energy !='' 
AND nuclear_share_energy >0 ;

#Find the number of micro nuclear reactors needed to power 10% of singapore's primary energy consumption
SELECT (primary_energy_consumption*1000000) /(20*3600) AS no_of_mirco_nuclear_reactors, year  
FROM owid_energy_data 
WHERE country='Singapore';

/*
Question 15
Despite the increasing awareness of environmental issues, 
some remain sceptical about climate change being a problem 
(see https://www.bbc.com/news/science-environment-62225696). 
Using the data provided in this project and the individual assignment 
(as well as any other publicly available data, if your team shall desire), 
build a convincing data narrative to illustrate climate change problems 
associated with emissions.
*/

# Create a new table for greenhouse gases using owid greenhouse gas data set 
CREATE TABLE greenworld2022.owid_greenhouse_gas (
  country TEXT NULL,
  year TEXT NULL,
  iso_code TEXT NULL,
  population TEXT NULL,
  gdp TEXT NULL,
  cement_co2 TEXT NULL,
  cement_co2_per_capita TEXT NULL,
  co2 TEXT NULL,
  co2_growth_abs TEXT NULL,
  co2_growth_prct TEXT NULL,
  co2_per_capita TEXT NULL,
  co2_per_gdp TEXT NULL,
  co2_per_unit_energy TEXT NULL,
  coal_co2 TEXT NULL,
  coal_co2_per_capita TEXT NULL,
  consumption_co2 TEXT NULL,
  consumption_co2_per_capita TEXT NULL,
  consumption_co2_per_gdp TEXT NULL,
  cumulative_cement_co2 TEXT NULL,
  cumulative_co2 TEXT NULL,
  cumulative_coal_co2 TEXT NULL,
  cumulative_flaring_co2 TEXT NULL,
  cumulative_gas_co2 TEXT NULL,
  cumulative_oil_co2 TEXT NULL,
  cumulative_other_co2 TEXT NULL,
  energy_per_capita TEXT NULL,
  energy_per_gdp TEXT NULL,
  flaring_co2 TEXT NULL,
  flaring_co2_per_capita TEXT NULL,
  gas_co2 TEXT NULL,
  gas_co2_per_capita TEXT NULL,
  ghg_excluding_lucf_per_capita TEXT NULL,
  ghg_per_capita TEXT NULL,
  methane TEXT NULL,
  methane_per_capita TEXT NULL,
  nitrous_oxide TEXT NULL,
  nitrous_oxide_per_capita TEXT NULL,
  oil_co2 TEXT NULL,
  oil_co2_per_capita TEXT NULL,
  other_co2_per_capita TEXT NULL,
  other_industry_co2 TEXT NULL,
  primary_energy_consumption TEXT NULL,
  share_global_cement_co2 TEXT NULL,
  share_global_co2 TEXT NULL,
  share_global_coal_co2 TEXT NULL,
  share_global_cumulative_cement_co2 TEXT NULL,
  share_global_cumulative_co2 TEXT NULL,
  share_global_cumulative_coal_co2 TEXT NULL,
  share_global_cumulative_flaring_co2 TEXT NULL,
  share_global_cumulative_gas_co2 TEXT NULL,
  share_global_cumulative_oil_co2 TEXT NULL,
  share_global_cumulative_other_co2 TEXT NULL,
  share_global_flaring_co2 TEXT NULL,
  share_global_gas_co2 TEXT NULL,
  share_global_oil_co2 TEXT NULL,
  share_global_other_co2 TEXT NULL,
  total_ghg TEXT NULL,
  total_ghg_excluding_lucf TEXT NULL,
  trade_co2 TEXT NULL,
  trade_co2_share TEXT NULL);
## Then use Table Data Import wizard and import "owid-co2-data.csv" to fill up the table

-- 1. Prove that Climate Change is man-made
-- Establish the rising trend of carbon dioxide
# Find the total amount of greenhouse gases produced 
SELECT distinct(year),total_ghg
FROM greenworld2022.owid_greenhouse_gas
WHERE country = 'World'
AND total_ghg != '';

-- Association of AverageLandTemperature and Greenhouse Gas
SELECT * FROM sustainability2022.globaltemperatures;
SELECT * FROM sustainability2022.greenhouse_gas_inventory_data_data;
SELECT DISTINCT(country_or_area) FROM sustainability2022.greenhouse_gas_inventory_data_data;

# Do not refer to the trend of greenhouse gas emissions in sustainbility dataset as it does not include data from 
# the 2 major producers : China and India 
SELECT greenhouse.year as Year,avgLandTemperature, minLandTemperature, maxLandTemperature, total_ghg
FROM
(
	SELECT DISTINCT(year),total_ghg
	FROM greenworld2022.owid_greenhouse_gas
	WHERE country = 'World'
	AND total_ghg != '') as greenhouse 
NATURAL JOIN
(
	SELECT year(recordedDate) as year, AVG(cast(LandAverageTemperature as double)) as avgLandTemperature,max(cast(LandAverageTemperature as double)) as maxLandTemperature,
	MIN(CAST(LandAverageTemperature as double)) as minLandTemperature FROM sustainability2022.globaltemperatures 
	GROUP BY year(recordedDate)) as globaltemp 
ORDER BY greenhouse.year;

-- Association of Ice Extent and Greenhouse Gas
# For respective hemisphere
SELECT year, avg(cast(Extent as double)) as avg_extent, max(cast(Extent as double)) as max_extent,
min(cast(Extent as double)) as min_extent, hemisphere FROM sustainability2022.seaice
GROUP BY year,hemisphere;

#For both hemisphere (Overview)
SELECT seaice.year as Year,avg_extent, max_extent, min_extent, total_ghg
FROM
( 
	SELECT year, avg(cast(Extent as double)) as avg_extent, max(cast(Extent as double)) as max_extent,
	min(cast(Extent as double)) as min_extent FROM sustainability2022.seaice
	GROUP BY year) as seaice 
NATURAL JOIN
(
	SELECT distinct(year),total_ghg
	FROM greenworld2022.owid_greenhouse_gas
	WHERE country = 'World'
	AND total_ghg != '') as greenhouse 
ORDER BY seaice.year;

-- Association of mass_balance and Greenhouse Gas
# Choose to analyse only countries which have consistently been surveryed from 1990-2020 each year
# That is 38 countries as shown in the view created
CREATE VIEW glacier AS SELECT NAME
FROM sustainability2022.mass_balance_data
WHERE (substring(SURVEY_DATE,1,4) BETWEEN 1990 AND 2020)
GROUP BY NAME
HAVING count(substring(SURVEY_DATE,1,4)) = 30;

#Find the annual balance of the 38 countries listed above
SELECT greenhouse.year as Year,avg_annual_balance, total_ghg from
(
	SELECT substring(SURVEY_DATE,1,4) AS Year, AVG(ANNUAL_BALANCE) AS avg_annual_balance
	FROM sustainability2022.mass_balance_data
	WHERE (substring(SURVEY_DATE,1,4) BETWEEN 1990 AND 2020) AND NAME IN (SELECT NAME FROM glacier)
	GROUP BY substring(SURVEY_DATE,1,4)) as m
NATURAL JOIN
(
	SELECT distinct(year),total_ghg
	FROM greenworld2022.owid_greenhouse_gas
	WHERE country = 'World'
	AND total_ghg != '') as greenhouse
ORDER BY greenhouse.year;

-- 2. Prove that the Consequences of Climate Change affects us

# Create a new table and import dataset for occurrence of natural disasters
CREATE TABLE greenworld2022.number_of_natural_disaster_events (
  year TEXT NULL,
  drought TEXT NULL,
  earthquake TEXT NULL,
  extreme_temperature TEXT NULL,
  extreme_weather TEXT NULL,
  flood TEXT NULL,
  impact TEXT NULL,
  landslide TEXT NULL,
  mass_movement_dry TEXT NULL,
  volcanic_activity TEXT NULL,
  wildfire TEXT NULL,
  total TEXT NULL);
## Then use Table Data Import wizard and import "number-of-natural-disaster-events.csv" to fill up the table

#check
SELECT * from greenworld2022.number_of_natural_disaster_events;

# Remove the asteroid impact as it is not the result of global warming
# Generate a newtotal occurrence of natural disasters for each year
SELECT year, (drought + earthquake+extreme_temperature+extreme_weather+
flood+landslide+mass_movement_dry+volcanic_activity+wildfire) as newtotal from greenworld2022.number_of_natural_disaster_events;

# Create a new table and import new dataset for economic loss incurred from natural disasters
CREATE TABLE greenworld2022.economic_damage_natural_disasters (
  natural_disaster TEXT NULL,
  year TEXT NULL,
  total_economic_damage TEXT NULL);
## Then use Table Data Import wizard and import "economic-damage-from-natural-disasters.csv" to fill up the table
  
#check
SELECT * from greenworld2022.economic_damage_natural_disasters;

#Find the total damages incurred
#start from 1942 where there is missing value for years after
select year , sum(total_economic_damage) as total_damage from greenworld2022.economic_damage_natural_disasters
where year between 1942 and 2018
group by year;

# Create a new table and import dataset for tropical diseases + malaria
CREATE TABLE greenworld2022.tropical_disease (
measure_name TEXT NULL,
location_name TEXT NULL,
sex_name TEXT NULL,
age_name TEXT NULL,
cause_name TEXT NULL,
metric_name TEXT NULL,
year TEXT NULL,
val TEXT NULL,
upper TEXT NULL,
lower TEXT NULL);
## Then use Table Data Import wizard and import "IHME-GBD_2019_DATA-3c59ab0d-1.csv" to fill up the table

#check
select * from greenworld2022.tropical_disease;

# For each year, find the total number of incidences
# that are strictly due to neglected tropical diseases and malaria
SELECT year, sum(val) as total_affected from greenworld2022.tropical_disease
WHERE cause_name = "Neglected tropical diseases and malaria"
AND metric_name = "Number"
GROUP BY year;



