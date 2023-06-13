ALTER TABLE [ELT].[ColumnMapping] 
	ADD  CONSTRAINT [FK_ColumnMapping_L1TransformID] 
	FOREIGN KEY([L1TransformID])
REFERENCES [ELT].[L1TransformDefinition] ([L1TransformID])