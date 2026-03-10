SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [dbo].[Transaction_Summary]
AS


    SELECT  DATEADD(   HOUR
                     , DATEPART(HOUR, ta.StartTime)
                     , CAST(CONVERT(VARCHAR(20), ta.StartTime, 1) AS DATETIME)
                   )               [Hour]
          , ta.DatabaseName
          , ta.HostName
          , ta.LoginName
          , ta.ApplicationName
          , COUNT(ta.DatabaseID) [Calls]
    FROM    Login_audit.dbo.tbl_Trans_audit ta
        CROSS APPLY(
                       SELECT   paramValue
                       FROM dbo.tbl_Parameters
                       WHERE paramName = 'MonitoringServer'
                   )                              mn

    WHERE ta.HostName <> mn.paramValue
        AND ta.HostName <> [login_audit].dbo.HostName()
    GROUP BY
        DATEADD(
                   HOUR
                 , DATEPART(HOUR, ta.StartTime)
                 , CAST(CONVERT(VARCHAR(20), ta.StartTime, 1) AS DATETIME)
               )
      , ta.DatabaseName
      , ta.HostName
      , ta.LoginName
      , ta.ApplicationName;
GO
