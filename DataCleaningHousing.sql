
/*

Cleaning Data in SQL Queries

*/


Select *
From Portfolio.dbo.NashvilleHousing



-- Standardize Date Format

Select SaleDate, CONVERT(date, SaleDate)
From Portfolio.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(date, SaleDate)

Select SaleDateConverted, CONVERT(date, SaleDate)
From Portfolio.dbo.NashvilleHousing



-- Populate Property Address Data

select *
from Portfolio..NashvilleHousing
--where PropertyAddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.PropertyAddress)
from Portfolio..NashvilleHousing a
Join Portfolio..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


update a
set PropertyAddress = ISNULL(a.propertyaddress, b.PropertyAddress)
from Portfolio..NashvilleHousing a
Join Portfolio..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

select *
from Portfolio..NashvilleHousing
where PropertyAddress is null
order by ParcelID

-- Breaking out Address into Individual Columns (Address, City, State)

select Propertyaddress
from Portfolio..NashvilleHousing

select 
SUBSTRING(propertyaddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(propertyaddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
from Portfolio..NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter Table NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(propertyaddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

select *
from Portfolio..NashvilleHousing


select OwnerAddress
from Portfolio..NashvilleHousing

select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3) as OwnerSplitAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2) as OwnerSplitCity,
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1) as OwnerSplitState
from Portfolio..NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

Alter Table NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

Alter Table NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)


select *
from Portfolio..NashvilleHousing

-- Change Y and N to yes and No in "Sold as Vacant" field

select Distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
group by (SoldAsVacant)
order by 2


select SoldAsVacant,
case When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	Else SoldAsVacant
	END
from NashvilleHousing

update NashvilleHousing
Set SoldAsVacant = case When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	Else SoldAsVacant
	END


select Distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
group by (SoldAsVacant)
order by 2




-- Create View for the columns you want to keep
Create View UpdatedHousing as
select [UniqueID ], ParcelID, LandUse, PropertySplitAddress, PropertySplitCity, SalePrice, SoldAsVacant, OwnerName, OwnerSplitAddress, OwnerSplitCity,
	OwnerSplitState, Acreage, LandValue, BuildingValue, TotalValue, YearBuilt, Bedrooms, FullBath, HalfBath, SaleDateConverted 
from Portfolio..NashvilleHousing


select *
from Portfolio..UpdatedHousing

--Now this data is ready to be used for any necessary analysis!