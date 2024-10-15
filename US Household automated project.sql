#Automated Data Cleaning
USE us_project;
-- create another table that we will do the cleaning on
-- so if we mess up we can come back to the original

DELIMITER $$
DROP PROCEDURE IF EXISTS Copy_and_Clean_DATA;
CREATE PROCEDURE Copy_and_Clean_DATA()
BEGIN
	CREATE TABLE IF NOT EXISTS `us_house_hold_income_clean` (
	  `row_id` int DEFAULT NULL,
	  `id` int DEFAULT NULL,
	  `State_Code` int DEFAULT NULL,
	  `State_Name` text,
	  `State_ab` text,
	  `County` text,
	  `City` text,
	  `Place` text,
	  `Type` text,
	  `Primary` text,
	  `Zip_Code` int DEFAULT NULL,
	  `Area_Code` int DEFAULT NULL,
	  `ALand` int DEFAULT NULL,
	  `AWater` int DEFAULT NULL,
	  `Lat` double DEFAULT NULL,
	  `Lon` double DEFAULT NULL,
	  `TimeStamp` timestamp DEFAULT NULL   #adding another column so if there is a problem we can know the date it happend
	) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
    -- Copy data into new table
	INSERT INTO us_house_hold_income_clean
	SELECT *, CURRENT_TIMESTAMP()
    FROM us_house_hold_income;
    
    
	#Data Cleaning 

	-- Remove Duplicates
	DELETE FROM us_household_income_clean 
	WHERE 
		row_id IN (
		SELECT row_id
	FROM (
		SELECT row_id, id,
			ROW_NUMBER() OVER (
				PARTITION BY id, `TimeStamp`     #add the timestamp column so if we call that procedure again it wont delete all the rows.
				ORDER BY id, `TimeStamp`) AS row_num
		FROM 
			us_household_income_clean
	) duplicates
	WHERE 
		row_num > 1
	);

	-- Fixing some data quality issues by fixing typos and general standardization
	UPDATE us_household_income_clean
	SET State_Name = 'Georgia'
	WHERE State_Name = 'georia';

	UPDATE us_household_income_clean
	SET County = UPPER(County);

	UPDATE us_household_income_clean
	SET City = UPPER(City);

	UPDATE us_household_income_clean
	SET Place = UPPER(Place);

	UPDATE us_household_income_clean
	SET State_Name = UPPER(State_Name);

	UPDATE us_household_income_clean
	SET `Type` = 'CDP'
	WHERE `Type` = 'CPD';

	UPDATE us_household_income_clean
	SET `Type` = 'Borough'
	WHERE `Type` = 'Boroughs';
    
END$$
DELIMITER ;

CALL Copy_and_Clean_DATA();



-- CREATE EVENT
DROP EVENT IF EXISTS run_data_cleaning;
CREATE EVENT run_data_cleaning
ON SCHEDULE EVERY 30 DAY
DO CALL Copy_and_Clean_DATA();





