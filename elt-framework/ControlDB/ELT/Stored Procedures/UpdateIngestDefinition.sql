CREATE PROCEDURE [ELT].[UpdateIngestDefinition]
	@IngestID INT,
	@LastWatermarkDate Datetime2(7)=null,
	@LastWatermarkNumber int=null,
	@IngestStatus varchar(20),
	@ReloadFlag bit=0
AS
BEGIN

		DECLARE @localdate as datetime	= CONVERT(datetime,CONVERT(datetimeoffset, getdate()) at time zone 'AUS Eastern Standard Time')

		Update 
			[ELT].[IngestDefinition]
		SET 
			[LastWatermarkDate] =
							CASE
								--When Successful and the DataToDate does not move forward since LastWatermarkDate, Increase LastWatermarkDate by the Interval
								WHEN @LastWatermarkDate IS NOT NULL AND @ReloadFlag <> 1 AND @IngestStatus IN ('Success','ReRunSuccess') AND @LastWatermarkDate = [LastWatermarkDate] 
									and [MaxIntervalMinutes] is NOT NULL
									THEN 
										CASE 
											WHEN 
												DateAdd(minute,[MaxIntervalMinutes],@LastWatermarkDate) > ELT.[uf_GetAestDateTime]()
													THEN CONVERT(VARCHAR(30),ELT.[uf_GetAestDateTime](),120)
											ELSE
												DateAdd(minute,[MaxIntervalMinutes],[LastWatermarkDate])
										END
								--Re-run Watermark date is later than existing Watermark date
								WHEN @LastWatermarkDate IS NOT NULL AND @IngestStatus IN ('Success','ReRunSuccess') AND datediff_big(ss,[LastWatermarkDate],@LastWatermarkDate) >= 0 
									THEN @LastWatermarkDate
								--Re-run Watermark date is earlier than existing Watermark date
								WHEN @LastWatermarkDate IS NOT NULL AND @IngestStatus IN ('Success','ReRunSuccess')  AND datediff_big(ss,@LastWatermarkDate,[LastWatermarkDate]) >=0 
									THEN [LastWatermarkDate]
								ELSE [LastWatermarkDate]
							END
			, [LastWatermarkNumber] = 
							CASE
								WHEN @LastWatermarkNumber IS NOT NULL AND @IngestStatus IN ('Success','ReRunSuccess') 
									THEN @LastWatermarkNumber
								WHEN @LastWatermarkNumber IS NOT NULL AND @IngestStatus IN ('Failure','ReRunFailure') 
									THEN [LastWatermarkNumber]
								WHEN @LastWatermarkNumber IS NULL AND @ReloadFlag <> 1 AND @IngestStatus IN ('Success','ReRunSuccess')  
									THEN ([LastWatermarkNumber] + [MaxIntervalNumber])
								ELSE [LastWatermarkNumber]
							END
			,[ModifiedBy] =suser_sname()
			, [ModifiedTimestamp]=@localdate
	WHERE [IngestID]=@IngestID
END
GO


