CREATE TABLE [dbo].[tbl_Trans_audit]
(
[ID] [bigint] NOT NULL IDENTITY(1, 1),
[HostName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ApplicationName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoginName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartTime] [datetime] NOT NULL,
[DatabaseName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DatabaseID] [int] NOT NULL,
[TextData] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TraceCollectBatchID] [bigint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tbl_Trans_audit] ADD CONSTRAINT [PK_tbl_Trans_audit] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_Trans_Audit_TraceCollectBatchID_DatabaseID] ON [dbo].[tbl_Trans_audit] ([TraceCollectBatchID], [DatabaseID]) ON [PRIMARY]
GO
