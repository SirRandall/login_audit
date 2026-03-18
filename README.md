# Login Audit

A SQL Server database project that captures, stores, and summarizes login and transaction activity across a SQL Server instance using SQL Trace.

## Purpose

This database tracks **who is connecting to which databases**, from what host and application, and how frequently. It is intended to help DBAs:

- Identify active vs. dormant databases
- Monitor login and application activity trends over time
- Filter out noise from known monitoring servers
- Detect unexpected or unauthorized access patterns

## How It Works

SQL Trace (event 114 - Audit Schema Object Access) writes `.trc` files to disk. A SQL Agent job runs every hour to:

1. **Import** the current trace file into `tbl_Trans_audit` (raw audit log)
2. **Summarize** the new data into `tbl_Trans_Summary` (hourly aggregates by database/host/login/app)
3. **Clean up** raw audit rows older than the configured retention window
4. **Restart** a fresh trace

## Database Objects

### Tables
| Table | Description |
|---|---|
| `tbl_Trans_audit` | Raw trace data: hostname, login, application, database, SQL text, timestamp. Short-term retention. |
| `tbl_Trans_Summary` | Hourly aggregated hit counts. Long-term retention. |
| `tbl_Parameters` | Key-value configuration store (trace path, file size limits, server names). |

### Stored Procedures
| Procedure | Description |
|---|---|
| `CreateTransactionTrace` | Creates a new SQL Trace targeting user databases only (DBID >= 5). |
| `ImportAndCycleTransactionTrace` | Stops the active trace, imports `.trc` data, deletes trace files, starts a new trace. |
| `SummarizeTransAudit` | Aggregates the latest batch from `tbl_Trans_audit` into `tbl_Trans_Summary`. |
| `CleanupAuditTable` | Deletes raw audit rows older than N days (default: 3) in batches. |
| `DatabaseTransTrends` | Reporting query: returns hourly hit counts for a given database over a date range. |
| `ResetCollectionTables` | Dev/maintenance utility: truncates all data and resets the batch sequence. |

### Views
| View | Description |
|---|---|
| `LegitActions` | Summary data filtered to exclude this server and the designated monitoring server. |
| `Transaction_Summary` | Live aggregation from raw audit data, with the same noise filtering as `LegitActions`. |
| `DatabasesWithNoConnections` | Lists databases in `sys.databases` that have no recorded activity in `tbl_Trans_Summary`. |

### Other Objects
| Object | Description |
|---|---|
| `TraceCollectBatchID` (Sequence) | Auto-incrementing ID stamped on each hourly import batch. Used for retention/purge logic. |
| `dbo.HostName()` (Function) | Returns the local SQL instance name from `tbl_Parameters`. Used in views to filter self-connections. |

## Configuration (`tbl_Parameters`)

| paramName | Description |
|---|---|
| `Transaction_Audit_path` | File path prefix for SQL Trace `.trc` files |
| `MaxFileSizeMB` | Maximum size per trace file (default: 20 MB) |
| `MaxFileCount` | Maximum number of rolling trace files |
| `SQLInstanceName` | The name of this SQL Server instance (used by `dbo.HostName()`) |
| `MonitoringServer` | Hostname of a monitoring server whose connections should be excluded from views |

## SQL Agent Job

**Job name:** `Login_Audit cycle trace`
**Schedule:** Every hour, all day

| Step | Command | On Failure |
|---|---|---|
| 1 - Import Trace Data | `ImportAndCycleTransactionTrace` | Go to Step 3 |
| 2 - Summarize Collected Data | `SummarizeTransAudit` | Go to Step 3 |
| 3 - Cleanup History | `CleanupAuditTable @DaysToKeep=1` | Fail job |

## Source Control

This project is managed with **Redgate SQL Source Control** (see `RedGate.ssc` and `RedGateDatabaseInfo.xml`).
