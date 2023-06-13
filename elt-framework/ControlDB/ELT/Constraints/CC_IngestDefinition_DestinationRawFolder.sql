ALTER TABLE [ELT].[IngestDefinition]  
	ADD  CONSTRAINT [CC_IngestDefinition_DestinationRawFolder] 
	CHECK (
			(left([DestinationRawFolder],charindex('YYYY/MM',[DestinationRawFolder])-(1))=(lower(left([DestinationRawFolder],charindex('YYYY/MM',[DestinationRawFolder])-(1)))) collate SQL_Latin1_General_CP1_CS_AS)
		)
