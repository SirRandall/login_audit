SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****** Object:  StoredProcedure [dbo].[ImportAndCycleTransactionTrace]    Script Date: 9/7/2016 11:03:09 AM ******/
CREATE Proc [dbo].[ImportAndCycleTransactionTrace] @RestartTrace int = 1
as

/* 3/18/2015 Randy Sheldon
	1. Stops currently running trace. If one isn't running, it creates one
	   if @RestartTrace = 1
	2. Imports data from stopped trace file
	3. Deletes selected trace
	4. Deletes trace TRC files created
	5. Starts a new identical trace 
*/
	Declare @TransactionPath nvarchar(200)
	Declare @TraceID int

--Get the paths for transaction audit
	Select @TransactionPath = paramValue
	from dbo.tbl_Parameters
	where paramName = 'Transaction_Audit_path'
		print '@TransactionPath = ' + @TransactionPath

--Find active TraceID for Transaction audit
	If Exists(Select Path from sys.traces where path Like @TransactionPath + '%') 
		begin
			Select @TraceID = ID 
			from sys.traces
			where Path like @TransactionPath + '%'

			print '@TraceID = ' + Cast(@traceID as varchar(2))

		end
	else
		goto Exit_
	
	
--Stop trace
	exec sp_trace_SetStatus @TraceID, 0


--Import information from the trace
--	truncate table dbo.tbl_Trans_audit;

	--Get the NEXT sequence ID for capturing batches
	DECLARE @BatchID BIGINT;
	SET @BatchID = NEXT VALUE FOR TraceCollectBatchID;

	Insert into dbo.tbl_Trans_Audit
		(TraceCollectBatchID, HostName, ApplicationName, LoginName, StartTime, Databasename, DatabaseID, TextData)
		Select @BatchID, HostName, Left(ApplicationName,100), Left(LoginName,255), StartTime, Left(Databasename,50), DatabaseID, CAST(TextData AS NVARCHAR(1000))
		from fn_trace_gettable(@TransactionPath + '.trc', 20)
		where HostName is Not Null
			and StartTime is Not Null
			and DatabaseName is not null
		order by StartTime
		
		Select  Cast(@@rowcount as varchar(20)) + ' rows imported.'
		

--delete the previous trace
--	If @TraceID > 0 
	exec sp_trace_setStatus @TraceID, 2

--Clear out existing tracefiles in this directory, using Ole Automation
	Declare @Result int
	Declare @FSO_Token int
	Declare @DeletePath nvarchar(256)
		Set @DeletePath = @TransactionPath + '*.trc'

	Exec @Result = sp_OACreate 'Scripting.FileSystemObject', @FSO_Token OUTPUT
	Exec @Result = sp_OAMethod @FSO_Token, 'DeleteFile', NULL, @DeletePath
	Exec @Result = sp_OADestroy @FSO_Token

Exit_:
--Create a new Trace
		
	If @RestartTrace = 1
		begin
			Declare @NewTraceID int, @MaxFileSizeMB int, @MaxFileCount int
			Select @MAxFileSizeMB = Cast(IsNull(paramValue,20) as int) 
				from dbo.[tbl_Parameters] 
				where [paramName] = 'MaxFileSizeMB'

			Select @MaxFileCount = Cast(IsNull(paramValue,20) as int)  
				from dbo.[tbl_Parameters] 
				where [paramName] = 'MaxFileCount'

			Exec dbo.CreateTransactionTrace @TransactionPath,@MAxFileSizeMB,@MaxFileCount, @NewTraceID output
			exec sp_trace_setstatus @NewTraceID, 1
		end
	
GO
