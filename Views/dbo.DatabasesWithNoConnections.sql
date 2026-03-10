SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [dbo].[DatabasesWithNoConnections]
AS
    SELECT  S.name + CASE
                         WHEN S.state = 6 THEN
                             ' (offline)'
                         ELSE
                             ''
                     END [Name]
          , S.state
    FROM    sys.databases               S
        LEFT JOIN dbo.tbl_Trans_Summary T
                  ON T.DatabaseName = S.name
    WHERE
        S.name NOT IN ( 'master', 'model', 'msdb', 'tempdb' )
        AND T.DatabaseName IS NULL;

GO
