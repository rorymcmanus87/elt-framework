﻿CREATE PROCEDURE [ELT].[GetTransformDefinition_L2] 
		@IngestID int, 
		@WatermarkDate datetime = null,
		@InputType varchar(15) = '%'
AS
	--declare @IngestID int
	DECLARE @localdate datetime	= CONVERT(datetime,CONVERT(datetimeoffset, getdate()) at time zone 'AUS Eastern Standard Time')

	--Should be using L2WatermarkTransformDate, if null then LocalDate
		SELECT
			--PK/FK
			TD.[L2TransformID]
			, TD.[IngestID]
			, TD.[L1TransformID]

			--Databricks
			, TD.[NotebookName]
			, TD.[NotebookPath]

			--Custom
			, TD.[CustomParameters]

			--InputType
			,TD.[InputType]

			 --Raw
			,TD.[InputFileSystem]
			,TD.[InputFileFolder]
			,TD.[InputFile]
			,TD.[InputFileDelimiter]
			,TD.[InputFileHeaderFlag]
			
			--InputEntity
			,TD.[InputEntityName]
			,TD.[WatermarkName]
			
			--Watermarks
			,[DataFromTimestamp] = NULL
			,[DataToTimestamp] = NULL
			,[DataFromNumber] = NULL
			,[DataToNumber] = NULL
			,TD.[MaxIntervalMinutes]
			,TD.[MaxIntervalNumber]
			

			--Retry
			,TD.[MaxRetries]

			--Curated File
			--Need to test how this performs with a file drop and filedrop reload. Possibly use date drop file was dropped?
			,TD.[OutputL2CurateFileSystem]
		
			,[OutputL2CuratedFolder] = 
					REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(TD.[OutputL2CuratedFolder] COLLATE SQL_Latin1_General_CP1_CS_AS
					,'YYYY',CAST(Year(COALESCE(TD.[LastWatermarkDate],@WatermarkDate,@localdate)) as varchar(4)))
					,'MM',Right('0'+ CAST(Month(COALESCE(TD.[LastWatermarkDate],@WatermarkDate,@localdate)) AS varchar(2)),2))
					,'DD',Right('0'+Cast(Day(COALESCE(TD.[LastWatermarkDate],@localdate)) as varchar(2)),2))
					,'HH',Right('0'+ CAST(DatePart(hh,COALESCE(TD.[LastWatermarkDate],@WatermarkDate,@localdate)) as varchar(2)),2))
					,'MI',Right('0'+ CAST(DatePart(mi,COALESCE(TD.[LastWatermarkDate],@WatermarkDate,@localdate)) as varchar(2)),2))
					,'SS',Right('0'+ CAST(DatePart(ss,COALESCE(TD.[LastWatermarkDate],@WatermarkDate,@localdate)) as varchar(2)),2))

			,[OutputL2CuratedFile] = 
					REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(TD.[OutputL2CuratedFile] COLLATE SQL_Latin1_General_CP1_CS_AS
					,'YYYY',CAST(Year(COALESCE(TD.[LastWatermarkDate],@WatermarkDate,@localdate)) as varchar(4)))
					,'MM',Right('0'+ CAST(Month(COALESCE(TD.[LastWatermarkDate],@WatermarkDate,@localdate)) AS varchar(2)),2))
					,'DD',Right('0'+Cast(Day(COALESCE(TD.[LastWatermarkDate],@WatermarkDate,@localdate)) as varchar(2)),2))
					,'HH',Right('0'+ CAST(DatePart(hh,COALESCE(TD.[LastWatermarkDate],@WatermarkDate,@localdate)) as varchar(2)),2))
					,'MI',Right('0'+ CAST(DatePart(mi,COALESCE(TD.[LastWatermarkDate],@WatermarkDate,@localdate)) as varchar(2)),2))
					,'SS',Right('0'+ CAST(DatePart(ss,COALESCE(TD.[LastWatermarkDate],@WatermarkDate,@localdate)) as varchar(2)),2))

			, TD.[OutputL2CuratedFileDelimiter]
			, TD.[OutputL2CuratedFileFormat]
			, TD.[OutputL2CuratedFileWriteMode]

			--SQL
			,TD.[OutputEntityName]
			,TD.[OutputEntityFileSystem]
			,TD.[OutputEntityFolder]
			,TD.[OutputEntityWriteMode]
			,TD.[LookupColumns]
			

		FROM
			[ELT].[L2TransformDefinition] TD
				LEFT JOIN [ELT].[IngestDefinition] ID
					ON TD.[IngestID] = ID.[IngestID]
		WHERE 
			TD.[IngestID] = @IngestID and 
			TD.[ActiveFlag] = 1
			and ID.[ActiveFlag] = 1
			and ID.[L2TransformationReqdFlag] =1
			and TD.[InputType] like COALESCE(@InputType,TD.[InputType])
GO


