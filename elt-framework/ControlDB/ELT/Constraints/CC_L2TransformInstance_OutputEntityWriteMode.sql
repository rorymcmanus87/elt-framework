ALTER TABLE [ELT].[L2TransformInstance]
	ADD CONSTRAINT [CC_L2TransformInstance_OutputEntityWriteMode]
	CHECK ([OutputEntityWriteMode]='append' OR [OutputEntityWriteMode]= 'overwrite' OR [OutputEntityWriteMode]= 'ignore' OR [OutputEntityWriteMode]= 'error' OR [OutputEntityWriteMode]= 'errorifexists')
