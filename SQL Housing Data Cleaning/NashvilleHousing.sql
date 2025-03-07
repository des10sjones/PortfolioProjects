/* Cleaning Data in SQL */



SELECT * FROM Housing.`nashville housing data for data cleaning`;

CREATE TABLE Housing.housing_cleaned
LIKE Housing.`nashville housing data for data cleaning`;

SELECT * 
FROM housing_cleaned;

INSERT housing_cleaned
SELECT *
FROM Housing.`nashville housing data for data cleaning`;

/*
The Columns with Doubles caused errors when importing the empty cells
Therefore they were imported as text fields 

The statement below checks for empty cells in fields that need to be converted to doubles
*/

SELECT Acreage,
LandValue,
BuildingValue,
TotalValue,
YearBuilt,
Bedrooms,
FullBath,
HalfBath
FROM housing_cleaned
WHERE     
Acreage NOT REGEXP '^[0-9]+(\.[0-9]*)?$' OR
LandValue NOT REGEXP '^[0-9]+(\.[0-9]*)?$' OR
BuildingValue NOT REGEXP '^[0-9]+(\.[0-9]*)?$' OR
TotalValue NOT REGEXP '^[0-9]+(\.[0-9]*)?$' OR
YearBuilt NOT REGEXP '^[0-9]+(\.[0-9]*)?$' OR
Bedrooms NOT REGEXP '^[0-9]+(\.[0-9]*)?$' OR
FullBath NOT REGEXP '^[0-9]+(\.[0-9]*)?$' OR
HalfBath NOT REGEXP '^[0-9]+(\.[0-9]*)?$';

-- Replace the empty cells with Null Values
UPDATE housing_cleaned
SET Acreage = NULL
WHERE Acreage NOT REGEXP '^[0-9]+(\.[0-9]*)?$';

SELECT Acreage
from housing_cleaned;

UPDATE housing_cleaned
SET LandValue = NULL
WHERE LandValue NOT REGEXP '^[0-9]+(\.[0-9]*)?$';

UPDATE housing_cleaned
SET BuildingValue = NULL
WHERE BuildingValue NOT REGEXP '^[0-9]+(\.[0-9]*)?$';

UPDATE housing_cleaned
SET TotalValue = NULL
WHERE TotalValue NOT REGEXP '^[0-9]+(\.[0-9]*)?$';

UPDATE housing_cleaned
SET YearBuilt = NULL
WHERE YearBuilt NOT REGEXP '^[0-9]+(\.[0-9]*)?$';

UPDATE housing_cleaned
SET Bedrooms = NULL
WHERE Bedrooms NOT REGEXP '^[0-9]+(\.[0-9]*)?$';

UPDATE housing_cleaned
SET FullBath = NULL
WHERE FullBath NOT REGEXP '^[0-9]+(\.[0-9]*)?$';

UPDATE housing_cleaned
SET HalfBath = NULL
WHERE HalfBath NOT REGEXP '^[0-9]+(\.[0-9]*)?$';

-- Standerize Date Format

SELECT SaleDate, STR_TO_DATE(SaleDate,'%M %d,%Y') as ConvertedDate
FROM Housing.housing_cleaned;

UPDATE housing_cleaned
SET SaleDate = STR_TO_DATE(SaleDate,'%M %d,%Y')
WHERE  SaleDate IS NOT NULL;	

SELECT SaleDate
FROM housing_cleaned;


-- Populate Property Address data
SELECT *
FROM housing_cleaned;

SELECT PropertyAddress
FROM housing_cleaned
WHERE PropertyAddress = '';

UPDATE housing_cleaned
SET PropertyAddress= NULL
WHERE PropertyAddress = '';

SELECT *
FROM housing_cleaned
WHERE PropertyAddress IS NULL;

-- Parcel ID's have the same address
SELECT *
FROM housing_cleaned
ORDER BY ParcelID;


SELECT h1.ParcelID,
h1.PropertyAddress AS MissingAddress,
h2.ParcelID as MatchedParcel,
h2.PropertyAddress AS FallbackAddress,
COALESCE(h1.PropertyAddress,h2.PropertyAddress) AS UpdatedAddress    
FROM housing_cleaned AS h1
JOIN housing_cleaned as h2
	on h1.ParcelID = h2.ParcelID
    AND h1.UniqueID != h2.UniqueID
WHERE h1.PropertyAddress IS NULL
    ;

UPDATE housing_cleaned AS h1
JOIN housing_cleaned as h2
	on h1.ParcelID = h2.ParcelID
    AND h1.UniqueID != h2.UniqueID
SET h1.PropertyAddress = COALESCE(h1.PropertyAddress,h2.PropertyAddress) 
WHERE h1.PropertyAddress IS NULL;

SELECT *
FROM housing_cleaned;

-- Breaking Out Address Into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM housing_cleaned
;

SELECT PropertyAddress,
SUBSTRING(PropertyAddress, 1,LOCATE(',', PropertyAddress) - 1) AS Address,
SUBSTRING(PropertyAddress,LOCATE(',', PropertyAddress) + 2) AS City
FROM housing_cleaned
;

ALTER TABLE housing_cleaned
ADD COLUMN PropertyCity VARCHAR(255);

UPDATE housing_cleaned
SET PropertyCity = SUBSTRING(PropertyAddress,LOCATE(',', PropertyAddress) + 2);

UPDATE housing_cleaned
SET PropertyAddress = SUBSTRING(PropertyAddress, 1,LOCATE(',', PropertyAddress) - 1);

SELECT *
from housing_cleaned;

-- Owner Address Split

SELECT OwnerAddress
from housing_cleaned;

SELECT OwnerAddress,
SUBSTRING_INDEX(OwnerAddress, ',',1),
SUBSTRING_INDEX(OwnerAddress, ',',-1),
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',',-2),',',1) as OwnerCity
from housing_cleaned;

ALTER TABLE housing_cleaned
ADD COLUMN OwnerState VARCHAR(255);

ALTER TABLE housing_cleaned
ADD COLUMN OwnerCity VARCHAR(255);

UPDATE housing_cleaned 
SET OwnerState = SUBSTRING_INDEX(OwnerAddress, ',',-1);

UPDATE housing_cleaned 
SET OwnerCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',',-2),',',1);

-- Check before we change the address
SELECT OwnerAddress,OwnerCity,OwnerState
from housing_cleaned;

UPDATE housing_cleaned 
SET OwnerAddress = SUBSTRING_INDEX(OwnerAddress, ',',1);

SELECT OwnerAddress,OwnerCity,OwnerState
from housing_cleaned;

--  Chnage Y and N to Yes and No in 'Sold as Vacant'   Field
SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
from housing_cleaned
GROUP BY SoldAsVacant
ORDER BY 2;


SELECT SoldAsVacant,
CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
END AS fixedSoldAsVacant
FROM housing_cleaned
WHERE SoldAsVacant = 'Y' OR SoldAsVacant ='N';

UPDATE housing_cleaned
set SoldAsVacant = CASE 
						WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
					END;


SELECT Distinct SoldAsVacant
from housing_cleaned
;


-- Remove the Duplicates

SELECT *
from housing_cleaned;
with RowNumCTE as(
SELECT *,
ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
			   PropertyAddress,
	           SalePrice,
	           SaleDate,
			   LegalReference
			   ORDER BY UniqueID ) AS row_num
from housing_cleaned
)
-- ORDER BY ParcelID;
Select *
from RowNumCTE 
WHERE row_num >1
Order by PropertyAddress;


SELECT *,
ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
			   PropertyAddress,
	           SalePrice,
	           SaleDate,
			   LegalReference
			   ORDER BY UniqueID ) AS row_num
from housing_cleaned
where ParcelID ='090 11 0A 030.00'
;

SELECT *
from housing_cleaned;
with RowNumCTE as(
SELECT *,
ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
			   PropertyAddress,
	           SalePrice,
	           SaleDate,
			   LegalReference
			   ORDER BY UniqueID ) AS row_num
from housing_cleaned
)
-- ORDER BY ParcelID;
DELETE FROM housing_cleaned
WHERE UniqueID IN (
    SELECT UniqueID FROM RowNumCTE WHERE row_num > 1
);
-- Order by PropertyAddress;

SELECT *
from housing_cleaned;
with RowNumCTE as(
SELECT *,
ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
			   PropertyAddress,
	           SalePrice,
	           SaleDate,
			   LegalReference
			   ORDER BY UniqueID ) AS row_num
from housing_cleaned
)
-- ORDER BY ParcelID;
SELECT *
from RowNumCTE 
WHERE row_num >1
Order by PropertyAddress;


-- Delete Unused Columns
SELECT *
from housing_cleaned;

ALTER TABLE housing_cleaned
DROP COLUMN TaxDistrict;



