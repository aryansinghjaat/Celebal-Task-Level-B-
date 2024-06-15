-- LEVEL TASK B 
-- TRIGGERS
-- ques 1

CREATE TRIGGER IO_DeleteOrderDetailsAndOrder
ON Orders
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Delete from Order Details first
    DELETE FROM [Order Details]
    WHERE OrderID IN (SELECT OrderID FROM deleted);

    -- Then delete from Orders
    DELETE FROM Orders
    WHERE OrderID IN (SELECT OrderID FROM deleted);
END;
GO


-- ques 2

CREATE TRIGGER IO_CheckStockAndInsertOrder
ON OrderDetails
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if there's sufficient stock
    IF EXISTS (
        SELECT p.ProductID, p.UnitsInStock, i.ProductID, i.Quantity
        FROM inserted i
        INNER JOIN Products p ON i.ProductID = p.ProductID
        WHERE p.UnitsInStock >= i.Quantity
    )
    BEGIN
        -- Update UnitsInStock and insert into OrderDetails
        UPDATE p
        SET p.UnitsInStock = p.UnitsInStock - i.Quantity
        FROM Products p
        INNER JOIN inserted i ON p.ProductID = i.ProductID;

        INSERT INTO OrderDetails (OrderID, ProductID, Quantity)
        SELECT OrderID, ProductID, Quantity
        FROM inserted;
    END
    ELSE
    BEGIN
        -- Insufficient stock notification
        RAISERROR ('Order could not be filled due to insufficient stock.', 16, 1);
    END
END;
GO


