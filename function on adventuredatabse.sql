-- LEVEL B Task
-- ques 1

USE AdventureWorks2014;
GO

CREATE PROCEDURE InsertOrderDetails
    @OrderID INT,
    @ProductID INT,
    @UnitPrice MONEY = NULL,
    @Quantity INT,
    @Discount DECIMAL(5, 2) = 0
AS
BEGIN
    DECLARE @CurrentUnitPrice MONEY;
    DECLARE @UnitsInStock INT;
    DECLARE @ReorderLevel INT;
    DECLARE @ProductModifiedDate DATETIME;
    
    -- Retrieve current UnitPrice from the Product table if not provided
    IF @UnitPrice IS NULL
    BEGIN
        SELECT @CurrentUnitPrice = ListPrice
        FROM Production.Product
        WHERE ProductID = @ProductID;
    END
    ELSE
    BEGIN
        SET @CurrentUnitPrice = @UnitPrice;
    END
    
    -- Retrieve UnitsInStock
    SELECT @UnitsInStock = SUM(Quantity)
    FROM Production.ProductInventory
    WHERE ProductID = @ProductID;
    
    -- Check if there is enough stock
    IF @UnitsInStock < @Quantity
    BEGIN
        PRINT 'Not enough stock. Order aborted.';
        RETURN;
    END

    -- Insert order details
    INSERT INTO Sales.SalesOrderDetail (SalesOrderID, ProductID, UnitPrice, OrderQty, UnitPriceDiscount)
    VALUES (@OrderID, @ProductID, @CurrentUnitPrice, @Quantity, @Discount);

    -- Check if the order was inserted successfully
    IF @@ROWCOUNT = 0
    BEGIN
        PRINT 'Failed to place the order. Please try again.';
        RETURN;
    END

    -- Update the UnitsInStock
    UPDATE Production.ProductInventory
    SET Quantity = Quantity - @Quantity
    WHERE ProductID = @ProductID;

    -- Retrieve UnitsInStock again to check against ReorderLevel
    SELECT @UnitsInStock = SUM(Quantity)
    FROM Production.ProductInventory
    WHERE ProductID = @ProductID;

    -- Assuming ReorderLevel is stored in the Product table (adjust if needed)
    SELECT @ReorderLevel = ReorderPoint
    FROM Production.Product
    WHERE ProductID = @ProductID;

    -- Check if UnitsInStock drops below ReorderLevel and print message
    IF @UnitsInStock < @ReorderLevel
    BEGIN
        PRINT 'Warning: Quantity in stock has dropped below the reorder level.';
    END
END;
GO



-- ques 2

USE AdventureWorks2014;
GO


CREATE PROCEDURE UpdateOrderDetails
    @OrderID INT,
    @ProductID INT,
    @UnitPrice MONEY = NULL,
    @Quantity INT = NULL,
    @Discount DECIMAL(5, 2) = NULL
AS
BEGIN
    DECLARE @CurrentUnitPrice MONEY;
    DECLARE @CurrentQuantity INT;
    DECLARE @CurrentDiscount DECIMAL(5, 2);
    DECLARE @OldQuantity INT;
    DECLARE @NewQuantity INT;

    -- Start a transaction
    BEGIN TRANSACTION;

    -- Get current values from SalesOrderDetail
    SELECT @CurrentUnitPrice = UnitPrice,
           @CurrentQuantity = OrderQty,
           @CurrentDiscount = UnitPriceDiscount
    FROM Sales.SalesOrderDetail
    WHERE SalesOrderID = @OrderID AND ProductID = @ProductID;

    -- Retain original values if parameters are NULL
    SET @UnitPrice = ISNULL(@UnitPrice, @CurrentUnitPrice);
    SET @Quantity = ISNULL(@Quantity, @CurrentQuantity);
    SET @Discount = ISNULL(@Discount, @CurrentDiscount);

    -- Calculate the adjustment for UnitsInStock
    SET @OldQuantity = @CurrentQuantity;
    SET @NewQuantity = @Quantity;

    -- Update SalesOrderDetail with new values
    UPDATE Sales.SalesOrderDetail
    SET UnitPrice = @UnitPrice,
        OrderQty = @Quantity,
        UnitPriceDiscount = @Discount
    WHERE SalesOrderID = @OrderID AND ProductID = @ProductID;

    -- Adjust UnitsInStock in ProductInventory
    UPDATE Production.ProductInventory
    SET Quantity = Quantity + (@OldQuantity - @NewQuantity)
    WHERE ProductID = @ProductID;

    -- Commit the transaction
    COMMIT TRANSACTION;
END;
GO


--ques 3

USE AdventureWorks2014;
GO

IF OBJECT_ID('GetOrderDetail', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE GetOrderDetail;
END;
GO

CREATE PROCEDURE GetOrderDetail
    @OrderID INT
AS
BEGIN
    -- Check if any records exist for the given OrderID
    IF NOT EXISTS (SELECT 1 FROM Sales.SalesOrderDetail WHERE SalesOrderID = @OrderID)
    BEGIN
        PRINT 'The orderid ' + CAST(@OrderID AS VARCHAR(10)) + ' does not exist';
        RETURN 1;
    END
    
    -- If records exist, return the details
    SELECT 
        SalesOrderID,
        ProductID,
        OrderQty,
        UnitPrice,
        UnitPriceDiscount,
        LineTotal
    FROM 
        Sales.SalesOrderDetail
    WHERE 
        SalesOrderID = @OrderID;
END;
GO


--ques 4

USE AdventureWorks2014;
GO

IF OBJECT_ID('DeleteOrderDetails', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE DeleteOrderDetails;
END;
GO

CREATE PROCEDURE DeleteOrderDetails
    @OrderID INT,
    @ProductID INT
AS
BEGIN
    -- Check if the OrderID exists
    IF NOT EXISTS (SELECT 1 FROM Sales.SalesOrderDetail WHERE SalesOrderID = @OrderID)
    BEGIN
        PRINT 'Error: The OrderID ' + CAST(@OrderID AS VARCHAR(10)) + ' does not exist.';
        RETURN -1;
    END
    
    -- Check if the ProductID exists for the given OrderID
    IF NOT EXISTS (SELECT 1 FROM Sales.SalesOrderDetail WHERE SalesOrderID = @OrderID AND ProductID = @ProductID)
    BEGIN
        PRINT 'Error: The ProductID ' + CAST(@ProductID AS VARCHAR(10)) + ' does not exist for the given OrderID ' + CAST(@OrderID AS VARCHAR(10)) + '.';
        RETURN -1;
    END
    
    -- Delete the record from SalesOrderDetail
    DELETE FROM Sales.SalesOrderDetail
    WHERE SalesOrderID = @OrderID AND ProductID = @ProductID;
    
    PRINT 'The order detail with OrderID ' + CAST(@OrderID AS VARCHAR(10)) + ' and ProductID ' + CAST(@ProductID AS VARCHAR(10)) + ' has been deleted.';
END;
GO
