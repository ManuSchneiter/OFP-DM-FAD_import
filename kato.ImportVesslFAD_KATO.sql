USE [fad_tracking]
GO

/****** Object:  StoredProcedure [kato].[ImportVesselFAD_KATO]    Script Date: 5/12/2023 1:46:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [kato].[ImportVesselFAD_KATO]
  @Period as nvarchar(20),
	@pOrigin AS nvarchar(50),
  @pDest AS nvarchar(50),
	@pCompany as nvarchar(50), 
	@pProvider as nvarchar(50)
AS
BEGIN
		DECLARE @SQL nvarchar(2000)
		DECLARE @TableName nvarchar(50)
		
		SET @TableName = 'K-' + @period + '-'  + @pOrigin
		
		IF EXISTS(SELECT 1 FROM sys.Tables WHERE  Name = @TableName)
			BEGIN
		
				SET @SQL = 'INSERT into ' + @pDest + ' SELECT null, BUOY, null,''' + coalesce(@pCompany,'') + ''', CONVERT(DATETIME, [Date/Time]), lat, long, null, speed, temp,''' + @pProvider + ''', IMO, Bat from ' + @pProvider + '.['+ @TableName +']'
				
				--print @SQL
				print '		--> Table '+@TableName+' imported.'
				print ''
				
				EXEC (@SQL)
				
			END
END
GO

