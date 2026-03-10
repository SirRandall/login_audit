SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****** Object:  StoredProcedure [dbo].[SummarizeTransAudit]    Script Date: 9/7/2016 11:03:00 AM ******/
CREATE proc [dbo].[SummarizeTransAudit]
as

--Aggrgate information from tbl_Trans_Audit into tbl_Trans_Summary

--Get the lastest batchID
	DECLARE @LatestBatchID BIGINT;

	SELECT @LatestBatchID = CAST(current_value AS BIGINT)
	FROM sys.sequences
	WHERE name = 'TraceCollectBatchID';

--Aggregate the LATEST batch into Temp table #t
	SELECT 
		DateAdd(HOUR,DatePart(HOUR,ta.StartTime), Cast(Convert(varchar(20),ta.StartTime,1) as datetime))	[DateHour]
		,ta.DatabaseName
		,ta.HostName
		,ta.LoginName
		,IsNull(ta.ApplicationName,'')	[ApplicationName]
		,Count(ta.DatabaseID) [Hits]
	INTO #T
	FROM [Login_Audit].[dbo].[tbl_Trans_audit] ta
	WHERE ta.TraceCollectBatchID = @LatestBatchID
	GROUP BY DateAdd(HOUR,DatePart(HOUR,ta.StartTime), Cast(Convert(varchar(20),ta.StartTime,1) as datetime))
		,ta.Databasename
		, ta.HostName
		, ta.LoginName
		, ta.ApplicationName
	ORDER BY 2;
		

		--Update temp table with any records that might already exist
		Update #T
			Set Hits = T.Hits + S.Hits
			from #T T
				join tbl_Trans_Summary S
				on		T.DateHour			= S.DateHour
					and T.DatabaseNAme		= S.DatabaseName
					and T.HostName			= S.HostName
					and T.LoginName			= S.LoginName
					and T.ApplicationName	= S.ApplicationName

		--Delete matching records from tbl_Trans_Summary
			Delete from tbl_Trans_Summary
			from tbl_Trans_Summary S
				join #T T
					on		T.DateHour			= S.DateHour
						and T.DatabaseNAme		= S.DatabaseName
						and T.HostName			= S.HostName
						and T.LoginName			= S.LoginName
						and T.ApplicationName	= S.ApplicationName

		--Insert the rest
			Insert into tbl_Trans_Summary(DateHour, DatabaseName, HostName, LoginName, ApplicationNAme, Hits)
			Select distinct DateHour, Left(DatabaseName,100), Left(HostName,30), right(LoginName,40), Left(ApplicationName,100), Hits
			from #T




	

Exit_:
	drop table #t


GO
