

Select *
From NashvilleHousing.dbo.HousingData


--Changing Date Format

Alter table NashvilleHousing.dbo.HousingData
add SaleDateConverted date;

update NashvilleHousing.dbo.HousingData
set SaleDateConverted = Convert(Date, SaleDate)

Select SaleDateConverted
From NashvilleHousing.dbo.HousingData


--Property Address

Select *
From NashvilleHousing.dbo.HousingData
--Where PropertyAddress is NULL
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing.dbo.HousingData a
JOIN NashvilleHousing.dbo.HousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing.dbo.HousingData a
JOIN NashvilleHousing.dbo.HousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null



--Splitting up Property Address into (Address, city)

Select PropertyAddress
From NashvilleHousing.dbo.HousingData
--Where PropertyAddress is null
--order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address
From NashvilleHousing.dbo.HousingData

ALTER TABLE NashvilleHousing.dbo.HousingData
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing.dbo.HousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing.dbo.HousingData
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing.dbo.HousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select *
From NashvilleHousing.dbo.HousingData



--Splitting up Owner Address into (Address, city, state)

Select OwnerAddress
From NashvilleHousing.dbo.HousingData

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From NashvilleHousing.dbo.HousingData


ALTER TABLE NashvilleHousing.dbo.HousingData
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing.dbo.HousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing.dbo.HousingData
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing.dbo.HousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE NashvilleHousing.dbo.HousingData
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing.dbo.HousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From NashvilleHousing.dbo.HousingData



--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing.dbo.HousingData
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From NashvilleHousing.dbo.HousingData

Update NashvilleHousing.dbo.HousingData
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END



--Removing the Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From NashvilleHousing.dbo.HousingData
)
Select *
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

Select *
From NashvilleHousing.dbo.HousingData



--Remove unused columns

Select *
From NashvilleHousing.dbo.HousingData


ALTER TABLE NashvilleHousing.dbo.HousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate




