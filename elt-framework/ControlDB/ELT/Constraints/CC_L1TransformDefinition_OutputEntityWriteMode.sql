ALTER TABLE [ELT].[L1TransformDefinition]
	ADD CONSTRAINT [CC_L1TransformDefinition_OutputEntityWriteMode]
CHECK ([OutputEntityWriteMode] ='append' OR [OutputEntityWriteMode]='overwrite' OR [OutputEntityWriteMode]='error' OR [OutputEntityWriteMode]='errorifexists' OR [OutputEntityWriteMode]='ignore')
