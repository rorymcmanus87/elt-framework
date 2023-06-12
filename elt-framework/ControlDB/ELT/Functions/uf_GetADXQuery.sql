CREATE FUNCTION [ELT].[uf_GetADXQuery]
(
	@QueryType varchar(20), --SourceQuery|StatQuery
	@IngestId INT,
	@EntityName varchar(100),
	@DeltaName varchar(20)=Null,
	@FromDate datetime2(7)=NULL,
	@ToDate datetime2(7)=NULL,
	@MaxIntervalMinutes int=NULL
	)
RETURNS varchar(MAX)
	AS
BEGIN
	--DECLARE @FromDate datetime2
	Declare @Query varchar(MAX)
	DECLARE @MappingExists INT
	DECLARE @Columns NVARCHAR(MAX)
	Declare @From datetime2(7)
	DECLARE @FromStr varchar(27), @ToStr varchar(27)

	SET @From = (CASE 
					WHEN @FromDate is NULL THEN '1900-01-01 00:00:00'
					ELSE @FromDate
				END)

	--Datetime Strings
	SET @ToStr =  CASE 
					WHEN @ToDate IS NOT NULL
						THEN @ToDate
					WHEN @ToDate is NULL AND @MaxIntervalMinutes IS NULL 
						THEN GETDATE()
					WHEN @ToDate is NULL AND @MaxIntervalMinutes IS NOT NULL AND DATEADD(DAY,@MaxIntervalMinutes/1440,@From) > GETDATE() 
						THEN GETDATE()
					WHEN @ToDate is NULL AND @MaxIntervalMinutes IS NOT NULL AND DATEADD(DAY,@MaxIntervalMinutes/1440,@From) <= GETDATE() 
						THEN DATEADD(DAY,@MaxIntervalMinutes/1440,@From)
					ELSE GETDATE()
					END

	SET @FromStr = (CASE 
					WHEN @FromDate is NULL THEN '1900-01-01 00:00:00'
					ELSE @FromDate
				END)

	--Set Columns
	SET @Columns = (		
						SELECT
							DISTINCT
								STUFF((
									SELECT 
										', ' + TargetName + '=' + SourceName
								    FROM     
										[ELT].[ColumnMapping]
									WHERE IngestId = @IngestId
										AND ActiveFlag = 1
									ORDER BY TargetOrdinalPosition ASC
								       FOR XML PATH('')
								       ),1,1,'') AS ColumnList
						FROM
							[ELT].[ColumnMapping]
						WHERE IngestId = @IngestId
							and ActiveFlag = 1 
						GROUP BY SourceName
					)

	--SourceQuery
	IF @QueryType ='SourceQuery'
		BEGIN
			SET @Query = 
			--COALESCE(@Columns, ' * ')
						@EntityName + ' | take 1000 '
						+ CASE 
							WHEN @DeltaName IS NOT NULL
								THEN ' | where ' 	+ @DeltaName + ' > datetime(' + @FromStr + ') and ' + @DeltaName + ' <=  datetime(' + @ToStr + ')'
							END
						+
						CASE 
							WHEN @Columns IS NOT NULL
							 THEN ' | project ' + @Columns
						END
		END



	--SourceQuery
	IF @QueryType ='StatQuery'
		BEGIN
			SET @Query = 
			--COALESCE(@Columns, ' * ')
						@EntityName 
						+ CASE 
							WHEN @DeltaName IS NOT NULL
								THEN ' | where ' 	+ @DeltaName + ' > datetime(' + @FromStr + ') and ' + @DeltaName + ' <=  datetime(' + @ToStr + ')'
									+ ' | summarize DataFromTimestamp=min(' + @DeltaName + '), DataToTimestamp=max(' + @DeltaName + '), SourceCount=count()'
							WHEN @DeltaName IS NULL
								THEN ' | summarize DataFromTimestamp=''1900-01-01T00:00:00Z'', DataToTimestamp=''' + @ToStr + ''', SourceCount=count()'
			
							END
		END

 -- Return the result of the function
	Return @Query

END


GO


