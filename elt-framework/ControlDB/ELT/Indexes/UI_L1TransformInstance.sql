CREATE UNIQUE INDEX [UI_L1TransformInstance]
	ON [ELT].[L1TransformInstance]
	([InputRawFileSystem],[InputRawFileFolder],[InputRawFile],[OutputEntityName],[OutputEntityFolder])