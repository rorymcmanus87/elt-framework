ALTER TABLE [ELT].[L2TransformDefinition]
	ADD CONSTRAINT [CC_L2TransformDefinition_OutputEntityWriteMode]
	CHECK ([OutputEntityWriteMode]='append' OR [OutputEntityWriteMode]='overwrite' OR [OutputEntityWriteMode]='ignore' OR [OutputEntityWriteMode]='error' OR [OutputEntityWriteMode]='errorifexists')
