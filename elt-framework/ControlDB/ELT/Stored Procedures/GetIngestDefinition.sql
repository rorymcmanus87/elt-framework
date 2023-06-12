CREATE PROCEDURE [ELT].[GetIngestDefinition]
	@SourceSystemName varchar(20),
	@StreamName VARCHAR(100) = '%', --Default =All Streams
	@MaxIngestInstance INT = 10
	
AS
BEGIN
	
		DECLARE @localdate as datetime	= CONVERT(datetime,CONVERT(datetimeoffset, getdate()) at time zone 'AUS Eastern Standard Time');

		

with 
	cte
as

(	--Normal Run
			SELECT 
				 [IngestID]
				,[SourceSystemName]
				,[StreamName]
				,[Backend]
				,[EntityName]
				,[WatermarkName]
				
				--Watermark Dates
				,[LastWatermarkDate]
				,[DataFromTimestamp] = 
								CASE 
									WHEN ([EntityName] IS NOT NULL AND [LastWatermarkDate] IS NOT NULL) THEN [LastWatermarkDate]
									ELSE CAST('1900-01-01' AS DateTime)
								END
				,[DataToTimestamp] = 
							CASE 
								WHEN ([EntityName] IS NOT NULL AND [LastWatermarkDate] IS NOT NULL AND [MaxIntervalMinutes] IS NOT NULL AND datediff_big(minute,[LastWatermarkDate],@localdate) > [MaxIntervalMinutes]) THEN DateAdd(minute,[MaxIntervalMinutes],[LastWatermarkDate])
								WHEN ([EntityName] IS NOT NULL AND [LastWatermarkDate] IS NOT NULL AND [MaxIntervalMinutes] IS NOT NULL AND datediff_big(minute,[LastWatermarkDate],@localdate) <= [MaxIntervalMinutes]) THEN CONVERT(VARCHAR(23),@localdate,120)
								ELSE CONVERT(VARCHAR(23),@localdate,120) 
							END

				--Watermark Numbers
				,[LastWatermarkNumber]
				,[DataFromNumber] = 
							CASE 
								WHEN ([EntityName] IS NOT NULL AND [LastWatermarkNumber] IS NOT NULL) THEN [LastWatermarkNumber]
					  END
				,[DataToNumber] = 
								CASE 
									WHEN ([EntityName] IS NOT NULL AND [LastWatermarkNumber] IS NOT NULL) THEN ([LastWatermarkNumber] + [MaxIntervalNumber])
					   END

				,[DataFormat]
				,[SourceStructure]
				,[MaxIntervalMinutes]
				,[MaxIntervalNumber]
				,[DataMapping]
				,[RunSequence]
				,[ActiveFlag]
				,[L1TransformationReqdFlag]
				,[L2TransformationReqdFlag]
				,[DelayL1TransformationFlag]
				,[DelayL2TransformationFlag]
				,[DestinationRawFileSystem]
		
			--Derived Fields
				,[DestinationRawFolder] = 
					REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE([DestinationRawFolder] COLLATE SQL_Latin1_General_CP1_CS_AS
					,'YYYY',CAST(Year(COALESCE([LastWatermarkDate],@localdate)) as varchar(4)))
					,'MM',Right('0'+ CAST(Month(COALESCE([LastWatermarkDate],@localdate)) AS varchar(2)),2))
					,'DD',Right('0'+Cast(Day(COALESCE([LastWatermarkDate],@localdate)) as varchar(2)),2))
					,'HH',Right('0'+ CAST(DatePart(hh,COALESCE([LastWatermarkDate],@localdate)) as varchar(2)),2))
					,'MI',Right('0'+ CAST(DatePart(mi,COALESCE([LastWatermarkDate],@localdate)) as varchar(2)),2))
					,'SS',Right('0'+ CAST(DatePart(ss,COALESCE([LastWatermarkDate],@localdate)) as varchar(2)),2))
			
				,[DestinationRawFile] = 
					REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE([DestinationRawFile] COLLATE SQL_Latin1_General_CP1_CS_AS
					,'YYYY',CAST(Year(COALESCE([LastWatermarkDate],@localdate)) AS varchar(4)))
					,'MM',Right('0'+ CAST(Month(COALESCE([LastWatermarkDate],@localdate)) AS varchar(2)),2))
					,'DD',Right('0'+Cast(Day(COALESCE([LastWatermarkDate],@localdate)) as varchar(2)),2))
					,'HH',Right('0'+ CAST(DatePart(hh,COALESCE([LastWatermarkDate],@localdate)) AS varchar(2)),2))
					,'MI',Right('0'+ CAST(DatePart(mi,COALESCE([LastWatermarkDate],@localdate)) AS varchar(2)),2))
					,'SS',Right('0'+ CAST(DatePart(ss,COALESCE([LastWatermarkDate],@localdate)) AS varchar(2)),2))			


			--Query
				,SourceQuery = 
					CASE
					-- Customized for simple Purview ATLAS API
					   WHEN Backend IN ('ATLAS REST API','AZURE REST API') THEN EntityName 

					-- Salesforce
					   WHEN Backend IN ('Salesforce - Cloud') THEN [ELT].[uf_GetSalesforceQuery]('SourceQuery', IngestID, EntityName, WatermarkName, LastWatermarkDate, NULL, MaxIntervalMinutes)

					--ADX
					 WHEN Backend = 'ADX - Database' THEN [ELT].[uf_GetADXQuery]('SourceQuery', IngestID, EntityName, WatermarkName, LastWatermarkDate, NULL, MaxIntervalMinutes)

					 --DEFAULT ANSI SQL for Watermark Table
						WHEN [EntityName] IS NOT NULL AND [WatermarkName] IS NOT NULL AND [LastWatermarkDate] IS NOT NULL
							THEN 
								CASE 
									WHEN datediff_big(minute,[LastWatermarkDate],@localdate) > [MaxIntervalMinutes]
										THEN 
											'SELECT * FROM ' + [EntityName] + ' WHERE ' 
											+ [WatermarkName] + ' > ' + ''''+CONVERT(VARCHAR(23),[LastWatermarkDate],121) +''''+ ' AND ' + [WatermarkName] + '<=' +  ''''+ CONVERT(VARCHAR(23), DATEADD(minute,[MaxIntervalMinutes],[LastWatermarkDate]),121) +''''
									ELSE 
										'SELECT * FROM ' + [EntityName] + ' WHERE ' 
										+ [WatermarkName] + ' > ' + ''''+ CONVERT(VARCHAR(23),[LastWatermarkDate],121) +''''+ ' AND ' + [WatermarkName] + '<='  + ''''+ CONVERT(VARCHAR(23), @localdate,120) +''''
								END
					 --DEFAULT ANSI SQL for Full Table
						WHEN [EntityName] IS NOT NULL AND [WatermarkName] IS NULL
							THEN 
								'SELECT * FROM ' + [EntityName]
					--Running Number
						WHEN [EntityName] IS NOT NULL AND [WatermarkName] IS NOT NULL AND [LastWatermarkNumber] IS NOT NULL
							THEN 'SELECT * FROM ' + [EntityName] + ' WHERE ' 
												+ [WatermarkName] + ' > ' + ''''+CONVERT(VARCHAR,[LastWatermarkNumber]) +'''' + [WatermarkName] + ' <= ' + ''''+CONVERT(VARCHAR,([LastWatermarkNumber] + [MaxIntervalNumber])) +''''
						ELSE NULL
					 END
			
			--Stats Query
				,StatQuery = 
					
					CASE 
						-- Customized for simple Purview ATLAS API
					   WHEN Backend IN ('ATLAS REST API','AZURE REST API') THEN EntityName 

					   -- Salesforce
					   WHEN Backend IN ('Salesforce - Cloud') 
						THEN [ELT].[uf_GetSalesforceQuery]('StatQuery', IngestID, [EntityName], [WatermarkName], [LastWatermarkDate], NULL, [MaxIntervalMinutes])

						--ADX
						WHEN Backend = 'ADX - Database' 
							THEN [ELT].[uf_GetADXQuery]('StatQuery', IngestID, EntityName, WatermarkName, LastWatermarkDate, NULL, MaxIntervalMinutes)

						--DEFAULT ANSI SQL For Watermark Table
						WHEN [EntityName] IS NOT NULL AND [WatermarkName] IS NOT NULL AND [LastWatermarkDate] IS NOT NULL
								THEN 
									CASE 
										WHEN datediff_big(minute,[LastWatermarkDate],@localdate) > [MaxIntervalMinutes] 
											THEN 
												'SELECT MIN('+[WatermarkName]+') AS DataFromTimestamp, MAX('+[WatermarkName]+') AS DataToTimestamp, count(1) as SourceCount FROM ' + [EntityName] + ' WHERE ' 
												+ [WatermarkName] + ' > ' + ''''+CONVERT(varchar(23),[LastWatermarkDate],121)+''''+ ' AND ' + [WatermarkName] + ' <= ' + ''''+CONVERT(VARCHAR(23), DATEADD(minute,[MaxIntervalMinutes],[LastWatermarkDate]),121)+''''
										ELSE 
											'SELECT MIN('+[WatermarkName]+') AS DataFromTimestamp, MAX('+[WatermarkName]+') AS DataToTimestamp, count(1) as SourceCount FROM ' + [EntityName] + ' WHERE ' 
											+ [WatermarkName] + ' > ' + ''''+CONVERT(VARCHAR(23),[LastWatermarkDate],121) +''''+ ' AND ' + [WatermarkName] + ' <= ' + ''''+ CONVERT(VARCHAR(23),(@localdate),120)+''''
										END
						--Common No Watermark
							WHEN [EntityName] IS NOT NULL AND [WatermarkName] IS NULL
								THEN 'SELECT ''1900-01-01 00:00:00'' AS DataFromTimestamp, '''+CONVERT(VARCHAR(23),ELT.uf_GetAestDateTime(),120)+''' AS DataToTimestamp,  COUNT(*) AS SourceCount FROM ' + [EntityName]
						--Running Number
							WHEN [EntityName] IS NOT NULL AND [WatermarkName] IS NOT NULL AND [LastWatermarkNumber] IS NOT NULL
									THEN 'SELECT MIN('+[WatermarkName]+') AS DataFromTimestamp,' + ' MAX('+[WatermarkName]+') AS DataToTimestamp,'+ 'COUNT(*) AS SourceCount FROM ' + [EntityName]
													+ [WatermarkName] + ' > ' + ''''+CONVERT(VARCHAR,[LastWatermarkNumber])+'''' + ' AND ' + [WatermarkName] + ' <= ' + ''''+CONVERT(VARCHAR,([LastWatermarkNumber] + [MaxIntervalNumber]))+''''
							ELSE NULL
					 END

				, CAST(0 AS BIT) AS [ReloadFlag]
				, NULL AS [ADFPipelineRunID]
			FROM 
				[ELT].[IngestDefinition]
			WHERE 
				[SourceSystemName]=@SourceSystemName
				AND [StreamName] LIKE COALESCE(@StreamName, [StreamName])
				AND [ActiveFlag]=1

--ReRun
UNION
		SELECT 
				[ID].[IngestID]
				,[SourceSystemName]
				,[StreamName]
				,[Backend]
				,[EntityName]
				,[WatermarkName]
				,[LastWatermarkDate]
				,II.[DataFromTimestamp]
				,II.[DataToTimestamp]
				,ID.[LastWatermarkNumber]
				,II.[DataFromNumber]
				,II.[DataToNumber]
				,[DataFormat]
				,[SourceStructure]
				,ID.[MaxIntervalMinutes]
				,ID.[MaxIntervalNumber]
				,ID.[DataMapping]
				,ID.[RunSequence]
				,[ActiveFlag]
				,[L1TransformationReqdFlag]
				,[L2TransformationReqdFlag]
				,[DelayL1TransformationFlag]
				,[DelayL2TransformationFlag]
				,II.[DestinationRawFileSystem]
				,II.[DestinationRawFolder]
				,II.[DestinationRawFile] 		
			
				--Derived Fields
				,SourceQuery = 
					CASE
						-- Customized for simple Purview ATLAS API
					    WHEN Backend IN ('ATLAS REST API','AZURE REST API') THEN EntityName 

						-- Salesforce
					   WHEN Backend IN ('Salesforce - Cloud') THEN [ELT].[uf_GetSalesforceQuery]('SourceQuery', ID.[IngestID], [EntityName], [WatermarkName], II.DataFromTimestamp,  II.[DataToTimestamp], NULL)

						--ADX
						WHEN Backend = 'ADX - Database' THEN [ELT].[uf_GetADXQuery]('SourceQuery',  ID.[IngestID], EntityName, WatermarkName,  II.DataFromTimestamp,  II.[DataToTimestamp], NULL)

						--DEFAULT ANSI SQL for Watermark Table
						WHEN [EntityName] IS NOT NULL AND [WatermarkName] IS NOT NULL AND [LastWatermarkDate] IS NOT NULL 
							THEN 'SELECT * FROM ' + [EntityName] + ' WHERE ' 
									+ [WatermarkName] + ' > ' + ''''+ CONVERT(VARCHAR(23),II.[DataFromTimestamp],121)+''''+ ' AND ' + [WatermarkName] + ' <= ' + ''''+ CONVERT(VARCHAR(23),II.[DataToTimestamp],121)+''''
						--Common No Watermark
						WHEN [EntityName] IS NOT NULL AND [WatermarkName] IS NULL
							THEN 'SELECT * FROM ' + [EntityName]
						--Running Number
						WHEN [EntityName] IS NOT NULL AND [WatermarkName] IS NOT NULL AND [LastWatermarkNumber] IS NOT NULL
								THEN 'SELECT * FROM ' + [EntityName] + ' WHERE ' 
												+ [WatermarkName] + ' > ' + ''''+CONVERT(VARCHAR,II.[DataFromNumber])+'''' + ' AND ' + [WatermarkName] + ' <= ' + ''''+CONVERT(VARCHAR,II.[DataToNumber])+''''
						
						ELSE NULL
					END

				,StatQuery = 
					CASE 
					-- Customized for simple Purview ATLAS API
					   WHEN Backend IN ('ATLAS REST API','AZURE REST API') THEN EntityName 

					-- Salesforce
					   WHEN Backend IN ('Salesforce - Cloud') THEN [ELT].[uf_GetSalesforceQuery]('StatQuery', ID.[IngestID], [EntityName], [WatermarkName], II.DataFromTimestamp,  II.[DataToTimestamp], NULL)

					--ADX
						WHEN Backend = 'ADX - Database' THEN [ELT].[uf_GetADXQuery]('StatQuery',  ID.[IngestID], EntityName, WatermarkName,  II.DataFromTimestamp,  II.[DataToTimestamp], NULL)


					--DEFAULT ANSI SQL for Watermark Table
						WHEN [EntityName] IS NOT NULL AND [WatermarkName] IS NOT NULL AND [LastWatermarkDate] IS NOT NULL THEN
									'SELECT MIN('+[WatermarkName]+') AS DataFromTimestamp, MAX('+[WatermarkName]+') AS DataToTimestamp, count(1) as SourceCount FROM ' 
									+ [EntityName] + ' WHERE ' + [WatermarkName] + '>' + ''''+CONVERT(VARCHAR(23),II.DataFromTimestamp,121)+''''+ ' AND ' + [WatermarkName] + '<='+ ''''+CONVERT(VARCHAR(23),II.[DataToTimestamp],121)+''''
					--Common No Watermark
						WHEN [EntityName] IS NOT NULL AND [WatermarkName] IS NULL AND [LastWatermarkDate] IS NOT NULL 
							THEN 'SELECT MIN('+[WatermarkName]+') AS DataFromTimestamp,' + ' MAX('+[WatermarkName]+') AS DataToTimestamp,'+ 'COUNT(*) AS SourceCount FROM ' + [EntityName]
					--Common No Watermark
						WHEN [EntityName] IS NOT NULL AND [WatermarkName] IS NULL
							THEN 'SELECT SELECT ''1900-01-01 00:00:00'' AS DataFromTimestamp, '''+CONVERT(VARCHAR(23),ELT.uf_GetAestDateTime(),120)+''' AS DataToTimestamp, COUNT(*) AS SourceCount FROM ' + [EntityName]
					--Running Number
						WHEN [EntityName] IS NOT NULL AND [WatermarkName] IS NOT NULL AND [LastWatermarkNumber] IS NOT NULL
								THEN 'SELECT MIN('+[WatermarkName]+') AS DataFromTimestamp,' + ' MAX('+[WatermarkName]+') AS DataToTimestamp,'+ 'COUNT(*) AS SourceCount FROM ' + [EntityName]
												+ [WatermarkName] + ' > ' + ''''+CONVERT(VARCHAR,II.[DataFromNumber]) +'''' + ' AND ' + [WatermarkName] + ' <= ' + ''''+CONVERT(VARCHAR,II.[DataToNumber])+''''
						ELSE NULL 	
					END

				,II.[ReloadFlag]
				, II.[ADFIngestPipelineRunID]
			FROM 
				[ELT].[IngestDefinition] ID
					INNER JOIN [ELT].[IngestInstance] AS II
						ON II.[IngestID]= ID.[IngestID] 
						AND II.[ReloadFlag]=1
						AND (II.[IngestStatus] is NULL OR II.[IngestStatus] != 'Running')  --Fetch new instances and ignore instances that are currently running
			WHERE 
				ID.[SourceSystemName]=@SourceSystemName
				AND ID.[StreamName] LIKE COALESCE(@StreamName, [StreamName])
				AND ID.[ActiveFlag]=1 
				AND ISNULL(II.RetryCount,0) <= ID.MaxRetries
				
	)
	SELECT 
		TOP (@MaxIngestInstance) *  
	FROM CTE
	ORDER BY 
		[RunSequence] ASC, [DataFromTimestamp] DESC, [DataToTimestamp] DESC

END
GO


