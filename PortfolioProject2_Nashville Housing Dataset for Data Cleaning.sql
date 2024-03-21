/* 
DATA CLEANING IN SQL
*/

SELECT * 
FROM ProjectPortfolio.dbo.NashvilleHousing

--1.STANDARDISE DATE FORMAT

SELECT SaleDate, CONVERT(DATE, SaleDate) AS SaleDateConverted
FROM ProjectPortfolio.dbo.NashvilleHousing;

UPDATE NashvilleHousing
SET SaleDate = CONVERT(DATE, SaleDate);

-- IF THE ABOVE QUERY DOES NOT WORK THEN TRY THE BELOW ONE

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate DATE;

--AN OTHER METHOD WE CAN DO THE ABOVE

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;
--FIRST CREATE THE NEW COULUMN AND THEN RUN THE BELOW UPDATE QUERY TO ADD VALUES TO THE NEW COULUMN CREATED
UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate);


--2.POPULATE PROPERTY ADDRESS DATA

SELECT *
FROM ProjectPortfolio.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

--WHEN WE RUN THE ABOVE QUERY WE CAN SEE THAT WHEN THE ParcelID IS THE SAME, THE PropertyAddress IS ALSO THE SAME

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(b.PropertyAddress, a.PropertyAddress)
FROM ProjectPortfolio.dbo.NashvilleHousing a
JOIN ProjectPortfolio.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID 
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE b.PropertyAddress IS NULL

BEGIN TRANSACTION;

UPDATE b -- WHEN USING JOINS AND UPDATE, ALWAYS USE THE ALIAS NAME INSTEAD OF THE TABLE NAME
SET PropertyAddress = ISNULL(b.PropertyAddress, a.PropertyAddress)
FROM ProjectPortfolio.dbo.NashvilleHousing a
JOIN ProjectPortfolio.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID 
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE b.PropertyAddress IS NULL;

COMMIT;

--3.BREAKING DOWN ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, STATE, CITY)

SELECT PropertyAddress
FROM ProjectPortfolio.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID;

SELECT 
SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM ProjectPortfolio.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);
--FIRST CREATE THE NEW COULUMN AND THEN RUN THE BELOW UPDATE QUERY TO ADD VALUES TO THE NEW COULUMN CREATED
UPDATE NashvilleHousing
SET PropertySplitAddress = 
SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) - 1);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);
--FIRST CREATE THE NEW COULUMN AND THEN RUN THE BELOW UPDATE QUERY TO ADD VALUES TO THE NEW COULUMN CREATED
UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

SELECT *
FROM ProjectPortfolio.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------

SELECT OwnerAddress
FROM ProjectPortfolio.dbo.NashvilleHousing


SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM ProjectPortfolio.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);
--FIRST CREATE THE NEW COULUMN AND THEN RUN THE BELOW UPDATE QUERY TO ADD VALUES TO THE NEW COULUMN CREATED
UPDATE NashvilleHousing
SET OwnerSplitAddress = 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);
--FIRST CREATE THE NEW COULUMN AND THEN RUN THE BELOW UPDATE QUERY TO ADD VALUES TO THE NEW COULUMN CREATED
UPDATE NashvilleHousing
SET OwnerSplitCity = 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);
--FIRST CREATE THE NEW COULUMN AND THEN RUN THE BELOW UPDATE QUERY TO ADD VALUES TO THE NEW COULUMN CREATED
UPDATE NashvilleHousing
SET OwnerSplitState = 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

SELECT *
FROM ProjectPortfolio.dbo.NashvilleHousing

--4.CHANGE Y AND N TO YES AND NO IN "SoldAsVacant" FIELD

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM ProjectPortfolio.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant, 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' 
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
END
FROM ProjectPortfolio.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' 
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
END

--5.REMOVE DUPLICATES

WITH RowNumCTE AS (
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
             PropertySplitAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY UniqueID) Row_Num
FROM ProjectPortfolio.dbo.NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE Row_Num > 1
ORDER BY PropertySplitAddress

----------------------------------------------------------------------------
-- IT IS NOT GOOD PRACTICE TO DELETE DATA FROM THE DATABASE, INSTEAD WE CAN CREATE TEMP TABLES AND STORE THE DUPLICATES THERE
-- IN THIS EXAMPLE WE ARE DELETING THE DUPLICATE DATA FROM THE DATABASE JUST TO KNOW HOW IT IS DONE

WITH RowNumCTE AS (
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
             PropertySplitAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY UniqueID) Row_Num
FROM ProjectPortfolio.dbo.NashvilleHousing
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE Row_Num > 1


--6.DELETE UNUSED COLUMNS

--THIS DOES NOT HAPPEN OFTEN, IT USUALLY HAPPENS WITH VIEWS (WE REMOVE UNWANTED VIEWS OR VIEWS CREATED BY MISTAKE)
--IT IS NOT A BEST PRACTICE TO DELETE UNUSED COLUMNS IN THE RAW DATA, SO NEVER DO IT
-- IN THIS EXAMPLE WE ARE DELETING THE UNUSED COLUMNS FROM THE DATABASE JUST TO KNOW HOW IT IS DONE

SELECT *
FROM ProjectPortfolio.dbo.NashvilleHousing


ALTER TABLE ProjectPortfolio.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict
