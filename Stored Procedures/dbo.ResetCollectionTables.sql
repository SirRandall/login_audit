SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[ResetCollectionTables]
AS

BEGIN


	TRUNCATE TABLE dbo.tbl_Trans_audit;

	TRUNCATE TABLE dbo.tbl_Trans_Summary;

	ALTER SEQUENCE dbo.TraceCollectBatchID RESTART WITH 1;


END

GO
