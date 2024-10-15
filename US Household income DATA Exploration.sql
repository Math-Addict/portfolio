#2. Exploratory Data Analysis
 
#lets find the 10 largest states by land
SELECT State_Name, SUM(ALand),SUM(AWater)
FROM us_house_hold_income
GROUP BY State_Name
ORDER BY 2 DESC
LIMIT 10;

 
 #10 largest by water
SELECT State_Name, SUM(ALand),SUM(AWater)
FROM us_house_hold_income
GROUP BY State_Name
ORDER BY 3 DESC
LIMIT 10;
 
 #lets join the 2 tables 
 SELECT * 
 FROM us_house_hold_income i
 JOIN us_house_hold_income_statistics s
	ON i.id = s.id
WHERE s.Mean != 0   #if the mean is 0 its mean that there is no report so we dont need that    
;
 
 
 
SELECT i.State_Name, i.County, i.Type, i.Primary, s.Mean, s.Median 
FROM us_house_hold_income i
JOIN us_house_hold_income_statistics s
	ON i.id = s.id
WHERE s.Mean != 0;
 
 
 #lets look on the state level
SELECT i.State_Name, ROUND(AVG(s.Mean),2), ROUND(AVG(s.Median),2) 
FROM us_house_hold_income i
JOIN us_house_hold_income_statistics s
	ON i.id = s.id
WHERE s.Mean != 0
GROUP BY i.State_Name
ORDER BY 2
;
 
 #lets find the 5 lowest income per state for house hold
SELECT i.State_Name, ROUND(AVG(s.Mean),2), ROUND(AVG(s.Median),2) 
FROM us_house_hold_income i
JOIN us_house_hold_income_statistics s
	ON i.id = s.id
WHERE s.Mean != 0
GROUP BY i.State_Name
ORDER BY 2
LIMIT 5
;
 
 #find the top 5 income
 
SELECT i.State_Name, ROUND(AVG(s.Mean),2), ROUND(AVG(s.Median),2) 
FROM us_house_hold_income i
JOIN us_house_hold_income_statistics s
	ON i.id = s.id
WHERE s.Mean != 0
GROUP BY i.State_Name
ORDER BY 2 DESC
LIMIT 5
;
 
#lest do the same with the median
SELECT i.State_Name, ROUND(AVG(s.Mean),2), ROUND(AVG(s.Median),2) 
FROM us_house_hold_income i
JOIN us_house_hold_income_statistics s
	ON i.id = s.id
WHERE s.Mean != 0
GROUP BY i.State_Name
ORDER BY 3
LIMIT 5
;

SELECT i.State_Name, ROUND(AVG(s.Mean),2), ROUND(AVG(s.Median),2) 
FROM us_house_hold_income i
JOIN us_house_hold_income_statistics s
	ON i.id = s.id
WHERE s.Mean != 0
GROUP BY i.State_Name
ORDER BY 3 DESC
LIMIT 5
;

 #lets check the same but now lets group by Type
 #we will add a count on the type so we can see which avg is more accurate
SELECT i.Type,COUNT(i.Type), ROUND(AVG(s.Mean),2), ROUND(AVG(s.Median),2) 
FROM us_house_hold_income i
JOIN us_house_hold_income_statistics s
	ON i.id = s.id
WHERE s.Mean != 0
GROUP BY i.Type
ORDER BY 2
;
#we can see that Municipality os not that accurate (we have only 1 sample)
#and Track is the most accurate.
#lets filter the ones that are not that accurate 
#so if we want to use that later to check stuff we will have accurate data

SELECT i.Type,COUNT(i.Type), ROUND(AVG(s.Mean),2), ROUND(AVG(s.Median),2) 
FROM us_house_hold_income i
JOIN us_house_hold_income_statistics s
	ON i.id = s.id
WHERE s.Mean != 0
GROUP BY i.Type
HAVING COUNT(i.Type) > 100
;

#now lets check the income but in the city level

SELECT i.State_Name,i.City, ROUND(AVG(s.Mean),2)
FROM us_house_hold_income i
JOIN us_house_hold_income_statistics s
	ON i.id = s.id
WHERE s.Mean != 0
GROUP BY i.State_Name,i.City
ORDER BY ROUND(AVG(s.Mean),2) DESC
;