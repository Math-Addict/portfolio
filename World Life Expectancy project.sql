                      #World Life Expectancy Project

#1. DATA CLEANING

SELECT * FROM world_life_expectancy;

# Removing Duplicates we need to have only 1 country in every year

#checking if there is any duplicate columns we need to remove
SELECT Country ,Year,COUNT(CONCAT(COUNTRY,Year)) AS if_dup
FROM world_life_expectancy
GROUP By Country, Year
HAVING if_dup >1;

#Remove the duplicate columns
#first use a windows function to specify the Row_ID of the duplicates
#cant do that with group by
SELECT Row_ID
FROM (
	SELECT Row_ID,
    concat(Country,Year) AS cy,
    ROW_NUMBER() OVER(PARTITION BY concat(Country,Year)) AS row_num
    FROM world_life_expectancy
    )AS row_table
WHERE row_num>1;

#now remove duplicates

DELETE FROM world_life_expectancy
WHERE
	Row_ID IN(
		SELECT Row_ID
FROM (
	SELECT Row_ID,
    concat(Country,Year) AS cy,
    ROW_NUMBER() OVER(PARTITION BY concat(Country,Year)) AS row_num
    FROM world_life_expectancy
    )AS row_table
WHERE row_num>1
        );


#find how many blank rows we have in the status column

SELECT * 
FROM world_life_expectancy
WHERE Status = ''
;

#lets check if we can populate that by checking if the status is populated in another year

SELECT * FROM world_life_expectancy
WHERE Country IN (SELECT Country 
FROM world_life_expectancy
WHERE Status = ''
);

#we saw that the status is populated in another year and is Developing or Developed
#populate the missing status
#first set the status of the country that are Developed 
UPDATE world_life_expectancy t1
JOIN (
	SELECT Country
    FROM world_life_expectancy
    WHERE Status = 'Developing'
    ) t2 ON t1.Country = t2.Country
SET t1.Status = 'Developing';

#update the remainning column to developed
UPDATE world_life_expectancy
SET Status = 'Developed'
WHERE Status = '';

#lets try and populate the life expectancy
#where the value is blank we will populate that with the avg of the nearest columns

SELECT t1.Country AS t1Country,t1.Year AS t1year ,t1.`Life expectancy` AS t1life,
t2.Country,t2.Year ,t2.`Life expectancy`,
t3.Country,t3.Year ,t3.`Life expectancy`,
ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2,1) AS av
FROM world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
	AND t1.Year = t2.Year-1
JOIN world_life_expectancy t3
	ON t1.Country = t3.Country
	AND t1.Year = t3.Year+1
WHERE t1.`Life expectancy` = ''

;
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
	AND t1.Year = t2.Year-1
JOIN world_life_expectancy t3
	ON t1.Country = t3.Country
	AND t1.Year = t3.Year+1
SET t1.`Life expectancy` = ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2,1)
WHERE t1.`Life expectancy` = '';

#2. Exploratory Data Analysis

SELECT *
FROM world_life_expectancy;

#find the average life expectancy of thw world in each year

SELECT Year,ROUND(AVG(`Life expectancy`),2)
FROM world_life_expectancy
WHERE `Life expectancy` !=0
GROUP BY Year
ORDER BY Year
;
#we can see that as a world the life expectancy got up from 66.75 to 71.62

#lets check the correlation between life expectancy with GDP 

SELECT Country,ROUND(AVG(`Life expectancy`),1) AS Life_Exp,ROUND(AVG(GDP),1) AS GDP
FROM world_life_expectancy
GROUP BY Country
HAVING Life_Exp > 0
AND GDP > 0
ORDER BY GDP
;
#we can see that clearly that is a correlation between life expectancy and GDP


SELECT 
SUM(CASE WHEN GDP >= 1172 THEN 1 ELSE 0 END) AS High_GDP_Count,
AVG(CASE WHEN GDP >= 1172 THEN `Life expectancy` ELSE NULL END) AS High_Life_ecpectancy_avg,
SUM(CASE WHEN GDP <= 1172 THEN 1 ELSE 0 END) AS Low_GDP_Count,
AVG(CASE WHEN GDP <= 1172 THEN `Life expectancy` ELSE NULL END) AS Low_Life_ecpectancy_avg
FROM world_life_expectancy
;
#we can see that the upper half of the GDP have more life expectancy
#on average then from the bottom half.alter




SELECT Status,COUNT(Country),ROUND(AVG(`Life expectancy`),1)
FROM world_life_expectancy
GROUP BY Status
;



#lets check the correlation between life expectancy with BMI 

SELECT Country,ROUND(AVG(`Life expectancy`),1) AS Life_Exp,ROUND(AVG(BMI),1) AS BMI
FROM world_life_expectancy
GROUP BY Country
HAVING Life_Exp > 0
AND BMI > 0
ORDER BY BMI
;

#check the adult mortality in each year
#we use order by in the over clause so the sum will sum each row and not randomly
SELECT Country,
Year,
`Life expectancy`,
`Adult Mortality`,
SUM(`Adult Mortality`) OVER (PARTITION BY Country ORDER BY Year) AS Rolling_Total
FROM world_life_expectancy;





