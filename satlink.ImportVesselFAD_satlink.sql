USE [fad_tracking]
GO

/****** Object:  StoredProcedure [satlink].[ImportVesselFAD_satlink]    Script Date: 5/12/2023 1:47:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [satlink].[ImportVesselFAD_satlink]
	@pPeriod as nvarchar(20),
  @pOrigin AS nvarchar(50),
  @pDest AS nvarchar(50),
	@pCompany as nvarchar(50), 
	@pProvider as nvarchar(50)
AS
BEGIN
		DECLARE @SQL nvarchar(3000)
		DECLARE @TableName nvarchar(100)
		
		SET @TableName = 'S-' + @pPeriod + '-'  + @pOrigin
		--print @TableName
		IF EXISTS(SELECT 1 FROM sys.Tables T WHERE  T.[name] = @TableName)
			BEGIN
		
				SET @SQL = 'INSERT into ' + @pDest + ' SELECT null, Name, null,''' + Coalesce(@pCompany,'') + ''', CONVERT(DATETIME, substring([Date],7,4)+''-''+substring([Date],4,2)+''-''+substring([Date],1,2)+'' ''+LEFT(cast(CONCAT(FLOOR([time]),'':'',([time]-FLOOR([time]))*100) as time),5)), latitude, longitude, null, speed, temp,''' + @pProvider + ''',Owner_IMO, CONVERT(DATETIME, substring(LastActivation,7,4)+''-''+substring(LastActivation,4,2)+''-''+substring(LastActivation,1,2)), CONVERT(DATETIME, substring(LastDeactivation,7,4)+''-''+substring(LastDeactivation,4,2)+''-''+substring(LastDeactivation,1,2)) from '+ @pProvider +'.[' + @TableName +']'

				--print @SQL
				print '		--> Table '+@TableName+' imported.'
				print ''
				
				EXEC (@SQL)
			END
END
GO

