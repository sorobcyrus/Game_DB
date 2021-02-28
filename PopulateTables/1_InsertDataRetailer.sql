/***************************************************************************************************
File: 1_InsertDataRetailer.sql
----------------------------------------------------------------------------------------------------
Create Date:    2021-02-01 
Author:         Sorob Cyrus
Description:    Inserts needed parameters to table Game.Discount, Game.Retailer (One to Many) 
Call by:        TBD, Add hoc
Steps:          EXEC 1_InsertDataRetailer
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

SET @SP = 'Script-1_InsertDataRetailer';
SET @StartTime = GETDATE();

SET @Message = 'Started SP ' + @SP + ' at ' + FORMAT(@StartTime , 'MM/dd/yyyy HH:mm:ss');   
RAISERROR (@Message, 0,1) WITH NOWAIT;
EXEC Game.InsertHistory @SP = @SP,
   @Status = 'Start',
   @Message = @Message;

-------------------------------------------------------------------------------

SET @ErrorText = 'Failed INSERT to table Discount!';
INSERT INTO Game.Discount
   (DiscountID, [Name], Amount) 
VALUES
   (1, 'Mid-Volume', 5),
   (2, 'Googoolie', 10),
   (3, 'Costonco', 20)

SET @Message = CONVERT(VARCHAR(10), @@ROWCOUNT) + ' rows effected. Completed INSERT to table Discount';   
RAISERROR (@Message, 0,1) WITH NOWAIT;
EXEC Game.InsertHistory @SP = @SP,
   @Status = 'Run',
   @Message = @Message;

-------------------------------------------------------------------------------

SET @ErrorText = 'Failed INSERT to table Retailer!';
INSERT INTO Game.Retailer
   (RetailerID, DiscountID, [Name], Website, [Address], City, Zip)
VALUES
   (101, 1, 'Amazian', 'Amazian.gum', '123 Amazian Rd', 'Seattle', '98133-0001'),
   (102, 2, 'Googoolie', 'Googoolie.gum', '234 Googoolie Rd', 'Boulder', '80303-0001'),
   (103, 3, 'Costonco', 'Constonco.gum', '345 Costonco Rd', 'New York', '10258-0001')

SET @Message = CONVERT(VARCHAR(10), @@ROWCOUNT) + ' rows effected. Completed INSERT to table Retailer';   
RAISERROR (@Message, 0,1) WITH NOWAIT;
EXEC Game.InsertHistory @SP = @SP,
   @Status = 'Run',
   @Message = @Message;
-------------------------------------------------------------------------------

SET @Message = 'Completed SP ' + @SP + '. Duration in minutes:  '   
   + CONVERT(VARCHAR(12), CONVERT(DECIMAL(6,2),datediff(mi, @StartTime, getdate())));    
RAISERROR(@Message, 0,1) WITH NOWAIT;
EXEC Game.InsertHistory @SP = @SP,
   @Status = 'End',
   @Message = @Message;

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
   @Message = @ErrorText;

RAISERROR(@ErrorText,18,127) WITH NOWAIT;
END CATCH;      