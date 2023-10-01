SELECT * FROM nashvillHousing

SELECT newSalesDate, CONVERT(DATE, SaleDate) AS newSaleDate
FROM nashvillHousing

--UPDATE nashvillHousing
--SET SaleDate = CONVERT(DATE, SaleDate)

ALTER Table nashvillHousing
ADD newSalesDate DATE;

UPDATE nashvillHousing
SET newSalesDate = CONVERT(DATE, SaleDate)

SELECT *
FROM nashvillHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID


--Joining the two tables to check for the null propertyAddress and filling it
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
ISNULL(a.PropertyAddress, b.PropertyAddress) AS duplicatedProperty
FROM nashvillHousing a
JOIN nashvillHousing b
 ON a.ParcelID = b.ParcelID
 AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


--Filling the null propertyAddress
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM nashvillHousing a
JOIN nashvillHousing b
 ON a.ParcelID = b.ParcelID
 AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

SELECT PropertyAddress, TRIM(SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)) AS address,
TRIM(SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))) AS city
FROM nashvillHousing



ALTER Table nashvillHousing
ADD newAddress NvarChar(255);

UPDATE nashvillHousing
SET newAddress = TRIM(SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1))



ALTER Table nashvillHousing
ADD city NvarChar(255);

UPDATE nashvillHousing
SET city = TRIM(SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)))


SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM nashvillHousing



ALTER Table nashvillHousing
ADD newOwnerAddress NvarChar(255);

UPDATE nashvillHousing
SET newOwnerAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER Table nashvillHousing
ADD newOwnerCity NvarChar(255);

UPDATE nashvillHousing
SET newOwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER Table nashvillHousing
ADD newOwnerState NvarChar(255);

UPDATE nashvillHousing
SET newOwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM nashvillHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM nashvillHousing


UPDATE nashvillHousing
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM nashvillHousing



--Remove Duplicate


;WITH rowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
	LegalReference,
	PropertyAddress,
	SalePrice,
	SaleDate
	ORDER BY
	UniqueID) rowNum
FROM nashvillHousing
)

SELECT *
FROM rowNumCTE
WHERE rowNum > 1


ALTER TABLE nashvillHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE nashvillHousing
DROP COLUMN SaleDate


SELECT *
FROM nashvillHousing