SELECT *
FROM NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT saleDateConverted, CONVERT(Date,SaleDate)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From NashvilleHousing
--WHERE PropertyAddress is NULL
ORDER BY ParcelID

Select a.ParcelID , b.ParcelID, b.PropertyAddress , ISNULL (a.PropertyAddress , b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

UPDATE a 
SET PropertyAddress = ISNULL (a.PropertyAddress , b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address inti Individualcolumns (Address, City, State)

SELECT PropertyAddress
FROM NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress , 1 , CHARINDEX(',',PropertyAddress)-1) AS Address , 
SUBSTRING(PropertyAddress , CHARINDEX(',',PropertyAddress)+1 , LEN (PropertyAddress)) AS Address
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress , 1 , CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress , CHARINDEX(',',PropertyAddress) + 1 , LEN (PropertyAddress))


SELECT OwnerAddress
FROM NashvilleHousing

SELECT OwnerAddress , SUBSTRING(OwnerAddress ,1,CHARINDEX (',' ,OwnerAddress)-1) AS OwnerSplitAddress,
 SUBSTRING(OwnerAddress , CHARINDEX(',',OwnerAddress) + 1 , LEN (OwnerAddress)-CHARINDEX(',',OwnerAddress)-4) AS OwnerSplitCity ,
SUBSTRING(OwnerAddress ,LEN(OwnerAddress)-2 ,LEN(OwnerAddress)) AS OwnerSplitState 
FROM NashvilleHousing

--- Other way to do it.

SELECT PARSENAME(REPLACE(OwnerAddress,',','.') , 3 ),
PARSENAME(REPLACE(OwnerAddress,',','.') , 2 ),
PARSENAME(REPLACE(OwnerAddress,',','.') , 1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress VARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.') , 3 )

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity VARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.') , 2 )

ALTER TABLE NashvilleHousing
ADD OwnerSplitState VARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.') , 1 )

--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant


SELECT SoldAsVacant,
CASE 
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

--------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
WITH ROW_NUM AS (
SELECT *,
    ROW_NUMBER() OVER (
	PARTITION BY ParcelID ,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
				  UniqueID
				  ) row_num
FROM NashvilleHousing
)
DELETE
FROM ROW_NUM
WHERE row_num > 1


--------------------------------------------------------------------------------------------------------------------------

--DELETE UNUSED COLUMNS

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict , PropertyAddress , saledate