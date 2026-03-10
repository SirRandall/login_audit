SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [dbo].[LegitActions]
AS

/* Returns data from tbl_Trans_Summary, but omits
    data that was specificallty generated from the Monitoring
    Server identitifed in tbl_Parameters where paramName = 'MonitoringServer'.

*/

SELECT ts.[DateHour]
      ,ts.[DatabaseName]
      ,ts.[HostName]
      ,ts.[LoginName]
      ,ts.[ApplicationName]
      ,ts.[Hits]
  FROM [Login_audit].[dbo].[tbl_Trans_Summary] ts

     CROSS APPLY (SELECT paramValue FROM dbo.tbl_Parameters WHERE paramName = 'MonitoringServer') mn

  WHERE ts.DatabaseName NOT IN ('_DBAAdmin', 'Login_audit')
	AND ts.hostname <> mn.paramvalue                --eliminates Monitoring server
	AND ts.hostname <> [Login_audit].dbo.HostName() --eliminates THIS server
GO
