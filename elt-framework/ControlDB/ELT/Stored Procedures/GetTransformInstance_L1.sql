﻿CREATE PROCEDURE [ELT].[GetTransformInstance_L1]
	@SourceSystemName varchar(20),
	@StreamName varchar(100) = '%',
	@MaxTransformInstance int = 10,
	@L1TransformInstanceId INT = NULL, --To fetch all transform instances set Parameter as NULL otherwise provide a specific instance id
	@DelayL1TransformationFlag INT=NULL --Pass @DelayL1TransformationFlag=0 to fetch all instances that needs to be transformed in the current pipeline (usually the ingestion pipeline). Pass @DelayL1TransformationFlag=1 to fetch all transformations that are scheduled for a later time.
AS
begin
	--Limit Number of Transform Instances to prevent queuing at DWH
		SELECT top (@MaxTransformInstance) 
			L1TI.[L1TransformInstanceID]
			, L1TI.[L1TransformID]
			, L1TI.[IngestID]	
			, L1TD.[MaxRetries]
			, L1TI.[NotebookName]
			, L1TI.[NotebookPath]
			

			--Notebook Parameters
			,NotebookParameters = 
				(
					SELECT 
					L1TI.[L1TransformInstanceID]
					, L1TD.[CustomParameters]
					, L1TI.[InputRawFileSystem]
					, L1TI.[InputRawFileFolder]
					, L1TI.[InputRawFile]
					, L1TI.[InputRawFileDelimiter]
					, L1TI.[InputFileHeaderFlag]
					, L1TI.[OutputEntityFileSystem]
					, L1TI.[OutputEntityFolder]
					, L1TI.[LookupColumns]
					, L1TI.[OutputEntityName]
					, L1TI.[OutputEntityWriteMode]
					, L1TD.[WatermarkName]
					, L1TI.[ReRunL1TransformFlag]
					 FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES
				)
			
			
		FROM 
			[ELT].[L1TransformInstance] as L1TI
				LEFT JOIN [ELT].[L1TransformDefinition] as L1TD
					ON L1TI.[L1TransformID] = L1TD.[L1TransformID]
				LEFT JOIN [ELT].[IngestDefinition] as ID
					ON id.[IngestID]= L1TD.[IngestID]		
			WHERE 
				ID.[SourceSystemName] =@SourceSystemName
				AND ID.[StreamName] like COALESCE(@StreamName,id.[StreamName])
				AND (ID.ActiveFlag = 1 AND L1TD.ActiveFlag = 1)
				AND (L1TI.[ActiveFlag]=1 OR L1TI.[ReRunL1TransformFlag]=1)
				AND L1TI.[L1TransformInstanceID] = COALESCE(@L1TransformInstanceId, L1TI.[L1TransformInstanceID])
				AND (L1TI.[L1TransformStatus] IS NULL OR L1TI.[L1TransformStatus] NOT IN ('Running','DWUpload'))  --Fetch new instances and ignore instances that are currently running
				AND ID.[DelayL1TransformationFlag] = COALESCE(@DelayL1TransformationFlag,ID.[DelayL1TransformationFlag])
				AND ISNULL(L1TI.RetryCount,0) <= L1TD.MaxRetries
			ORDER BY L1TI.[L1TransformInstanceID] ASC
END
GO


