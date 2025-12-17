-- Migration script for User Requests, Favorites, Comments, and Services tables
-- Run this script in your SQL Server database

-- IMPORTANT: Replace 'ZoozyApi' with your actual database name if different
USE [ZoozyApi]; 
GO

-- Create UserRequests table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UserRequests]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[UserRequests] (
        [Id] INT IDENTITY(1,1) PRIMARY KEY,
        [UserId] INT NOT NULL,
        [PetName] NVARCHAR(200) NOT NULL,
        [ServiceName] NVARCHAR(100) NOT NULL,
        [UserPhoto] NVARCHAR(MAX) NULL,
        [StartDate] DATETIME2 NOT NULL,
        [EndDate] DATETIME2 NOT NULL,
        [DayDiff] INT NOT NULL,
        [Note] NVARCHAR(1000) NULL,
        [Location] NVARCHAR(500) NULL,
        [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        [UpdatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT [FK_UserRequests_Users] FOREIGN KEY ([UserId]) 
            REFERENCES [dbo].[Users] ([Id]) ON DELETE CASCADE
    );
    
    CREATE INDEX [IX_UserRequests_UserId] ON [dbo].[UserRequests]([UserId]);
END
GO

-- Create UserFavorites table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UserFavorites]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[UserFavorites] (
        [Id] INT IDENTITY(1,1) PRIMARY KEY,
        [UserId] INT NOT NULL,
        [Title] NVARCHAR(200) NOT NULL,
        [Subtitle] NVARCHAR(500) NULL,
        [ImageUrl] NVARCHAR(MAX) NULL,
        [ProfileImageUrl] NVARCHAR(MAX) NULL,
        [Tip] NVARCHAR(50) NOT NULL, -- "explore", "moments", "caregiver"
        [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT [FK_UserFavorites_Users] FOREIGN KEY ([UserId]) 
            REFERENCES [dbo].[Users] ([Id]) ON DELETE CASCADE
    );
    
    CREATE INDEX [IX_UserFavorites_UserId] ON [dbo].[UserFavorites]([UserId]);
    CREATE INDEX [IX_UserFavorites_Tip] ON [dbo].[UserFavorites]([Tip]);
END
GO

-- Create UserComments table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UserComments]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[UserComments] (
        [Id] INT IDENTITY(1,1) PRIMARY KEY,
        [UserId] INT NOT NULL,
        [CardId] NVARCHAR(200) NOT NULL, -- "moment_xxx" or "caregiver_xxx"
        [Message] NVARCHAR(MAX) NOT NULL,
        [Rating] INT NOT NULL DEFAULT 5 CHECK ([Rating] >= 1 AND [Rating] <= 5),
        [AuthorName] NVARCHAR(200) NOT NULL,
        [AuthorAvatar] NVARCHAR(MAX) NULL,
        [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT [FK_UserComments_Users] FOREIGN KEY ([UserId]) 
            REFERENCES [dbo].[Users] ([Id]) ON DELETE CASCADE
    );
    
    CREATE INDEX [IX_UserComments_UserId] ON [dbo].[UserComments]([UserId]);
    CREATE INDEX [IX_UserComments_CardId] ON [dbo].[UserComments]([CardId]);
END
GO

-- Create UserServices table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UserServices]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[UserServices] (
        [Id] INT IDENTITY(1,1) PRIMARY KEY,
        [UserId] INT NOT NULL,
        [ServiceName] NVARCHAR(200) NOT NULL,
        [ServiceIcon] NVARCHAR(100) NULL,
        [Price] NVARCHAR(50) NULL,
        [Description] NVARCHAR(MAX) NULL,
        [Address] NVARCHAR(500) NOT NULL,
        [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        [UpdatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT [FK_UserServices_Users] FOREIGN KEY ([UserId]) 
            REFERENCES [dbo].[Users] ([Id]) ON DELETE CASCADE
    );
    
    CREATE INDEX [IX_UserServices_UserId] ON [dbo].[UserServices]([UserId]);
END
GO

PRINT 'All tables created successfully!';
GO

