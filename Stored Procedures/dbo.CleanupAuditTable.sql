SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROC [dbo].[CleanupAuditTable] (@DaysToKeep INT = 3, @BatchSize int = 100000)
AS
BEGIN

SET NOCOUNT ON;

--DECLARE @DaysToKeep INT = 3
--DECLARE @BatchSize INT = 100000;

--Cleanup Audit history

	--Get Current identity value for TraceCollectBatchID
		DECLARE @curBatchID INT
		SELECT @curBatchID = NEXT VALUE FOR dbo.TraceCollectBatchID
		--1 batch every hour.

	--Disable dynamic Statistics updates
		EXEC sys.sp_autostats @tblname = N'dbo.tbl_Trans_audit'   
            , @flagc = 'OFF'       
            , @indname = NULL  

	--Delete records in batches of 5000
		DECLARE @RowCount bigint = 0
		DECLARE @rc INT = 0
		DECLARE @strNow NVARCHAR(30)

		WHILE 1 = 1
		BEGIN

			DELETE TOP (@BatchSize)
			FROM Login_audit.dbo.tbl_Trans_audit
			WHERE TraceCollectBatchID < (@curBatchID - (24 * @DaysToKeep)); --data over @DaysToKeep days old

				SELECT @rc = @@ROWCOUNT

			--Get new rowcount, and show the progress message
				SELECT @RowCount = SUM(p.rows) --AS RowCount
				FROM sys.partitions p
				WHERE p.object_id = OBJECT_ID('dbo.tbl_Trans_audit')
				AND p.index_id IN (0,1);

				SET @strNow = CONVERT(VARCHAR(23), SYSDATETIME(), 121);

				RAISERROR('%s - Remaining rows: %I64d', 0, 1, @strNow, @RowCount) WITH NOWAIT;

			--Exit the loop if no records were deleted
				IF @rc = 0
					BREAK;
		END

	--Manually update statistics
		UPDATE STATISTICS Login_audit.dbo.tbl_Trans_audit

	--Re-Enable dynamic Statistics updates
		EXEC sys.sp_autostats @tblname = N'dbo.tbl_Trans_audit'    
			, @flagc = 'ON'      
			, @indname = NULL   

END
GO
