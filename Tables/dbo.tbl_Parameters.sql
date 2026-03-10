CREATE TABLE [dbo].[tbl_Parameters]
(
[paramName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[paramValue] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[testfield1] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tbl_Parameters] ADD CONSTRAINT [PK_tbl_Parameters] PRIMARY KEY CLUSTERED ([paramName]) ON [PRIMARY]
GO
