CREATE OR ALTER PROCEDURE Game.GetTotalAmount
    @GameID         TINYINT,
    @RetailerID     TINYINT,
    @Quantity       INT,
    @TotalAmount    MONEY OUTPUT
AS

/***************************************************************************************************
File: GetTotalAmount.sql
----------------------------------------------------------------------------------------------------
Create Date:    2021-02-01 
Author:         Sorob Cyrus
Description:    Gets Game's Total Amount for the Order (Quantity*Price/Discount).
Call by:        Add hoc
Steps:          N/A 
****************************************************************************************************
SUMMARY OF CHANGES
Date(yyyy-mm-dd)    Author              Comments
------------------- ------------------- ------------------------------------------------------------
****************************************************************************************************/
SET NOCOUNT ON;

DECLARE @ErrorText      VARCHAR(MAX),      
        @Message        VARCHAR(255),    
        @StartTime      DATETIME,
        @SP             VARCHAR(50),

        @Price          MONEY,
        @Discount       TINYINT,
        @DiscountAmount MONEY,
        @Pretotal       MONEY

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
-- Calculate Total Amount for an Order

SET @ErrorText = 'Failed Get TotalAmount!';
SET @Discount = (SELECT Amount 
                    FROM Discount 
                        JOIN Retailer 
                        ON Discount.DiscountID = Retailer.DiscountID
                    WHERE Retailer.RetailerID = @RetailerID);
SET @Price = (SELECT Price
                FROM Game
                WHERE GameID = @GameID)

SET @Pretotal = @Price * @Quantity
SET @DiscountAmount = @Pretotal * (@Discount / 100)
SET @TotalAmount = @Pretotal - @DiscountAmount

IF(@TotalAmount <= 0)
BEGIN
    SET @ErrorText = 'Total Amount' + CONVERT(VARCHAR(10), @TotalAmount) + ' is not acceptable!';
    RAISERROR(@ErrorText, 16, 1);
END;
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
