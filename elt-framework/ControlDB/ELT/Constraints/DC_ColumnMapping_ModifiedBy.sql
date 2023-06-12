ALTER TABLE [ELT].[ColumnMapping] 
	ADD  CONSTRAINT [DC_ColumnMapping_ModifiedBy]  
	DEFAULT (suser_sname()) 
FOR [ModifiedBy]