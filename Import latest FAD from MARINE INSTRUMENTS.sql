-- FAD DATA IMPORT - MARINE INSTRUMENTS DATA - Manu 12/2023
-- Use this routine to import new data 
-- import all latest CSV tables first...


IF OBJECT_ID('tempdb..#Table_list') IS NOT NULL DROP TABLE #Table_list

-- deleting potential old DATA
-- Delete from marineinstruments.fad_buoy_all where Year(CONVERT(DATE, transmission_datetime))=2023 and month(CONVERT(DATE, transmission_datetime))>=6

DECLARE	@mProvider as nvarchar(50) = 'marineinstruments'
DECLARE @mPeriod as varchar(20)
DECLARE	@mOrigin AS nvarchar(50)
DECLARE @mDest AS nvarchar(50) = @mProvider+'.fad_buoy_all'
DECLARE @mCompany as nvarchar(50) = '' 
DECLARE @mCode as nvarchar(200)

-- test reading table from folder

SELECT table_name into #table_list FROM information_schema.tables
WHERE table_schema = @mProvider AND table_type='BASE TABLE'
	AND Left(table_name,2)='M-'
	
-- select * from #table_list
	
DECLARE @RowCount INT = (SELECT COUNT(*) FROM #table_List)
DECLARE @NameVar varchar(100)

select @RowCount

BEGIN TRANSACTION

WHILE @RowCount > 0 BEGIN  
	SELECT @NameVar = [table_name]   
	FROM #table_list   
	ORDER BY Table_name DESC OFFSET @RowCount - 1 ROWS FETCH NEXT 1 ROWS ONLY;  
		 
	SET @mPeriod = substring(@NameVar,3,7)
	SET @mOrigin = right(@NameVar,len(@NameVar)-10)
	
	--print('Period: '+@mPeriod+' Origin:'+@mOrigin+' Dest:'+@mDest+' Company:'+Coalesce(@mCompany,'')+' Provider:'''+@mProvider+'''  ->  ')

	SET @mCode = @mProvider + '.ImportVesselFAD_MI''' + @mPeriod +''',''' + @mORigin +''',''' + @mDest + ''',''' + @mCompany +''',''' + @mProvider + ''''
	print (@mCode)
	EXEC (@mCode)
	
	--OLD - EXEC marineinstruments.ImportVesselFAD @mPeriod, @mORigin, @mDest, @mCompany, @mProvider 
	
	SET @RowCount -= 1;  
END   

-- COMMIT
-- ROLLBACK


-- step1: Updating the UVI in main table, from vesselname

update FB
set vsl_IMO = v.UVI
from marineinstruments.fad_buoy_all FB
		left outer join ref.vessel_instances vi on FB.vsl_name COLLATE DATABASE_DEFAULT = vi.vesselname COLLATE DATABASE_DEFAULT and FB.transmission_datetime between vi.start_date and vi.calculated_end_date 
		join ref.vessels v on vi.vessel_id = v.vessel_id
where FB.vsl_IMO is null and FB.vsl_name is not null

-- Step2: Updating the missing UVIs from Conversion table

UPDATE FB
set vsl_IMO = VC.vsl_IMO
FROM marineinstruments.fad_buoy_all FB inner join marineinstruments.Vess_conversion VC on FB.vsl_name = VC.vsl_name
WHERE FB.vsl_IMO is null

-- Step3: adding missing vessel/UVI correspondance into conversion table, to finish the UVI searching process

insert into marineinstruments.Vess_conversion select distinct vsl_name, null as vsl_IMO from marineinstruments.fad_buoy_all where vsl_IMO is null

-- ADD THE MISSING UVI CORRESPONDANCE IN marineinstruments.Vess_conversion TABLE BEFORE RUNNING THE FOLLOWING CODE
-- Then rerun STEP2

