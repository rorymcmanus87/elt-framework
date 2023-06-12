ALTER TABLE [ELT].[ColumnMapping] 
	WITH CHECK ADD  CONSTRAINT [FK_ColumnMapping_L1TransformID] 
	FOREIGN KEY([L1TransformId])
REFERENCES [ELT].[L1TransformDefinition] ([L1TransformID])