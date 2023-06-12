ALTER TABLE [ELT].[ColumnMapping]  
	WITH CHECK ADD  CONSTRAINT [FK_ColumnMapping_L2TransformID] 
FOREIGN KEY([L2TransformId])
REFERENCES [ELT].[L2TransformDefinition] ([L2TransformID])