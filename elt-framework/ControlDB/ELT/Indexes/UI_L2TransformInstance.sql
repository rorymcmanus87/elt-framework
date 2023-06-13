CREATE INDEX [UI_L2TransformInstance]
	ON [ELT].[L2TransformInstance]
	(
	[InputFileSystem] ASC,
	[InputFileFolder] ASC,
	[InputFile] ASC,
	[InputEntityName] ASC,
	[OutputL2CurateFileSystem] ASC,
	[OutputL2CuratedFolder] ASC,
	[OutputL2CuratedFile] ASC
)