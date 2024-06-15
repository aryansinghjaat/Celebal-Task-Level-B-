-- LEVEL TASK B
-- VIEWS
-- ques 1

CREATE VIEW vwcustomerorder
AS
SELECT 
    company_name,
    orderid,
    orderdate,
    productid,
    productname,
    quantity,
    unitprice,
    quantity * unitprice AS totalprice
FROM customerorders;

select * from vwcustomerorder;

-- ques 2

CREATE VIEW vwcustomerorder_yesterday
AS
SELECT 
    company_name,
    orderid,
    orderdate,
    productid,
    productname,
    quantity,
    unitprice,
    quantity * unitprice AS totalprice
FROM customerorders
WHERE CONVERT(DATE, orderdate) = CONVERT(DATE, DATEADD(DAY, -1, GETDATE())); 

select * from vwcustomerorder_yesterday;


-- ques 3 


CREATE VIEW myproduct
AS
SELECT 
    p.productid,
    p.productname,
    p.quantityperunit,
    p.unitprice,
    s.companyname AS company_name,
    c.categoryname AS categoryname
FROM 
    dbo.products p
JOIN 
    dbo.suppliers s ON p.supplierid = s.supplierid
JOIN 
    dbo.categories c ON p.categoryid = c.categoryid
WHERE 
    p.discontinued = 0;


select * from myproduct;