ALTER TABLE [ELT].[ColumnMapping] 
	ADD CONSTRAINT [FK_ColumnMapping_IngestID] 
	FOREIGN KEY([IngestID])
REFERENCES [ELT].[IngestDefinition] ([IngestID])