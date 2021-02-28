CREATE OR ALTER PROCEDURE Game.CreateFKs
AS
/***************************************************************************************************
File: CreateTables.sql
----------------------------------------------------------------------------------------------------
Procedure:      Game.CreateFKs
Create Date:    2021-02-01 
Author:         Sorob Cyrus
Description:    Creates all needed Game FKs  
Call by:        TBD, UI, Add hoc
Steps:          NA
Parameter(s):   None
Usage:          EXEC Game.CreateFKs
****************************************************************************************************
SUMMARY OF CHANGES
Date			Author				Comments 
------------------- ------------------- ------------------------------------------------------------
****************************************************************************************************/
SET NOCOUNT ON;

DECLARE @ErrorText VARCHAR(MAX),      
        @Message   VARCHAR(255),   
        @StartTime DATETIME,
        @SP        VARCHAR(50)

BEGIN TRY;   
SET @ErrorText = 'Unexpected ERROR in setting the variables!';  

SET @SP = OBJECT_NAME(@@PROCID)
SET @StartTime = GETDATE();    
SET @Message = 'Started SP ' + @SP + ' at ' + FORMAT(@StartTime , 'MM/dd/yyyy HH:mm:ss');  
 
RAISERROR (@Message, 0,1) WITH NOWAIT;
EXEC Game.InsertHistory @SP = @SP,
    @Status = 'Start',
    @Message = @Message;
-------------------------------------------------------------------------------
SET @ErrorText = 'Failed adding FOREIGN KEY for Table Game.PartnerInfo.';

IF EXISTS (SELECT *
	FROM sys.foreign_keys
	WHERE object_id = OBJECT_ID(N'Game.FK_PartnerInfo_Partner_PartnerID')
	AND parent_object_id = OBJECT_ID(N'Game.PartnerInfo')
	)
BEGIN
  SET @Message = 'FOREIGN KEY for Table Game.PartnerInfo already exist, skipping....';
  RAISERROR(@Message, 0,1) WITH NOWAIT;
  EXEC Game.InsertHistory @SP = @SP,
        @Status = 'Run',
        @Message = @Message;
END
ELSE
BEGIN
  ALTER TABLE Game.PartnerInfo
	ADD CONSTRAINT FK_PartnerInfo_Partner_PartnerID FOREIGN KEY (PartnerID)
    REFERENCES Game.Partner (PartnerID);

  SET @Message = 'Completed adding FOREIGN KEY for TABLE Game.PartnerInfo.';
  RAISERROR(@Message, 0,1) WITH NOWAIT;
  EXEC Game.InsertHistory @SP = @SP,
   @Status = 'Run',
   @Message = @Message;
END
-------------------------------------------------------------------------------

SET @ErrorText = 'Failed adding FOREIGN KEY for Table Game.Game.';

IF EXISTS (SELECT *
	FROM sys.foreign_keys
	WHERE object_id = OBJECT_ID(N'Game.FK_Game_Partner_PartnerID')
	AND parent_object_id = OBJECT_ID(N'Game.Game')
)
BEGIN
  SET @Message = 'FOREIGN KEY for Table Game.Game already exist, skipping....';
  RAISERROR(@Message, 0,1) WITH NOWAIT;
  EXEC Game.InsertHistory @SP = @SP,
   @Status = 'Run',
   @Message = @Message;
END
ELSE
BEGIN
  ALTER TABLE Game.Game
   ADD CONSTRAINT FK_Game_Partner_PartnerID FOREIGN KEY (PartnerID)
      REFERENCES Game.Partner (PartnerID),
   CONSTRAINT FK_Game_Type_TypeID FOREIGN KEY (TypeID)
      REFERENCES Game.Type (TypeID);
      
  SET @Message = 'Completed adding FOREIGN KEY for TABLE Game.Game.';
  RAISERROR(@Message, 0,1) WITH NOWAIT;
  EXEC Game.InsertHistory @SP = @SP,
   @Status = 'Run',
   @Message = @Message;
END
-------------------------------------------------------------------------------

SET @ErrorText = 'Failed adding FOREIGN KEY for Table Game.GameTeam.';

IF EXISTS (SELECT *
	FROM sys.foreign_keys
	WHERE object_id = OBJECT_ID(N'Game.FK_GameTeam_Game_GameID')
	AND parent_object_id = OBJECT_ID(N'Game.GameTeam')
)
BEGIN
  SET @Message = 'FOREIGN KEY for Table Game.GameTeam already exist, skipping....';
  RAISERROR(@Message, 0,1) WITH NOWAIT;
  EXEC Game.InsertHistory @SP = @SP,
   @Status = 'Run',
   @Message = @Message;
END
ELSE
BEGIN
  ALTER TABLE Game.GameTeam
   ADD CONSTRAINT FK_GameTeam_Game_GameID FOREIGN KEY (GameID)
      REFERENCES Game.Game (GameID),
    CONSTRAINT FK_GameTeam_Team_TeamID FOREIGN KEY (TeamID)
      REFERENCES Game.[Team] (TeamID);

  SET @Message = 'Completed adding FOREIGN KEY for TABLE Game.GameTeam.';
  RAISERROR(@Message, 0,1) WITH NOWAIT;
  EXEC Game.InsertHistory @SP = @SP,
   @Status = 'Run',
   @Message = @Message;
END
-------------------------------------------------------------------------------

SET @ErrorText = 'Failed adding FOREIGN KEY for Table Game.Order.';

IF EXISTS (SELECT *
	FROM sys.foreign_keys
	WHERE object_id = OBJECT_ID(N'Game.FK_Order_Game_GameID')
	AND parent_object_id = OBJECT_ID(N'Game.Order')
)
BEGIN
  SET @Message = 'FOREIGN KEY for Table Game.Order already exist, skipping....';
  RAISERROR(@Message, 0,1) WITH NOWAIT;
  EXEC Game.InsertHistory @SP = @SP,
   @Status = 'Run',
   @Message = @Message;
END
ELSE
BEGIN
  ALTER TABLE Game.[Order]
   ADD CONSTRAINT FK_Order_Game_GameID FOREIGN KEY (GameID)
      REFERENCES Game.Game (GameID),
   CONSTRAINT FK_Order_Retailer_RetailerID FOREIGN KEY (RetailerID)
      REFERENCES Game.Retailer (RetailerID);
      
  SET @Message = 'Completed adding FOREIGN KEY for TABLE Game.Order.';
  RAISERROR(@Message, 0,1) WITH NOWAIT;
  EXEC Game.InsertHistory @SP = @SP,
   @Status = 'Run',
   @Message = @Message;
END

-------------------------------------------------------------------------------

SET @ErrorText = 'Failed adding FOREIGN KEY for Table Game.Retailer.';

IF EXISTS (SELECT *
	FROM sys.foreign_keys
	WHERE object_id = OBJECT_ID(N'Game.FK_Retailer_Discount_DiscountID')
	AND parent_object_id = OBJECT_ID(N'Game.Retailer')
)
BEGIN
  SET @Message = 'FOREIGN KEY for Table Game.Retailer already exist, skipping....';
  RAISERROR(@Message, 0,1) WITH NOWAIT;
  EXEC Game.InsertHistory @SP = @SP,
   @Status = 'Run',
   @Message = @Message;
END
ELSE
BEGIN
  ALTER TABLE Game.Retailer
   ADD CONSTRAINT FK_Retailer_Discount_DiscountID FOREIGN KEY (DiscountID)
      REFERENCES Game.Discount (DiscountID);
      
  SET @Message = 'Completed adding FOREIGN KEY for TABLE Game.Retailer.';
  RAISERROR(@Message, 0,1) WITH NOWAIT;
  EXEC Game.InsertHistory @SP = @SP,
   @Status = 'Run',
   @Message = @Message;
END
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

