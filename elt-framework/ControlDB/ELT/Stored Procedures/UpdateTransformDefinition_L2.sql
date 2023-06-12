CREATE PROCEDURE [ELT].[UpdateTransformDefinition_L2]
	@L2TransformID INT,
	@LastWatermarkDate Datetime2 =null,
	@LastWatermarkNumber int =null
	as
BEGIN
	Update [ELT].[L2TransformDefinition]
	SET 
		[ModifiedBy] =suser_sname(),
		[ModifiedTimestamp]=GETDATE(),
		[LastWatermarkDate] = COALESCE(@LastWatermarkDate,[LastWatermarkDate],ELT.uf_GetAestDateTime()),
		[LastWatermarkNumber] = COALESCE(@LastWatermarkNumber,[LastWatermarkNumber])

	WHERE [L2TransformID] = @L2TransformID
END
GO


