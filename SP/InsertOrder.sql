CREATE OR ALTER PROCEDURE Game.InsertOrder
    @GameID         TINYINT,
    @RetailerID     TINYINT,
    @OrderDate      DATETIME2,
    @Quantity       INT
AS
/***************************************************************************************************
File: InsertOrder.sql
----------------------------------------------------------------------------------------------------
Procedure:      Game.InsertOrder
Create Date:    2021-02-01 (yyyy-mm-dd)
Author:         Sorob Cyrus
Description:    Insert an order
Call by:        Game.AddOrder, Add hoc

Steps:          1- Check the @GameID for RI issue in Game.Game table
                2- Check the @RetailerID for RI issue in Game.Retailer table
                3- Get the Max(OrderID)
                3- Calculate @TotalAmount
                4- Insert to table Game.Order

Parameter(s):   @GameID
                @RetailerID
                @OrderDate
                @Quantity

Usage:          Exec Game.InsertOrder   @GameID = 101,
                                        @RetailerID = 101,
                                        @OrderDate = '2021-02-01', 
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

        @OrderID     INT,
        @TotalAmount MONEY

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
SET @ErrorText = 'Failed SELECT from table Game!';
-- Check to give a friendly error for RI Issue.
IF NOT EXISTS(SELECT 1
FROM Game.Game
WHERE GameID = @GameID)
BEGIN
    SET @ErrorText = 'GameID = ' + CONVERT(VARCHAR(10), @GameID) + ' not found in table Game! Rasing Error!';
    RAISERROR(@ErrorText, 16,1);
END;

SET @ErrorText = 'Failed SELECT from table Retailer!';
-- Check to give a friendly error for RI Issue.
IF NOT EXISTS(SELECT 1
FROM Game.Retailer
WHERE RetailerID = @RetailerID)
BEGIN
    SET @ErrorText = 'RetailerID = ' + CONVERT(VARCHAR(10), @RetailerID) + ' not found in table Retailer! Rasing Error!';
    RAISERROR(@ErrorText, 16,1);
END;

-------------------------------------------------------------------------------
-- Get Max OrderID, in order to insert new record to Order table.
SET @ErrorText = 'Failed calling SP GetMaxOrderID!';
EXEC Game.GetMaxOrderID @MaxOrderID = @OrderID OUTPUT;

SET @Message = 'OrderID = ' + CONVERT(VARCHAR(10), @OrderID) + ' is the return value from SP Game.GetMaxOrderID.';
RAISERROR (@Message, 0,1) WITH NOWAIT;
EXEC Game.InsertHistory @SP = @SP,
@Status = 'Run',
@Message = @Message;

--  Get total amount
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
-------------------------------------------------------------------------------

SET @ErrorText = 'Failed INSERT to table Order!';
INSERT INTO Game.[Order]
    (OrderID, GameID, RetailerID, OrderDate, Quantity, TotalAmount)
VALUES
    (@OrderID, @GameID, @RetailerID, @OrderDate, @Quantity, @TotalAmount)

SET @Message = CONVERT(VARCHAR(10), @@ROWCOUNT) + ' rows effected. Completed INSERT to table Order using OrderID = ' + CONVERT(VARCHAR(10), @OrderID) ;   
RAISERROR (@Message, 0,1) WITH NOWAIT;
EXEC Game.InsertHistory @SP = @SP,
   @Status = 'Run',
   @Message = @Message
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

