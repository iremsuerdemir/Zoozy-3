-- =============================================
-- UserPhoto MaxLength Hatası Düzeltme
-- SSMS'te bu script'i çalıştırın
-- =============================================

USE [ZoozyApi];  -- Veritabanı adınızı buraya yazın
GO

-- UserPhoto kolonunu NVARCHAR(MAX) yap
ALTER TABLE [UserRequests]
ALTER COLUMN [UserPhoto] NVARCHAR(MAX) NULL;
GO

PRINT '✅ UserPhoto kolonu NVARCHAR(MAX) olarak güncellendi.';
GO

-- Kontrol: Kolon tipini kontrol et
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'UserRequests' 
AND COLUMN_NAME = 'UserPhoto';
GO

