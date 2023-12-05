-- FAD DATA IMPORT - KATO DATA - Manu 12/2023
-- Use this routine to import new data 
-- import all latest CSV tables first...


IF OBJECT_ID('tempdb..#Table_list') IS NOT NULL DROP TABLE #Table_list

-- deleting potential old DATA
-- Delete from kato.fad_buoy_all where source = 'KATO' and Year(CONVERT(DATE, transmission_datetime))=2023 and month(CONVERT(DATE, transmission_datetime))>=6

-- test reading table from folder

SELECT table_name into #table_list FROM information_schema.tables
WHERE table_schema='kato' AND table_type='BASE TABLE'
	AND Left(table_name,1)='K'
	
-- select * from #table_list
DECLARE @mPeriod as varchar(20)
DECLARE	@mOrigin AS nvarchar(50)
DECLARE @mDest AS nvarchar(50) = 'kato.fad_buoy_all'
DECLARE @mCompany as nvarchar(50) = null 
DECLARE	@mProvider as nvarchar(50) = 'KATO'
	
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
	
	print('Period: '+@mPeriod+' Origin:'+@mOrigin+' Dest:'+@mDest+' Company:'+Coalesce(@mCompany,'')+' Provider:'+@mProvider+'  ->  ')

	EXEC KATO.ImportVesselFAD_KATO @mPeriod, @mORigin, @mDest, @mCompany, @mProvider 
	
	SET @RowCount -= 1;  
END   

-- COMMIT
-- ROLLBACK

------------------------------------------------------
update FB
set vsl_name = vi.VesselName
from kato.fad_buoy_all FB
		left outer join ref.vessels v on FB.vsl_IMO = v.UVI
		join ref.vessel_instances vi on v.vessel_id = vi.vessel_id and FB.transmission_datetime between vi.start_date and vi.calculated_end_date
where FB.vsl_name is null and FB.vsl_IMO is not null

------------------------------------------------------
select * from kato.fad_buoy_all