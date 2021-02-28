CREATE OR ALTER PROCEDURE Game.CreateTables
AS
/***************************************************************************************************
File: CreateTables.sql
----------------------------------------------------------------------------------------------------
Procedure:      Game.CreateTables
Create Date:    2021-02-01 
Author:         Sorob Cyrus
Description:    Creates all needed Game tables  
Call by:        TBD, UI, Add hoc
Steps:          NA
Parameter(s):   None
Usage:          EXEC Game.CreateTables
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
Set @ErrorText = 'Failed CREATE Table Game.Parameter.';

IF EXISTS (SELECT * 
    FROM sys.objects
    WHERE object_id = OBJECT_ID(N'Game.Parameter') AND type in (N'U'))
BEGIN 
    SET @Message = 'Table Game.Parameter already exists, Skipping CREATE TABLE...';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
	EXEC Game.InsertHistory @SP = @SP,
		@Status = 'Error',
		@Message = @Message;
END
ELSE
BEGIN
    CREATE TABLE Game.Parameter
    (
        [Name]          VARCHAR(50)     NOT NULL,
        NumValue        INT             NOT NULL,
        CharValue       VARCHAR(20)     NULL,
        Note            varchar(250)    NULL
    );

    SET @Message = 'Completed CREATE TABLE Game.Parameter.';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
	EXEC Game.InsertHistory @SP = @SP,
		@Status = 'Run',
		@Message = @Message;
END
---------------------------------------------------------------------------------------

Set @ErrorText = 'Failed CREATE Table Game.Partner.';

IF EXISTS (SELECT * 
    FROM sys.objects
    WHERE object_id = OBJECT_ID(N'Game.Partner') AND type in (N'U'))
BEGIN 
    SET @Message = 'Table Game.Partner already exists, Skipping CREATE TABLE...';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
	EXEC Game.InsertHistory @SP = @SP,
		@Status = 'Error',
		@Message = @Message;
END
ELSE
BEGIN
    CREATE TABLE Game.[Partner]
    (
        PartnerID    TINYINT         NOT NULL,
        [Name]       VARCHAR(50) NOT NULL,
        CONSTRAINT PK_Partner_PartnerID PRIMARY KEY CLUSTERED(PartnerID)
    );

    SET @Message = 'Completed CREATE TABLE Game.Partner.';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
	EXEC Game.InsertHistory @SP = @SP,
		@Status = 'Run',
		@Message = @Message;
END
---------------------------------------------------------------------------------------

Set @ErrorText = 'Failed CREATE Table Game.PartnerInfo.';

IF EXISTS (SELECT * 
    FROM sys.objects
    WHERE object_id = OBJECT_ID(N'Game.PartnerInfo') AND type in (N'U'))
BEGIN 
    SET @Message = 'Table Game.PartnerInfo already exists, Skipping CREATE TABLE...';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
	EXEC Game.InsertHistory @SP = @SP,
		@Status = 'Error',
		@Message = @Message;
END
ELSE  
BEGIN
    CREATE TABLE Game.[PartnerInfo]
    (
        PartnerID       TINYINT         NOT NULL,
        Website         VARCHAR(250)    NULL,
        City            VARCHAR(50)     NOT NULL,
        [State]         VARCHAR(2)      NOT NULL,
        Country         VARCHAR(50)     NULL,
        Note            VARCHAR(250)    NULL,
        CONSTRAINT PK_PartnerInfo_PartnerID PRIMARY KEY CLUSTERED(PartnerID)
    );

    SET @Message = 'Completed CREATE TABLE Game.PartnerInfo.';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
	EXEC Game.InsertHistory @SP = @SP,
		@Status = 'Run',
		@Message = @Message;
END
---------------------------------------------------------------------------------------

Set @ErrorText = 'Failed CREATE Table Game.Game.';

IF EXISTS (SELECT * 
    FROM sys.objects
    WHERE object_id = OBJECT_ID(N'Game.Game') AND type in (N'U'))
BEGIN 
    SET @Message = 'Table Game.Game already exists, Skipping CREATE TABLE...';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
	EXEC Game.InsertHistory @SP = @SP,
		@Status = 'Error',
		@Message = @Message;
END
ELSE
BEGIN
    CREATE TABLE Game.[Game]
    (
        GameID       TINYINT        NOT NULL,
        TypeID       TINYINT        NOT NULL,
        PartnerID    TINYINT        NOT NULL,
        [Name]       VARCHAR(50)    NOT NULL,
        Price        MONEY          NOT NULL,  
        Note         VARCHAR(250)   NULL,
        CONSTRAINT PK_Game_GameID PRIMARY KEY CLUSTERED(GameID),
        CONSTRAINT CK_Game_Price CHECK (Price >= 0)
    );

    SET @Message = 'Completed CREATE TABLE Game.Game.';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
	EXEC Game.InsertHistory @SP = @SP,
		@Status = 'Run',
		@Message = @Message;
END
---------------------------------------------------------------------------------------

Set @ErrorText = 'Failed CREATE Table Game.Team.';

IF EXISTS (SELECT * 
    FROM sys.objects
    WHERE object_id = OBJECT_ID(N'Game.Team') AND type in (N'U'))
BEGIN 
    SET @Message = 'Table Game.Team already exists, Skipping CREATE TABLE...';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
	EXEC Game.InsertHistory @SP = @SP,
		@Status = 'Error',
		@Message = @Message;
END
ELSE
BEGIN
    CREATE TABLE Game.[Team]
    (
        TeamID       TINYINT        NOT NULL,
        [Name]       VARCHAR(50)    NOT NULL,
        Note         VARCHAR(250)   NULL,
        CONSTRAINT PK_Team_TeamID PRIMARY KEY CLUSTERED(TeamID)
    );

    SET @Message = 'Completed CREATE TABLE Game.Team.';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
	EXEC Game.InsertHistory @SP = @SP,
		@Status = 'Run',
		@Message = @Message;
END
---------------------------------------------------------------------------------------

Set @ErrorText = 'Failed CREATE Table Game.GameTeam.';

IF EXISTS (SELECT * 
    FROM sys.objects
    WHERE object_id = OBJECT_ID(N'Game.GameTeam') AND type in (N'U'))
BEGIN 
    SET @Message = 'Table Game.GameTeam already exists, Skipping CREATE TABLE...';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
	EXEC Game.InsertHistory @SP = @SP,
		@Status = 'Error',
		@Message = @Message;
END
ELSE 
BEGIN
    CREATE TABLE Game.GameTeam
    (
        GameID       TINYINT        NOT NULL,
        TeamID       TINYINT        NOT NULL,
        RoyaltyPer   MONEY          NOT NULL,  
        CONSTRAINT PK_GameTeam_GameID_TeamID PRIMARY KEY CLUSTERED(GameID, TeamID),
        CONSTRAINT CK_GameTeam_RoyaltyPer CHECK (RoyaltyPer >= 0)
    );

    SET @Message = 'Completed CREATE TABLE Game.GameTeam.';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
	EXEC Game.InsertHistory @SP = @SP,
		@Status = 'Run',
		@Message = @Message;
END
---------------------------------------------------------------------------------------

Set @ErrorText = 'Failed CREATE Table Game.Type.';

IF EXISTS (SELECT * 
    FROM sys.objects
    WHERE object_id = OBJECT_ID(N'Game.Type') AND type in (N'U'))
BEGIN 
    SET @Message = 'Table Game.Type already exists, Skipping CREATE TABLE...';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
	EXEC Game.InsertHistory @SP = @SP,
		@Status = 'Error',
		@Message = @Message;
END
ELSE  
BEGIN
    CREATE TABLE Game.[Type]
    (
        TypeID       TINYINT        NOT NULL,
        [Name]       VARCHAR(50)    NOT NULL,
        Note         VARCHAR(250)   NULL,
        CONSTRAINT PK_Type_TypeID PRIMARY KEY CLUSTERED(TypeID)
    );

    SET @Message = 'Completed CREATE TABLE Game.Type.';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
	EXEC Game.InsertHistory @SP = @SP,
		@Status = 'Run',
		@Message = @Message;
END
---------------------------------------------------------------------------------------

Set @ErrorText = 'Failed CREATE Table Game.Order.';

IF EXISTS (SELECT * 
    FROM sys.objects
    WHERE object_id = OBJECT_ID(N'Game.Order') AND type in (N'U'))
BEGIN 
    SET @Message = 'Table Game.Order already exists, Skipping CREATE TABLE...';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
	EXEC Game.InsertHistory @SP = @SP,
		@Status = 'Error',
		@Message = @Message;
END
ELSE
BEGIN
    CREATE TABLE Game.[Order]
    (
        OrderID         INT         NOT NULL,
        GameID          TINYINT     NOT NULL,
        RetailerID      TINYINT     NOT NULL,
        OrderDate       DATETIME    NOT NULL,
        Quantity        INT         NOT NULL,
        TotalAmount     MONEY       NOT NULL,
        CONSTRAINT PK_Order_OrderID PRIMARY KEY CLUSTERED(OrderID),
        CONSTRAINT CK_Order_Qunatity CHECK (Quantity > 0),
        CONSTRAINT CK_Order_TotalAmount CHECK (TotalAmount > 0)
    );

    SET @Message = 'Completed CREATE TABLE Game.Order.';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
	EXEC Game.InsertHistory @SP = @SP,
		@Status = 'Run',
		@Message = @Message;
END
---------------------------------------------------------------------------------------

Set @ErrorText = 'Failed CREATE Table Game.Retailer.';

IF EXISTS (SELECT * 
    FROM sys.objects
    WHERE object_id = OBJECT_ID(N'Game.Retailer') AND type in (N'U'))
BEGIN 
    SET @Message = 'Table Game.Retailer already exists, Skipping CREATE TABLE...';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
	EXEC Game.InsertHistory @SP = @SP,
		@Status = 'Error',
		@Message = @Message;
END
ELSE
BEGIN
    CREATE TABLE Game.Retailer
    (
        RetailerID  TINYINT         NOT NULL,
		DiscountID	TINYINT			NOT NULL,
        [Name]      VARCHAR(50)     NOT NULL,
        Website     VARCHAR(250)    NOT NULL,
        [Address]   VARCHAR(500)    NULL,
        City        VARCHAR(50)     NULL,
        ZIP         VARCHAR(10)     NULL
        CONSTRAINT PK_Retailer_RetailerID PRIMARY KEY CLUSTERED(RetailerID)
    );

    SET @Message = 'Completed CREATE TABLE Game.Retailer.';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
	EXEC Game.InsertHistory @SP = @SP,
		@Status = 'Run',
		@Message = @Message;
END
---------------------------------------------------------------------------------------

Set @ErrorText = 'Failed CREATE Table Game.Discount.';

IF EXISTS (SELECT * 
    FROM sys.objects
    WHERE object_id = OBJECT_ID(N'Game.Discount') AND type in (N'U'))
BEGIN 
    SET @Message = 'Table Game.Discount already exists, Skipping CREATE TABLE...';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
	EXEC Game.InsertHistory @SP = @SP,
		@Status = 'Error',
		@Message = @Message;
END
ELSE
BEGIN
    CREATE TABLE Game.Discount
    (
        DiscountID  TINYINT     NOT NULL,
        [Name]      VARCHAR(50) NOT NULL,
        Amount      TINYINT     NOT NULL
        CONSTRAINT PK_Discount_DiscountID PRIMARY KEY CLUSTERED(DiscountID)
    );

    SET @Message = 'Completed CREATE TABLE Game.Discount.';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
	EXEC Game.InsertHistory @SP = @SP,
		@Status = 'Run',
		@Message = @Message;
END
---------------------------------------------------------------------------------------

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