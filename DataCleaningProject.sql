select *
from NashvilleHousing



---------------------------------------------------------------------------------------------------------------------------------------------------------

-- Standrardize Date Format


select SaleDate, CONVERT(date,saledate) as Date
from NashvilleHousing

update NashvilleHousing
set SaleDate=CONVERT(date,saledate)

ALTER TABLE NashvilleHousing 
ALTER COLUMN SaleDate DATE

---------------------------------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data


select t1.ParcelID, T1.PropertyAddress, t2.ParcelID, t2.PropertyAddress, ISNULL(T1.PropertyAddress, t2.PropertyAddress)
from NashvilleHousing as T1
join NashvilleHousing as T2
	on t1.ParcelID= t2.ParcelID and t1.[UniqueID ]<>t2.[UniqueID ]
where t1.PropertyAddress is null

update t1
set PropertyAddress = ISNULL(T1.PropertyAddress, t2.PropertyAddress)
from NashvilleHousing as T1
join NashvilleHousing as T2
	on t1.ParcelID= t2.ParcelID and t1.[UniqueID ]<>t2.[UniqueID ]
where t1.PropertyAddress is null


---------------------------------------------------------------------------------------------------------------------------------------------------------

--Splitting address into individual columns(address, city, state)

select *
from NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress VARCHAR(255),
    PropertySplitCity VARCHAR(255);
UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1),
    PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


alter table NashvilleHousing
ADD OwnerSplitAddress VARCHAR(255),
    OwnerSplitCity VARCHAR(255),
	OwnerSplitState VARCHAR(255);
Update NashvilleHousing
set OwnerSplitAddress= parsename(replace(owneraddress, ',','.'),3),
	OwnerSplitCity= parsename(replace(owneraddress, ',','.'),2),
	OwnerSplitState= parsename(replace(owneraddress, ',','.'),1)


---------------------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "sold as Vacant" Field

UPDATE NashvilleHousing
SET SoldAsVacant = CASE SoldAsVacant
                      WHEN 'Y' THEN 'Yes'
                      WHEN 'N' THEN 'No'
                      ELSE SoldAsVacant
                   END
WHERE SoldAsVacant IN ('Y', 'N');


---------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates


with RowNumCTE as(
select *,
	ROW_NUMBER() over (
	partition by parcelID,
				 Propertyaddress,
				 saledate,
				 saleprice,
				 Legalreference
				 order by UniqueID
				 ) row_num
from NashvilleHousing
)
select *
from RowNumCTE
where row_num>1

---------------------------------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



alter table NashvilleHousing
drop column owneraddress, propertyaddress

alter table NashvilleHousing
drop column saledate

select *
from NashvilleHousing
