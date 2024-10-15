                         #US household Income Project
                         
#1.DATA Cleaning


SELECT * FROM us_house_hold_income_statistics;

SELECT * FROM us_house_hold_income;


#change the first column name in the statistics table from ï»¿id to just id

ALTER TABLE us_house_hold_income_statistics RENAME COLUMN `ï»¿id` TO `id`;

#lets check for duplicates

SELECT id,COUNT(id)
FROM us_house_hold_income
GROUP BY id
HAVING COUNT(id)>1;     #if they have count(id)>1 it means that there is 2 identical id's

#we can see that there is duplicates 
#we have a unique column (row_id) so we can delete the duplicates using that column
#first lets find the row_num rows we need to delete

SELECT row_id,id,row_num
FROM(
	SELECT row_id,id,
	ROW_NUMBER() OVER(PARTITION BY id) AS row_num
	FROM us_house_hold_income
    ) duplicate
WHERE row_num>1
    ;

#now we can use the delete statement after we now that we will delete the correct rows

DELETE FROM us_house_hold_income
WHERE row_id IN(
		SELECT row_id
	FROM(
		SELECT row_id,id,
		ROW_NUMBER() OVER(PARTITION BY id) AS row_num
		FROM us_house_hold_income
		) duplicate
	WHERE row_num>1);

#now lets do the same for the other table

#check if there is any duplicates

SELECT id,COUNT(id)
FROM us_house_hold_income_statistics
GROUP BY id
HAVING COUNT(id)>1;

#we dont have any dup in the statistics table

#check if there is any problem in the State_Name column
SELECT DISTINCT(State_Name) FROM us_house_hold_income
ORDER BY State_Name;

#Seems that every thing is fine except a typo in georia instead of Georgia
#and alabama instead of Alabama
#lets fick that

UPDATE us_house_hold_income
SET State_Name = 'Alabama'
WHERE State_Name = 'alabama';

UPDATE us_house_hold_income
SET State_Name = 'Georgia'
WHERE State_Name = 'georia';


#lets check if there is a problem in the state_ab column as well

SELECT DISTINCT(State_ab) FROM us_house_hold_income
ORDER BY State_ab;
#looks ok

#when i scrolled down the table i saw an empty value in the place column lets check

SELECT * 
FROM us_house_hold_income
WHERE Place = '';
#there is only 1 row like that ,lets see if we can populate her
#the empty place is in the Autauga County

SELECT * 
FROM us_house_hold_income
WHERE County = 'Autauga County';

#we can see that if the county is Autauga then the Place is Autaugaville

#lets populate the missing place

UPDATE us_house_hold_income
SET Place = 'Autaugaville'
WHERE Place = ''; #as we saw before there is only one value in place that missing .

#lets check the type column

SELECT Type,COUNT(Type)
FROM us_house_hold_income
GROUP BY Type;

#we can see that there is 2 typos,CPD instead of CDP (i checked google and there is no such
#thing as CPD in this context, and Boroughs instead of Borough.

#change that

UPDATE us_house_hold_income
SET Type = 'CDP'
WHERE Type = 'CPD';

UPDATE us_house_hold_income
SET Type = 'Borough'
WHERE Type = 'Boroughs';

#lets check id there is a county that is no water and no land because that is impossible

SELECT ALand,AWater
FROM us_house_hold_income
WHERE (ALand = 0 Or ALand = '' OR ALand IS NULL)
AND (AWater = 0 Or AWater = '' OR AWater IS NULL);
 #seems that we are good
 
 #we finish the data cleaning now we will move to the EDA
 
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












