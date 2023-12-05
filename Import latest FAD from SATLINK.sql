-- FAD DATA IMPORT - SATLINK DATA - Manu 12/2023
-- Use this routine to import new Satlink data 
-- import all latest CSV first...


-- deleting potential old DATA
--delete from satlink.fad_buoy_all where source = 'SATLINK' and year(transmission_datetime)=2023 and month(transmission_datetime)>9
--Delete from dbo.fad_buoy_all where source = 'SATLINK'-- where year(transmission_datetime)=2023

------------------------------------------------------------------------
/* tests
satlink.ImportVesselFAD '2023-10','6717801-P','satlink.fad_buoy_all','','satlink'

SELECT * FROM sys.Tables WHERE  Name = 'S-2023-09-6717801-P'

IF EXISTS(SELECT 1 FROM sys.Tables T WHERE  T.[name] = 'S-2023-09-6717801-P')
	BEGIN	
		print ('table exist')
	END
*/
------------------------------------------------------------------------

IF OBJECT_ID('tempdb..#Table_list') IS NOT NULL DROP TABLE #Table_list

DECLARE	@mProvider as nvarchar(50) = 'satlink'
DECLARE @mPeriod as varchar(20)
DECLARE	@mOrigin AS nvarchar(50)
DECLARE @mDest AS nvarchar(50) = @mProvider+'.fad_buoy_all'
DECLARE @mCompany as nvarchar(50) = '' 
DECLARE @mCode as nvarchar(200)

-- test reading table from folder

SELECT table_name into #table_list FROM information_schema.tables
WHERE table_schema = @mProvider AND table_type='BASE TABLE'
	AND Left(table_name,2)='S-'
	
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

	SET @mCode = @mProvider + '.ImportVesselFAD_satlink''' + @mPeriod +''',''' + @mOrigin +''',''' + @mDest + ''',''' + @mCompany +''',''' + @mProvider + ''''
	print (@mCode)
	EXEC (@mCode)
	
	--OLD - EXEC marineinstruments.ImportVesselFAD @mPeriod, @mORigin, @mDest, @mCompany, @mProvider 
	
	SET @RowCount -= 1;  
END   

-- COMMIT
-- ROLLBACK

update FB
set vsl_name = vi.VesselName
from satlink.fad_buoy_all FB
		left outer join ref.vessels v on FB.vsl_IMO = v.UVI
		join ref.vessel_instances vi on v.vessel_id = vi.vessel_id and FB.transmission_datetime between vi.start_date and vi.calculated_end_date
where FB.vsl_name is null and FB.vsl_IMO is not null

