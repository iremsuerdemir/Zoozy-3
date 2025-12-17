-- UserComments tablosundaki AuthorAvatar kolonunu NVARCHAR(MAX) olarak güncelle
-- Base64 string'ler çok uzun olabilir, bu yüzden MaxLength kaldırıldı

USE [ZoozyApi]; -- Database adınızı buraya yazın
GO

-- AuthorAvatar kolonunu NVARCHAR(MAX) olarak güncelle
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
           WHERE TABLE_NAME = 'UserComments' AND COLUMN_NAME = 'AuthorAvatar')
BEGIN
    ALTER TABLE [dbo].[UserComments]
    ALTER COLUMN [AuthorAvatar] NVARCHAR(MAX) NULL;
    
    PRINT '✅ AuthorAvatar kolonu NVARCHAR(MAX) olarak güncellendi';
END
ELSE
BEGIN
    PRINT '❌ AuthorAvatar kolonu bulunamadı!';
END
GO

