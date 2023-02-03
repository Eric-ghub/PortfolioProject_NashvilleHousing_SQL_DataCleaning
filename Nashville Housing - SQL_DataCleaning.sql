
/*

CLEANING DATA IN SQL QUERIES 

*/

Select *
From PortfolioProject.dbo.NashvilleHousing

------------------------------------------

-- Standardize Date Format

Select SaleDate, CONVERT(Date, SaleDate)
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateCoverted Date

Update NashvilleHousing
SET SaleDateCoverted = CONVERT(Date, SaleDate)

Select SaleDateCoverted, CONVERT(Date, SaleDate)
From PortfolioProject.dbo.NashvilleHousing

-------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
    on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is Null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
    on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is Null

----------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address Into Individual Coloumns (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--Order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Adddress
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Adddress

From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


Select *
From PortfolioProject.dbo.NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

Select *
From PortfolioProject.dbo.NashvilleHousing

------------------------------------------------------------------------------------------------------------------------------------

-- Change 1 and 0 to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ALTER COLUMN SoldAsVacant nvarchar(255)


Select SoldAsVacant
, CASE When SoldAsVacant = 1 THEN 'Yes'
       When SoldAsVacant = 0 THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousing

Update PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 1 THEN 'Yes'
                        When SoldAsVacant = 0 THEN 'No'
	                    ELSE SoldAsVacant
	                    END

---------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
     ROW_NUMBER() OVER (
     PARTITION BY ParcelID,
	              PropertyAddress,
				  SalePrice,
				  LegalReference
				  ORDER BY
				     UniqueID
					 ) row_num

From PortfolioProject.dbo.NashvilleHousing
--Order by ParcelID
)
--DELETE 
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

-------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate
