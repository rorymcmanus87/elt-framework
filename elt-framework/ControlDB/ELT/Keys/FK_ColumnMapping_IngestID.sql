ALTER TABLE [ELT].[ColumnMapping] 
	WITH CHECK ADD CONSTRAINT [FK_ColumnMapping_IngestID] 
	FOREIGN KEY([IngestID])
REFERENCES [ELT].[IngestDefinition] ([IngestID])