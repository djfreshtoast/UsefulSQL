DECLARE @startDate DATE, @numberDays TINYINT

SET @startDate = '2016-01-01'
SET @numberDays = 10;

WITH CTE_DatesTable
AS
(
  SELECT @startDate AS [date]
  UNION ALL
  SELECT DATEADD(DAY, 1, [date])
  FROM CTE_DatesTable
  WHERE DATEADD(DAY, 1, [date]) <= DateAdd(DAY, @numberDays-1, @startdate)
)

SELECT [date] 
FROM CTE_DatesTable

OPTION (MAXRECURSION 0)