WITH CTE_DatesTable
AS
(
  SELECT CAST('20150101' as date) AS [date]
  UNION ALL
  SELECT DATEADD(dd, 1, [date])
  FROM CTE_DatesTable
  WHERE DATEADD(dd, 1, [date]) <= GetDate()
)

SELECT * FROM CTE_DatesTable

OPTION (MAXRECURSION 0)