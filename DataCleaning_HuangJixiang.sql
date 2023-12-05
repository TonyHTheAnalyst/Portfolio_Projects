/*
author: Huang Jixiang
data sourse: NashvilleHousing
purpose: data cleaning(ETL£©
*/


-------------------------------------------------------------------------------------------------------------------
-- Standardize Data Format
SELECT SaleDateConverted, convert(date, SaleDate)
FROM ProtfolioProject.dbo.NashvilleHousing

alter table NashvilleHousing
add SaleDateConverted date;

update NashvilleHousing
set SaleDateConverted = convert(date, SaleDate)


-------------------------------------------------------------------------------------------------------------------
--Populate Proterty Address Data
SELECT a.ParcelID, a.propertyAddress, b.ParcelID ,b.propertyAddress, ISNULL(a.propertyAddress,b.propertyAddress)
FROM ProtfolioProject.dbo.NashvilleHousing a
JOIN ProtfolioProject.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

update a
set propertyAddress = ISNULL(a.propertyAddress,b.propertyAddress)
FROM ProtfolioProject.dbo.NashvilleHousing a
JOIN ProtfolioProject.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL
 

 -------------------------------------------------------------------------------------------------------------------
--Breaking out address into individual columns (address, city ,state)
SELECT propertyAddress
FROM ProtfolioProject.dbo.NashvilleHousing


SELECT
SUBSTRING(propertyAddress,1, CHARINDEX(',',propertyAddress)-1) as Address
,SUBSTRING(propertyAddress, CHARINDEX(',',propertyAddress) + 1, LEN(propertyAddress)) as Address
From ProtfolioProject.dbo.NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress Nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(propertyAddress,1, CHARINDEX(',',propertyAddress)-1)

alter table NashvilleHousing
add PropertySplitCity Nvarchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(propertyAddress, CHARINDEX(',',propertyAddress) + 1, LEN(propertyAddress))

-------------------------------------------------------------------------------------------------------------------
--Split the OnwerAddress

SELECT 
PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
FROM ProtfolioProject.dbo.NashvilleHousing


alter table NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)

alter table NashvilleHousing
add OwnerSplitCity Nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2)

alter table NashvilleHousing
add OwnerSplitState Nvarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)

-------------------------------------------------------------------------------------------------------------------
--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), count(SoldAsVacant)
FROM ProtfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

Select SoldAsVacant
, case 
when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
END
FROM ProtfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case 
when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
END

-------------------------------------------------------------------------------------------------------------------
--Remove Duplicates

with RowNumCTE as(	--this funciton is make it to a temp table
Select * ,
	ROW_NUMBER()over(
	partition by ParcelID, --use partition by to make sure all of those rows are be one unit
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
				 UniqueID
				 )row_num
FROM ProtfolioProject.dbo.NashvilleHousing
)
	--make it to a temp table that we can use 'where' to select all the duplicate rows and delete it
delete
from RowNumCTE
where row_num >1


-------------------------------------------------------------------------------------------------------------------
-- Delete Unused Columns

alter table ProtfolioProject.dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress


