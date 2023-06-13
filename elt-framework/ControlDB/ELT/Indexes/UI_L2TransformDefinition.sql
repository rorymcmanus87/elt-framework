CREATE UNIQUE INDEX [UI_L2TransformDefinition]
	ON [ELT].[L2TransformDefinition]
	([InputFileSystem] ASC,
	[InputFileFolder] ASC,
	[InputFile] ASC,
	[InputEntityName] ASC,
	[OutputEntityFileSystem] ASC,
	[OutputEntityFolder] ASC)
