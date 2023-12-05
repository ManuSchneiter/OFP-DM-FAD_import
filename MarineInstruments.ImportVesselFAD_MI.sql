USE [fad_tracking]
GO

/****** Object:  StoredProcedure [marineinstruments].[ImportVesselFAD_MI]    Script Date: 5/12/2023 1:47:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [marineinstruments].[ImportVesselFAD_MI]
	@pPeriod as nvarchar(20) ,
  @pOrigin AS nvarchar(50) ,
  @pDest AS nvarchar(50),
	@pCompany as nvarchar(50), 
	@pProvider as nvarchar(50)
AS
BEGIN
		DECLARE @SQL nvarchar(2000)
		DECLARE @TableName nvarchar(50)
		
		SET @TableName = 'M-' + @pPeriod + '-'  + @pOrigin
		
		IF EXISTS(SELECT 1 FROM sys.Tables WHERE  Name = @TableName)
			BEGIN
		
				SET @SQL = 'INSERT into ' + @pDest + ' SELECT null, FACTORY_CODE, ''' + @pOrigin + ''',''' + coalesce(@pCompany,'') + ''', CONVERT(DATETIME, substring([Date],7,4)+''-''+substring([Date],4,2)+''-''+substring([Date],1,2)+'' ''+LEFT(cast(CONCAT(FLOOR([time]),'':'',([time]-FLOOR([time]))*100) as time),5)), latitude, longitude, DIRECTION, SPEED, TEMPERATURE,''' + @pProvider + ''', IMO, null, null from '+ @pProvider +'.[M-' + @pPeriod + '-'  + @pOrigin +']'

				--print @SQL
				print '		--> Table '+@TableName+' imported.'
				print ''
				
				EXEC (@SQL)

			END
END
GO

