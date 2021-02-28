/***************************************************************************************************
File: 1_InsertDataGameAndTeam.sql
----------------------------------------------------------------------------------------------------
Create Date:    2021-02-01 
Author:         Sorob Cyrus
Description:    Inserts needed parameters to table Game.Game, Game.Team and Game.GameTeam (Many to Many) 
Call by:        TBD, Add hoc
Steps:          EXEC 1_InsertDataGameAndTeam
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

SET @SP = 'Script-1_InsertDataPartner';
SET @StartTime = GETDATE();

SET @Message = 'Started SP ' + @SP + ' at ' + FORMAT(@StartTime , 'MM/dd/yyyy HH:mm:ss');   
RAISERROR (@Message, 0,1) WITH NOWAIT;
EXEC Game.InsertHistory @SP = @SP,
   @Status = 'Start',
   @Message = @Message;

-------------------------------------------------------------------------------

SET @ErrorText = 'Failed INSERT to table Type!';
INSERT INTO Game.Type
   (TypeID, [Name], Note)
VALUES
   (1, 'Strategy', 'Games based on strategy'),
   (2, 'Brain Games', 'Games to improve cognitive behaviour'),
   (3, 'War Games', 'Games based on killing nature'),
   (4, 'Politics', 'Games based on politics'),
   (5, 'Romantic', 'Games nobody wants to play')

SET @Message = CONVERT(VARCHAR(10), @@ROWCOUNT) + ' rows effected. Completed INSERT to table Game';   
RAISERROR (@Message, 0,1) WITH NOWAIT;
EXEC Game.InsertHistory @SP = @SP,
   @Status = 'Run',
   @Message = @Message;

-------------------------------------------------------------------------------

SET @ErrorText = 'Failed INSERT to table Game!';
INSERT INTO Game.Game
   (GameID, TypeID, PartnerID, [Name], Price, Note)
VALUES
   (101, 1, 101, 'Stratigists Concur', 75.99, 'A game to stratigize and to concur'),
   (102, 2, 101, 'Chess match ultimate', 54.99, 'How to be a gracious loser'),
   (103, 5, 102, 'Band of firends', 99.99, 'Survive the war with a stick and some stones'),
   (104, 3, 103, 'Red-White rose', 29.99, 'Plant red or white roses then fight over them')

SET @Message = CONVERT(VARCHAR(10), @@ROWCOUNT) + ' rows effected. Completed INSERT to table Game';   
RAISERROR (@Message, 0,1) WITH NOWAIT;
EXEC Game.InsertHistory @SP = @SP,
   @Status = 'Run',
   @Message = @Message;
-------------------------------------------------------------------------------

SET @ErrorText = 'Failed INSERT to table Team!';
INSERT INTO Game.Team
   (TeamID, [Name], Note)
VALUES
   (11, 'GoodGuys', 'A group of juniors working on easy stuff'),
   (12, 'BetterOnes', 'Agile group of developers in their 40+'),
   (14, 'WorstGuys', 'Advanced team of developers dealing with bad situations'),
   (15, 'SmartOnes', 'Elite team of developers, with fastest Vacation requests')

SET @Message = CONVERT(VARCHAR(10), @@ROWCOUNT) + ' rows effected. Completed INSERT to table Team';   
RAISERROR (@Message, 0,1) WITH NOWAIT;
EXEC Game.InsertHistory @SP = @SP,
   @Status = 'Run',
   @Message = @Message;
-------------------------------------------------------------------------------

SET @ErrorText = 'Failed INSERT to table GameTeam!';
INSERT INTO Game.GameTeam
   (GameID, TeamID, RoyaltyPer)
VALUES
   (101, 11, 2),
   (102, 11, 4),
   (102, 12, 6),
   (102, 15, 10),
   (103, 11, 2),
   (103, 12, 6),
   (143, 11, 4),
   (104, 14, 8 )

SET @Message = CONVERT(VARCHAR(10), @@ROWCOUNT) + ' rows effected. Completed INSERT to table Team';   
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
