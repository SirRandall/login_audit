SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE proc [dbo].[DatabaseTransTrends] @StartDate datetime, @EndDate datetime, @DatabaseName varchar(100)
as
--Select @StartDate = '9/1/2016', @EndDate = '9/10/2016', @DatabaseName = 'Australia_commerce'

SELECT  db.name                             [DatabaseName]
      , CONVERT(VARCHAR(30), S.DateHour, 1) [FixedDate]
      , SUM(S.Hits)                         [Hits]
FROM    sys.databases                           db

    LEFT JOIN Login_audit.dbo.tbl_Trans_Summary S
              ON db.name = S.DatabaseName

WHERE
    db.name = @DatabaseName -- db.database_id > 4

    AND ( S.DateHour BETWEEN @StartDate AND @EndDate
            OR  ISNULL(S.DateHour, @EndDate) = @EndDate
        )
GROUP BY
    db.name
  , CONVERT(VARCHAR(30), S.DateHour, 1);

GO
