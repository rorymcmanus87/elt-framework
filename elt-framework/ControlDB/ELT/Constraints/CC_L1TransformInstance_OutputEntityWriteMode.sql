ALTER TABLE [ELT].[L1TransformInstance]
	ADD CONSTRAINT [CC_L1TransformInstance_OutputEntityWriteMode]
	CHECK ([OutputEntityWriteMode]='append' OR [OutputEntityWriteMode]='overwrite' OR [OutputEntityWriteMode]='error' OR [OutputEntityWriteMode]='errorifexists' OR [OutputEntityWriteMode]='ignore')
