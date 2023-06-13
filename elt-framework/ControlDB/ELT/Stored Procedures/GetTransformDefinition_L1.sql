CREATE PROCEDURE [ELT].[GetTransformDefinition_L1] 
		@IngestID int, 
		@WatermarkDate datetime = null 			
AS
	--declare @IngestID int 
	DECLARE @localdate datetime	= CONVERT(datetime,CONVERT(datetimeoffset, getdate()) AT TIME ZONE 'AUS Eastern Standard Time')
	DECLARE @CuratedDate datetime
	SET @CuratedDate = COALESCE(@WatermarkDate,@localdate)


		SELECT 
			--PK/FK
			TD.[L1TransformID]
			, TD.[IngestID]

			
			--Databricks
			, TD.[NotebookName]
			, TD.[NotebookPath]
			
			--Custom
			, TD.[CustomParameters]

			 --Raw
			 ,TD.[InputRawFileDelimiter]
			 ,TD.[InputFileHeaderFlag]
			
			--Curated File
			,TD.[OutputEntityFileSystem]
			,TD.[OutputEntityFolder]

			--Watermark
			, [LookupColumns]
			, TD.[OutputEntityName]
			, TD.[OutputEntityWriteMode]

			--Max Retries
			, TD.[MaxRetries]
			

		FROM
			[ELT].[L1TransformDefinition] TD
				LEFT JOIN [ELT].[IngestDefinition] ID
					ON TD.[IngestID] = ID.[IngestID]
		WHERE 
			TD.[IngestID] = @IngestID and 
			TD.[ActiveFlag] = 1 
			and ID.[ActiveFlag] = 1 
			and ID.[L1TransformationReqdFlag] =1
GO


