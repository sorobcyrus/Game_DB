/***************************************************************************************************
File: 01_RebuildTables.sql
----------------------------------------------------------------------------------------------------
Create Date:    2021-02-01 (yyyy-mm-dd)
Author:         Sorob Cyrus
Description:    Rebuilds all needed tables for rbuilding the enviornment
Call by:        TBD, Add hoc

Steps:          1- Call SP Game.DropTableConstraints 
                2- Call SP Game.DropTables
                3- Call SP Game.CreateHistoryTable
                4- Call SP Game.CreateParameterTable
                5- Call SP Game.CreateTables

****************************************************************************************************
SUMMARY OF CHANGES
Date(yyyy-mm-dd)    Author              Comments
------------------- ------------------- ------------------------------------------------------------
****************************************************************************************************/
SET NOCOUNT ON;

DECLARE @ErrorText VARCHAR(MAX),      
        @Message   VARCHAR(255),   
        @StartTime DATETIME

BEGIN TRY;   
SET @ErrorText = 'Unexpected ERROR in setting the variables!';

SET @StartTime = GETDATE();
SET @Message = 'Started at ' + FORMAT(@StartTime , 'MM/dd/yyyy HH:mm:ss');   

-------------------------------------------------------------------------------
SET @ErrorText = 'Failed Calling SP DropTableConstraints!';

EXEC Game.DropTableConstraints;

SET @Message = 'Completed SP DropTableConstraints';   
RAISERROR(@Message, 0,1) WITH NOWAIT;
-------------------------------------------------------------------------------

SET @ErrorText = 'Failed Calling SP DropTables!';

EXEC Game.DropTables;

SET @Message = 'Completed SP DropTables';   
RAISERROR(@Message, 0,1) WITH NOWAIT;
-------------------------------------------------------------------------------

SET @ErrorText = 'Failed Calling SP CreateHistoryTable!';

EXEC Game.CreateHistoryTable;

SET @Message = 'Completed SP CreateHistoryTable';   
RAISERROR(@Message, 0,1) WITH NOWAIT;
-------------------------------------------------------------------------------

SET @ErrorText = 'Failed Calling SP CreateParameterTable!';

EXEC Game.CreateParameterTable

SET @Message = 'Completed SP CreateParameterTable';   
RAISERROR(@Message, 0,1) WITH NOWAIT;
-------------------------------------------------------------------------------

SET @ErrorText = 'Failed Calling SP CreateTables!';

EXEC Game.CreateTables;

SET @Message = 'Completed SP CreateTables';   
RAISERROR(@Message, 0,1) WITH NOWAIT;
-------------------------------------------------------------------------------

SET @Message = 'Completed, duration in minutes:  '   
   + CONVERT(VARCHAR(12), CONVERT(DECIMAL(6,2),datediff(mi, @StartTime, getdate())));    

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

   RAISERROR(@ErrorText,18,127) WITH NOWAIT;      
END CATCH;      

