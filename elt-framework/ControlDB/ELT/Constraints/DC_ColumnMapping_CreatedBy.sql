ALTER TABLE [ELT].[ColumnMapping] 
	ADD  CONSTRAINT [DC_ColumnMapping_CreatedBy]  
	DEFAULT (suser_sname()) 
	FOR [CreatedBy]