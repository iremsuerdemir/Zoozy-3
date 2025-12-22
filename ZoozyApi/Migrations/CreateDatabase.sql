-- =============================================
-- Zoozy Database - Complete Schema
-- Tüm tabloları oluşturan SQL script
-- =============================================

-- Users tablosu
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Users')
BEGIN
    CREATE TABLE [Users] (
        [Id] INT PRIMARY KEY IDENTITY(1,1),
        [FirebaseUid] NVARCHAR(200) NULL,
        [Email] NVARCHAR(200) NOT NULL,
        [PasswordHash] NVARCHAR(MAX) NULL,
        [DisplayName] NVARCHAR(200) NOT NULL,
        [PhotoUrl] NVARCHAR(500) NULL,
        [Provider] NVARCHAR(50) NOT NULL DEFAULT 'local',
        [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        [UpdatedAt] DATETIME2 NULL,
        [IsActive] BIT NOT NULL DEFAULT 1,
        [PasswordResetToken] NVARCHAR(MAX) NULL,
        [PasswordResetTokenExpiry] DATETIME2 NULL
    );

    CREATE UNIQUE INDEX [IX_Users_Email] ON [Users]([Email]);
    CREATE UNIQUE INDEX [IX_Users_FirebaseUid] ON [Users]([FirebaseUid]) WHERE [FirebaseUid] IS NOT NULL;
END
GO

-- PetProfiles tablosu
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PetProfiles')
BEGIN
    CREATE TABLE [PetProfiles] (
        [Id] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        [FirebaseId] NVARCHAR(200) NOT NULL,
        [Name] NVARCHAR(200) NOT NULL,
        [Species] NVARCHAR(100) NULL,
        [Breed] NVARCHAR(100) NULL,
        [Age] INT NULL,
        [Weight] DECIMAL(5,2) NULL,
        [PhotoUrl] NVARCHAR(500) NULL,
        [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        [UpdatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE()
    );

    CREATE UNIQUE INDEX [IX_PetProfiles_FirebaseId] ON [PetProfiles]([FirebaseId]);
END
GO

-- ServiceProviders tablosu
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ServiceProviders')
BEGIN
    CREATE TABLE [ServiceProviders] (
        [Id] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        [FirebaseId] NVARCHAR(200) NOT NULL,
        [Name] NVARCHAR(200) NOT NULL,
        [ServiceType] NVARCHAR(100) NULL,
        [Rating] DECIMAL(3,2) NULL,
        [PhotoUrl] NVARCHAR(500) NULL,
        [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        [UpdatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE()
    );

    CREATE UNIQUE INDEX [IX_ServiceProviders_FirebaseId] ON [ServiceProviders]([FirebaseId]);
END
GO

-- ServiceRequests tablosu
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ServiceRequests')
BEGIN
    CREATE TABLE [ServiceRequests] (
        [Id] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        [FirebaseId] NVARCHAR(200) NOT NULL,
        [PetProfileId] UNIQUEIDENTIFIER NOT NULL,
        [ServiceProviderId] UNIQUEIDENTIFIER NOT NULL,
        [Status] NVARCHAR(50) NULL,
        [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        [UpdatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        
        CONSTRAINT [FK_ServiceRequests_PetProfiles] FOREIGN KEY ([PetProfileId]) REFERENCES [PetProfiles]([Id]),
        CONSTRAINT [FK_ServiceRequests_ServiceProviders] FOREIGN KEY ([ServiceProviderId]) REFERENCES [ServiceProviders]([Id])
    );

    CREATE UNIQUE INDEX [IX_ServiceRequests_FirebaseId] ON [ServiceRequests]([FirebaseId]);
END
GO

-- UserRequests tablosu
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'UserRequests')
BEGIN
    CREATE TABLE [UserRequests] (
        [Id] INT PRIMARY KEY IDENTITY(1,1),
        [UserId] INT NOT NULL,
        [PetName] NVARCHAR(200) NOT NULL,
        [ServiceName] NVARCHAR(100) NOT NULL,
        [UserPhoto] NVARCHAR(5000) NULL,
        [StartDate] DATETIME2 NOT NULL,
        [EndDate] DATETIME2 NOT NULL,
        [DayDiff] INT NOT NULL DEFAULT 0,
        [Note] NVARCHAR(1000) NULL,
        [Location] NVARCHAR(500) NULL,
        [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        [UpdatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        
        CONSTRAINT [FK_UserRequests_Users] FOREIGN KEY ([UserId]) REFERENCES [Users]([Id]) ON DELETE CASCADE
    );
END
GO

-- UserFavorites tablosu
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'UserFavorites')
BEGIN
    CREATE TABLE [UserFavorites] (
        [Id] INT PRIMARY KEY IDENTITY(1,1),
        [UserId] INT NOT NULL,
        [Title] NVARCHAR(200) NOT NULL,
        [Tip] NVARCHAR(50) NOT NULL,
        [Identifier] NVARCHAR(500) NULL,
        [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        
        CONSTRAINT [FK_UserFavorites_Users] FOREIGN KEY ([UserId]) REFERENCES [Users]([Id]) ON DELETE CASCADE
    );
END
GO

-- UserComments tablosu
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'UserComments')
BEGIN
    CREATE TABLE [UserComments] (
        [Id] INT PRIMARY KEY IDENTITY(1,1),
        [UserId] INT NOT NULL,
        [CardId] NVARCHAR(200) NOT NULL,
        [CommentText] NVARCHAR(1000) NOT NULL,
        [AuthorName] NVARCHAR(200) NULL,
        [AuthorAvatar] NVARCHAR(MAX) NULL,
        [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        
        CONSTRAINT [FK_UserComments_Users] FOREIGN KEY ([UserId]) REFERENCES [Users]([Id]) ON DELETE CASCADE
    );
END
GO

-- UserServices tablosu
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'UserServices')
BEGIN
    CREATE TABLE [UserServices] (
        [Id] INT PRIMARY KEY IDENTITY(1,1),
        [UserId] INT NOT NULL,
        [ServiceName] NVARCHAR(200) NOT NULL,
        [ServiceIcon] NVARCHAR(100) NULL,
        [Price] DECIMAL(10,2) NULL,
        [Description] NVARCHAR(1000) NULL,
        [Address] NVARCHAR(500) NULL,
        [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        [UpdatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        
        CONSTRAINT [FK_UserServices_Users] FOREIGN KEY ([UserId]) REFERENCES [Users]([Id]) ON DELETE CASCADE
    );
END
GO

-- Messages tablosu (YENİ)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Messages')
BEGIN
    CREATE TABLE [Messages] (
        [Id] INT PRIMARY KEY IDENTITY(1,1),
        [SenderId] INT NOT NULL,
        [ReceiverId] INT NOT NULL,
        [JobId] INT NOT NULL,
        [MessageText] NVARCHAR(2000) NOT NULL,
        [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        
        CONSTRAINT [FK_Messages_Users_Sender] FOREIGN KEY ([SenderId]) REFERENCES [Users]([Id]),
        CONSTRAINT [FK_Messages_Users_Receiver] FOREIGN KEY ([ReceiverId]) REFERENCES [Users]([Id]),
        CONSTRAINT [FK_Messages_UserRequests_Job] FOREIGN KEY ([JobId]) REFERENCES [UserRequests]([Id])
    );

    CREATE INDEX [IX_Messages_SenderId] ON [Messages]([SenderId]);
    CREATE INDEX [IX_Messages_ReceiverId] ON [Messages]([ReceiverId]);
    CREATE INDEX [IX_Messages_JobId] ON [Messages]([JobId]);
    CREATE INDEX [IX_Messages_CreatedAt] ON [Messages]([CreatedAt]);
END
GO

-- Notifications tablosu (YENİ)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Notifications')
BEGIN
    CREATE TABLE [Notifications] (
        [Id] INT PRIMARY KEY IDENTITY(1,1),
        [UserId] INT NOT NULL,
        [Type] NVARCHAR(50) NOT NULL,
        [Title] NVARCHAR(200) NOT NULL,
        [RelatedUserId] INT NULL,
        [RelatedJobId] INT NULL,
        [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        [IsRead] BIT NOT NULL DEFAULT 0,
        
        CONSTRAINT [FK_Notifications_Users_User] FOREIGN KEY ([UserId]) REFERENCES [Users]([Id]) ON DELETE CASCADE,
        CONSTRAINT [FK_Notifications_Users_RelatedUser] FOREIGN KEY ([RelatedUserId]) REFERENCES [Users]([Id]),
        CONSTRAINT [FK_Notifications_UserRequests_RelatedJob] FOREIGN KEY ([RelatedJobId]) REFERENCES [UserRequests]([Id])
    );

    CREATE INDEX [IX_Notifications_UserId] ON [Notifications]([UserId]);
    CREATE INDEX [IX_Notifications_Type] ON [Notifications]([Type]);
    CREATE INDEX [IX_Notifications_CreatedAt] ON [Notifications]([CreatedAt]);
    CREATE INDEX [IX_Notifications_IsRead] ON [Notifications]([IsRead]);
END
GO

-- FirebaseSyncLogs tablosu
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'FirebaseSyncLogs')
BEGIN
    CREATE TABLE [FirebaseSyncLogs] (
        [Id] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        [PayloadSource] NVARCHAR(128) NOT NULL,
        [PetsProcessed] INT NOT NULL DEFAULT 0,
        [ProvidersProcessed] INT NOT NULL DEFAULT 0,
        [RequestsProcessed] INT NOT NULL DEFAULT 0,
        [Notes] NVARCHAR(MAX) NULL,
        [SyncedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE()
    );

    CREATE UNIQUE INDEX [IX_FirebaseSyncLogs_PayloadSource] ON [FirebaseSyncLogs]([PayloadSource]);
END
GO

PRINT 'Database schema oluşturuldu!';
PRINT 'Tüm tablolar hazır.';

