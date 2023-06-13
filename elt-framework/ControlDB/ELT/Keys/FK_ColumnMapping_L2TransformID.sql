ALTER TABLE [ELT].[ColumnMapping]  
	ADD  CONSTRAINT [FK_ColumnMapping_L2TransformID] 
FOREIGN KEY([L2TransformID])
REFERENCES [ELT].[L2TransformDefinition] ([L2TransformID])