SELECT * 
FROM public."Nashville_housing_data";

----- Standardizing date format 
SELECT 
    "SaleDateConverted",
    CAST("SaleDate" AS DATE) 
FROM public."Nashville_housing_data";

ALTER TABLE "Nashville_housing_data" 
ADD "SaleDateConverted" DATE;

-- 3. Updating the converted data into the created column
UPDATE "Nashville_housing_data"
SET "SaleDateConverted" = CAST("SaleDate" AS DATE);

-----------------------------------------------------------------------------------------------------------------
---populate the address 
SELECT *
FROM public."Nashville_housing_data"
--WHERE "PropertyAddress" IS NULL
ORDER BY "ParcelID" ;

---Correcting an import mismatch of the column
ALTER TABLE "Nashville_housing_data" 
RENAME COLUMN "UniqueID " TO "UniqueID";

----Using a self join because the parcel ID is the same for the addresses and distinguished the rows using UniqueID
----Used Coalesce function to populate the address in a with the column b.propertyaddress
SELECT a."ParcelID" ,a."PropertyAddress" ,b."ParcelID", b."PropertyAddress" ,COALESCE(a."PropertyAddress",b."PropertyAddress")
FROM public."Nashville_housing_data" a
JOIN public."Nashville_housing_data" b 
ON a."ParcelID" = b."ParcelID"
AND a."UniqueID" <> b."UniqueID"
WHERE a."PropertyAddress" IS NULL

-----Updating the values 
UPDATE "Nashville_housing_data" AS a
SET "PropertyAddress" = COALESCE(a."PropertyAddress", b."PropertyAddress")
FROM "Nashville_housing_data" AS b
WHERE a."ParcelID" = b."ParcelID"
  AND a."UniqueID" <> b."UniqueID"
  AND a."PropertyAddress" IS NULL;


------------------------------------------------------------------------------------------------------------
---breaking down address into seperate columns
SELECT 
    split_part("OwnerAddress", ',', 1) AS Address,
    split_part("OwnerAddress", ',', 2) AS City,
    split_part("OwnerAddress", ',', 3) AS State
FROM public."Nashville_housing_data";

ALTER TABLE "Nashville_housing_data"
ADD COLUMN "OwnerSplitAddress" VARCHAR(255);

UPDATE "Nashville_housing_data"
SET "OwnerSplitAddress" =  split_part("OwnerAddress", ',', 1)

ALTER TABLE "Nashville_housing_data"
ADD COLUMN "OwnerSplitCity" VARCHAR(255);

UPDATE "Nashville_housing_data"
SET "OwnerSplitCity" = split_part("OwnerAddress", ',', 2)

ALTER TABLE "Nashville_housing_data"
ADD COLUMN "OwnerSplitState" VARCHAR(255);

UPDATE "Nashville_housing_data"
SET "OwnerSplitState" = split_part("OwnerAddress", ',', 3)

SELECT "OwnerSplitAddress" , "OwnerSplitCity" ,"OwnerSplitState"
FROM public."Nashville_housing_data"

SELECT * FROM public."Nashville_housing_data"
ORDER BY "UniqueID" ASC;

---------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field using case function 


Select Distinct("SoldAsVacant"), Count("SoldAsVacant")
From public."Nashville_housing_data"
Group by "SoldAsVacant"
order by 2

Select "SoldAsVacant"
, CASE When "SoldAsVacant" = 'Y' THEN 'Yes'
	   When "SoldAsVacant" = 'N' THEN 'No'
	   ELSE "SoldAsVacant"
	   END
From public."Nashville_housing_data"


Update "Nashville_housing_data"
SET "SoldAsVacant" = CASE When "SoldAsVacant" = 'Y' THEN 'Yes'
	   When "SoldAsVacant" = 'N' THEN 'No'
	   ELSE "SoldAsVacant"
	   END

---------------------------------------------------------------------------------------------

-----Deletion for PostgresSQL
DELETE FROM public."Nashville_housing_data"
WHERE "UniqueID" IN (
    SELECT "UniqueID"
    FROM (
        SELECT "UniqueID",
        ROW_NUMBER() OVER(
            PARTITION BY "ParcelID", 
                         "PropertyAddress", 
                         "SalePrice", 
                         "SaleDate", 
                         "LegalReference" 
            ORDER BY "UniqueID"
        ) AS row_num
        FROM public."Nashville_housing_data"
    ) AS duplicates
    WHERE row_num > 1
);


--------------------------------------------------------------------------------------
--Delete Unused columns 
SELECT * FROM public."Nashville_housing_data"

ALTER TABLE "Nashville_housing_data"
DROP COLUMN "OwnerAddress", 
DROP COLUMN "TaxDistrict", 
DROP COLUMN "PropertyAddress",
DROP COLUMN "SaleDate";

-- Data validation
SELECT COUNT(*) AS total_rows FROM public."Nashville_housing_data";
SELECT COUNT(*) AS null_addresses FROM public."Nashville_housing_data" WHERE "OwnerSplitAddress" IS NULL;
SELECT DISTINCT "SoldAsVacant" FROM public."Nashville_housing_data";
SELECT * FROM public."Nashville_housing_data" WHERE "OwnerSplitAddress" IS NULL;