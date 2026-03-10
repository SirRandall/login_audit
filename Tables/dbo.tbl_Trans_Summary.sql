CREATE TABLE [dbo].[tbl_Trans_Summary]
(
[DateHour] [datetime] NOT NULL,
[DatabaseName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HostName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoginName] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ApplicationName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Hits] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tbl_Trans_Summary] ADD CONSTRAINT [PK_tbl_Trans_Summary] PRIMARY KEY CLUSTERED ([DateHour], [DatabaseName], [HostName], [LoginName], [ApplicationName]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_tbl_Trans_Summary_DateHour] ON [dbo].[tbl_Trans_Summary] ([DateHour]) ON [PRIMARY]
GO
