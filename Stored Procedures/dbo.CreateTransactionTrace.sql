SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****** Object:  StoredProcedure [dbo].[CreateTransactionTrace]    Script Date: 9/7/2016 11:02:51 AM ******/
CREATE proc [dbo].[CreateTransactionTrace] @RootAuditPath nvarchar(256)
	, @MaxFileSizeMB bigint = 20
	, @MaxFileNumber int = 1
	, @NewTraceID int output
as

	declare @rc int
	declare @TraceID int

--Create Trace
	exec @rc = sp_trace_create @TraceID output
		, 2
		, @RootAuditPath
		, @maxfilesizeMB
		, NULL 
		, @MaxFileNumber

if (@rc != 0) goto error

-- Set the events
	declare @on bit
	set @on = 1
		--Audit Schema Object Access
		--http://www.databasejournal.com/features/mssql/article.php/3887996/Determining-Object-Access-Using-SQL-Server-Profiler.htm
		exec sp_trace_setevent @TraceID, 114, 8 , @on			--HostName
--
		exec sp_trace_setevent @TraceID, 114, 1 , @on			--TextData
--
		exec sp_trace_setevent @TraceID, 114, 10, @on			--ApplicationName
		exec sp_trace_setevent @TraceID, 114, 3 , @on			--DatabaseID
		exec sp_trace_setevent @TraceID, 114, 11, @on			--LoginName
		exec sp_trace_setevent @TraceID, 114, 35, @on			--DatabaseName
		exec sp_trace_setevent @TraceID, 114, 12, @on			--SPID
		exec sp_trace_setevent @TraceID, 114, 14, @on			--StartTime

-- Set the Filters
	declare @intfilter int
		set @intfilter = 5

	exec sp_trace_setfilter @TraceID, 3, 0, 4, @intfilter		--DBID>=5. Don't monitor system databases
	exec sp_trace_setfilter @TraceID, 10, 0, 7, N'SQL Server Profiler - 9d6318ce-e48f-4885-9939-8079624f63cd'

goto finish

error: 
	select ErrorCode=@rc

finish: 
	Set @NewTraceID = @TraceID

GO
