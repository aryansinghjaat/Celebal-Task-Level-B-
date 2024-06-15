-- LEVEL TASK B 
-- FUCTIONS 
-- ques 1

CREATE FUNCTION FormatDate (@inputDate DATETIME)
RETURNS VARCHAR(10)
AS
BEGIN
    RETURN (SELECT CONVERT(VARCHAR(2), DATEPART(MM, @inputDate)) + '/' +
                   CONVERT(VARCHAR(2), DATEPART(DD, @inputDate)) + '/' +
                   CONVERT(VARCHAR(4), DATEPART(YYYY, @inputDate)))
END

SELECT dbo.FormatDate('2006-11-21 23:34:05.920') AS FormattedDate


--ques 2

CREATE FUNCTION ReturnDate (@inputDate DATETIME)
RETURNS VARCHAR(8)
AS
BEGIN
    RETURN (SELECT CONVERT(VARCHAR(8), @inputDate, 112))
END

SELECT dbo.ReturnDate('2006-11-21 23:34:05.920') AS FormattedDate


