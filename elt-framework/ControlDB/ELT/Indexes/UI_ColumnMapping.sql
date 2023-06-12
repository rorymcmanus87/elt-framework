CREATE UNIQUE INDEX [UI_ColumnMapping]
	ON [ELT].[ColumnMapping]
	([IngestID],[L1TransformID],[L2TransformID],[SourceName],[TargetName])