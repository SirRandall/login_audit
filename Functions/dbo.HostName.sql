SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[HostName]
(
)
RETURNS NVARCHAR(100)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @str NVARCHAR(100)
	
	-- Add the T-SQL statements to compute the return value here
	SELECT @Str = paramvalue FROM dbo.tbl_Parameters WHERE paramName = 'SQLInstanceName'
	
	-- Return the result of the function
	RETURN @Str

END
GO
