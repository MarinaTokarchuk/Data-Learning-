--Cleaning Data in SQL Queries

select * from PortfolioProject.dbo.NashvilleHousing;




--1.Standartize Data Format
select SaleDateConverted, CONVERT(Date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing;

update NashvilleHousing
set SaleDate=CONVERT(Date,SaleDate);

Alter table NashvilleHousing
Add SaleDateConverted Date; 

update NashvilleHousing
set SaleDateConverted=CONVERT(Date,SaleDate);



--2.Populate Property Address Data
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null


--3. Breaking out address into individual columns (Address, City, State)
select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing

select 
substring (PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
, substring (PropertyAddress, CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress)) as City
from PortfolioProject.dbo.NashvilleHousing

alter table NashvilleHousing
Add PropertySeparatedAddress Nvarchar(255); 

update NashvilleHousing
set PropertySeparatedAddress=substring (PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1);

alter table NashvilleHousing
Add PropertySeparatedCity Nvarchar(255); 

update NashvilleHousing
set PropertySeparatedCity=substring (PropertyAddress, CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress));

select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing;

select
PARSENAME(Replace(OwnerAddress, ',','.'),1),
PARSENAME(Replace(OwnerAddress, ',','.'),2),
PARSENAME(Replace(OwnerAddress, ',','.'),3)
from PortfolioProject.dbo.NashvilleHousing;

alter table NashvilleHousing
Add OwnerSeparatedAddress Nvarchar(255); 

update NashvilleHousing
set OwnerSeparatedAddress=PARSENAME(Replace(OwnerAddress, ',','.'),3);

alter table NashvilleHousing
Add OwnerSeparatedCity Nvarchar(255); 

update NashvilleHousing
set OwnerSeparatedCity=PARSENAME(Replace(OwnerAddress, ',','.'),2);

alter table NashvilleHousing
Add OwnerSeparatedState Nvarchar(255); 

update NashvilleHousing
set OwnerSeparatedState=PARSENAME(Replace(OwnerAddress, ',','.'),1)


--4.Change Y and N to Yes and No in "SoldAsVacant" field


select distinct(SoldAsVacant), count(SoldAsVacant) as CountYN
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant 
order by CountYN desc


Select SoldAsVacant,
CASE When SoldAsVacant='N' then 'No'
	 When SoldAsVacant='Y' then 'Yes'
	 else SoldAsVacant
	 END
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant=CASE When SoldAsVacant='N' then 'No'
	 When SoldAsVacant='Y' then 'Yes'
	 else SoldAsVacant
	 END

--5.Remove Duplicates
select *
from PortfolioProject.dbo.NashvilleHousing;

with RowNumCTE AS( 
select *,
	Row_Number() over(
	Partition by ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 order by 
				  UniqueID
				) rom_num
from PortfolioProject.dbo.NashvilleHousing)
--order by ParcelID


delete -- 104 rows (duplicates) were deletaed
from RowNumCTE
where rom_num > 1;
--order by PropertyAddress

--6.Delete unused columns

SELECT * INTO DupTable
FROM PortfolioProject.dbo.NashvilleHousing;

select *
from DupTable
order by ParcelID;

alter table DupTable
drop column PropertyAddress, OwnerAddress, TaxDistrict;

select * from DupTable
order by 5;






alter table PortfolioProject.dbo.NashvilleHousing
drop column 


