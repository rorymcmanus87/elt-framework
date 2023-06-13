CREATE TABLE [ELT].[ColumnMapping](
	[MappingID] [int] IDENTITY(1,1) NOT NULL,
	[IngestID] [int] NULL,
	[L1TransformID] [int] NULL,
	[L2TransformID] [int] NULL,
	[SourceName] [nvarchar](128) NOT NULL,
	[TargetName] [nvarchar](128) NOT NULL,
	[Description] [nvarchar](250) NULL,
	[TargetOrdinalPosition] [int] NOT NULL,
	[ActiveFlag] [bit] NULL,
	[CreatedBy] [varchar](50) NOT NULL,
	[CreatedTimestamp] [datetime] NOT NULL,
	[ModifiedBy] [varchar](50) NULL,
	[ModifiedTimestamp] [datetime] NULL)