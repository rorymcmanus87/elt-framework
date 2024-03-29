﻿CREATE TABLE [ELT].[IngestDefinition](
	[IngestID] [int] IDENTITY(1,1) NOT NULL,
	[SourceSystemName] [varchar](50) NOT NULL,
	[StreamName] [varchar](100) NULL,
	[SourceSystemDescription] [varchar](200) NULL,
	[Backend] [varchar](30) NULL,
	[DataFormat] [varchar](10) NULL,
	[EntityName] [varchar](100) NULL,
	[WatermarkName] [varchar](50) NULL,
	[WatermarkFormat] [varchar](30) NULL,
	[LastWatermarkDate] [datetime2](7) NULL,
	[LastWatermarkNumber] [int] NULL,
	[LastWatermarkString] [varchar](50) NULL,
	[MaxIntervalMinutes] [int] NULL,
	[MaxIntervalNumber] [int] NULL,
	[DataMapping] [varchar](max) NULL,
	[SourceFileDropFileSystem] [varchar](50) NULL,
	[SourceFileDropFolder] [varchar](200) NULL,
	[SourceFileDropFile] [varchar](200) NULL,
	[SourceFileDelimiter] [char](1) NULL,
	[SourceFileHeaderFlag] [bit] NULL,
	[SourceStructure] [varchar](max) NULL,
	[DestinationRawFileSystem] [varchar](50) NULL,
	[DestinationRawFolder] [varchar](200) NULL,
	[DestinationRawFile] [varchar](200) NULL,
	[RunSequence] [int] NULL,
	[MaxRetries] [int] NULL,
	[ActiveFlag] [bit] NOT NULL,
	[L1TransformationReqdFlag] [bit] NOT NULL,
	[L2TransformationReqdFlag] [bit] NOT NULL,
	[DelayL1TransformationFlag] [bit] NOT NULL,
	[DelayL2TransformationFlag] [bit] NOT NULL,
	[CreatedBy] [nvarchar](128) NOT NULL,
	[CreatedTimestamp] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](128) NULL,
	[ModifiedTimestamp] [datetime] NULL)