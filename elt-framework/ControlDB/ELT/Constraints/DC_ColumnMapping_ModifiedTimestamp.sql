ALTER TABLE [ELT].[ColumnMapping] 
	ADD CONSTRAINT [DC_ColumnMapping_ModifiedTimestamp]  
	DEFAULT (CONVERT([datetime],(CONVERT([datetimeoffset],getdate()) AT TIME ZONE 'AUS Eastern Standard Time'))) 
FOR [ModifiedTimestamp]