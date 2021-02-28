CREATE OR ALTER PROCEDURE Game.DeleteOrder
    @OrderID INT
AS
/***************************************************************************************************
File: DeleteOrder.sql
----------------------------------------------------------------------------------------------------
Procedure:      Game.DeleteOrder
Create Date:    2021-02-01 (yyyy-mm-dd)
Author:         Sorob Cyrus
Description:    Deletes an Order 
Call by:        TBD, UI, Add hoc
Steps:          N/A
Parameter(s):   @LocationID
Usage:          Game.DeleteOrder 1001
****************************************************************************************************
SUMMARY OF CHANGES
Date(yyyy-mm-dd)    Author              Comments
------------------- ------------------- ------------------------------------------------------------
****************************************************************************************************/
SET NOCOUNT ON;

DECLARE @ErrorText VARCHAR(MAX),      
        @Message   VARCHAR(255),   
        @StartTime DATETIME,
        @SP        VARCHAR(50)

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
SET @ErrorText = 'Failed DELETE from Order table.';

IF(NOT EXISTS(SELECT 1
FROM Game.[Order]))
BEGIN
    SET @ErrorText = 'Order table is Empty Rasing Error!';
    RAISERROR(@ErrorText, 16,1);
END;

BEGIN TRAN;

DELETE FROM Game.[Order]
WHERE OrderID = @OrderID;
IF @@ROWCOUNT = 0  
BEGIN
    SET @ErrorText = 'OrderID = ' + CONVERT(VARCHAR(10), @OrderID) + ' Not found in table Order! Rasing Error!';
    RAISERROR(@ErrorText, 16,1);
END;

SET @Message = 'Completed DELETE from Order table for OrderID = ' + CONVERT(VARCHAR(10), @OrderID) ;   
RAISERROR(@Message, 0,1) WITH NOWAIT;
EXEC Game.InsertHistory @SP = @SP,
   @Status = 'Run',
   @Message = @Message

COMMIT TRAN;

-------------------------------------------------------------------------------

SET @Message = 'Completed SP ' + @SP + '. Duration in minutes:  '   
   + CONVERT(VARCHAR(12), CONVERT(DECIMAL(6,2),datediff(mi, @StartTime, getdate())));    
RAISERROR(@Message, 0,1) WITH NOWAIT;
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

