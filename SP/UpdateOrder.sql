CREATE OR ALTER PROCEDURE Game.UpdateOrder
    @OrderID        INT,
    @GameID         INT,
    @RetailerID     INT,
    @OrderDate      DATETIME2,
    @Quantity       INT
AS
/***************************************************************************************************
File: InsertOrder.sql
----------------------------------------------------------------------------------------------------
Procedure:      Game.UpdateOrder
Create Date:    2021-02-01 (yyyy-mm-dd)
Author:         Sorob Cyrus
Description:    Update an order
Call by:        Game.UpdateOrder, Add hoc

Steps:          1- Check the @GameID for RI issue in Game.Game table
                2- Check the @RetailerID for RI issue in Game.Retailer table
                3- Check the @OrderID for RI issue in Game.Order table
                4- Error out if @TotalAmount < 0
                5- Update table Game.Order

Parameter(s):   @OrderID
                @GameID
                @RetailerID
                @OrderDate
                @Quantity

Usage:          EXEC Game.UpdateOrder @OrderID = 100001,
                                   @GameID = 101,
                                   @RetailerID = 102,
                                   @OrderDate = GETDATE(),
                                   @Quantity = 100

****************************************************************************************************
SUMMARY OF CHANGES
Date(yyyy-mm-dd)    Author              Comments
------------------- ------------------- ------------------------------------------------------------
****************************************************************************************************/
SET NOCOUNT ON;

DECLARE @ErrorText   VARCHAR(MAX),      
        @Message     VARCHAR(255),    
        @StartTime   DATETIME,
        @SP          VARCHAR(50),
        @RowCount    INT,
        
        @TotalAmount MONEY;

BEGIN TRY;   
SET @ErrorText = 'Unexpected ERROR in setting the variables!';

SET @SP = OBJECT_NAME(@@PROCID);
SET @StartTime = GETDATE();

SET @Message = 'Started SP ' + @SP + ' at ' + FORMAT(@StartTime , 'MM/dd/yyyy HH:mm:ss');   
RAISERROR (@Message, 0,1) WITH NOWAIT;
EXEC Game.InsertHistory @SP = @SP,
   @Status = 'Start',
   @Message = @Message

-------------------------------------------------------------------------------
-- Check to give a friendly error for RI Issue.
SET @ErrorText = 'Failed to SELECT from table Order!';
IF NOT EXISTS(SELECT 1
FROM Game.[Order]
WHERE OrderID = @OrderID)
BEGIN
    SET @ErrorText = 'Did not find the Order! OrderID = ' + CONVERT(VARCHAR(10), @OrderID) + ' not found in table Order! Please check the OrderID and try again. Rasing Error!';
    RAISERROR(@ErrorText, 16,1);
END;

SET @ErrorText = 'Failed SELECT from table Game!';
IF NOT EXISTS(SELECT 1
FROM Game.Game
WHERE GameID = @GameID)
BEGIN
    SET @ErrorText = 'GameID = ' + CONVERT(VARCHAR(10), @GameID) + ' not found in table Game! Rasing Error!';
    RAISERROR(@ErrorText, 16,1);
END;

SET @ErrorText = 'Failed SELECT from table Retailer!';
IF NOT EXISTS(SELECT 1
FROM Game.Retailer
WHERE RetailerID = @RetailerID)
BEGIN
    SET @ErrorText = 'RetailerID = ' + CONVERT(VARCHAR(10), @RetailerID) + ' not found in table Retailer! Rasing Error!';
    RAISERROR(@ErrorText, 16,1);
END;

SET @ErrorText = 'Failed check for variable @TotalAmount!';
-- Check for value
IF @TotalAmount < 0
BEGIN
    SET @ErrorText = 'TotalAmout = ' + CONVERT(VARCHAR(10), @TotalAmount) + ' This value is not acceptable. Rasing Error!';
    RAISERROR(@ErrorText, 16,1);
END;

--Get Total Amount
SET @ErrorText = 'Failed calling SP GetTotalAmount!';
EXEC Game.GetTotalAmount  
        @GameID = @GameID, 
        @RetailerID = @RetailerID, 
        @Quantity = @Quantity, 
        @TotalAmount = @TotalAmount OUTPUT;

SET @Message = 'OrderID = ' + CONVERT(VARCHAR(10), @OrderID) + ' is the return value from SP Game.GetTotalAmount.';
RAISERROR (@Message, 0,1) WITH NOWAIT;
EXEC Game.InsertHistory @SP = @SP,
@Status = 'Run',
@Message = @Message;


SET @ErrorText = 'Failed UPDATE to table Order!';
UPDATE Game.[Order]
SET GameID = ISNULL(@GameID, GameID),
    RetailerID = ISNULL(@RetailerID, RetailerID),
    OrderDate = ISNULL(@OrderDate, OrderDate),
    Quantity = ISNULL(@Quantity, Quantity),
    TotalAmount = ISNULL(@TotalAmount, TotalAmount)  
WHERE OrderID = @OrderID

SET @RowCount = @@ROWCOUNT
IF @RowCount <> 1  
BEGIN
    SET @ErrorText = CONVERT(VARCHAR(10), @RowCount) + ' rows effected! OrderID = ' + CONVERT(VARCHAR(10), @OrderID) + ' Should be only one row! UNEXPECTED RESULT! Rasing Error!';
    RAISERROR(@ErrorText, 16,1);
END
ELSE
BEGIN
    SET @Message = CONVERT(VARCHAR(10), @RowCount) + ' rows effected. Completed UPDATE to table Order using OrderID = ' + CONVERT(VARCHAR(10), @OrderID);
    RAISERROR (@Message, 0,1) WITH NOWAIT;
    EXEC Game.InsertHistory @SP = @SP,
    @Status = 'Run',
    @Message = @Message;
END
-------------------------------------------------------------------------------

SET @Message = 'Completed SP ' + @SP + '. Duration in minutes:  '    
      + CONVERT(VARCHAR(12), CONVERT(DECIMAL(6,2),datediff(mi, @StartTime, getdate())));    
RAISERROR (@Message, 0,1) WITH NOWAIT;    
EXEC Game.InsertHistory @SP = @SP,
   @Status = 'End',
   @Message = @Message

END TRY

BEGIN CATCH;      
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;      
      
   SET @ErrorText = 'Error: '+CONVERT(VARCHAR,ISNULL(ERROR_NUMBER(),'NULL'))      
                  +', Severity = '+CONVERT(VARCHAR,ISNULL(ERROR_SEVERITY(),'NULL'))      
                  +', State = '+CONVERT(VARCHAR,ISNULL(ERROR_STATE(),'NULL'))      
                  +', Line = '+CONVERT(VARCHAR,ISNULL(ERROR_LINE(),'NULL'))      
                  +', Procedure = '+CONVERT(VARCHAR,ISNULL(ERROR_PROCEDURE(),'NULL'))      
                  +', Server Error Message = '+CONVERT(VARCHAR(100),ISNULL(ERROR_MESSAGE(),'NULL'))      
                  +', SP Defined Error Text = '+@ErrorText; 

   EXEC Game.InsertHistory @SP = @SP,
   @Status = 'Error',
   @Message = @ErrorText
     
   RAISERROR(@ErrorText,18,127) WITH NOWAIT;      
END CATCH;      

