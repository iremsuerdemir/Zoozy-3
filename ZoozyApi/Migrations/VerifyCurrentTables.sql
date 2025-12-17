-- SSMS'te Tabloların Güncel Olup Olmadığını Kontrol Etme
-- Bu sorguyu SSMS'te çalıştırarak tabloların güncel yapısını kontrol edebilirsiniz

USE [ZoozyApi]; -- Database adınızı buraya yazın
GO

-- ============================================
-- 1. Users Tablosu Kontrolü
-- ============================================
PRINT '=== Users Tablosu Kontrolü ===';
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Users')
BEGIN
    PRINT '✅ Users tablosu mevcut';
    
    -- PhotoUrl kolonu var mı?
    IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'Users' AND COLUMN_NAME = 'PhotoUrl')
    BEGIN
        PRINT '✅ PhotoUrl kolonu mevcut';
    END
    ELSE
    BEGIN
        PRINT '❌ PhotoUrl kolonu EKSİK! Aşağıdaki SQL ile ekleyin:';
        PRINT 'ALTER TABLE Users ADD PhotoUrl NVARCHAR(1000) NULL;';
    END
    
    -- Users tablosu kolonlarını göster
    SELECT 
        COLUMN_NAME as [Kolon],
        DATA_TYPE as [Tip],
        IS_NULLABLE as [Null Olabilir],
        CHARACTER_MAXIMUM_LENGTH as [Max Uzunluk]
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'Users'
    ORDER BY ORDINAL_POSITION;
END
ELSE
BEGIN
    PRINT '❌ Users tablosu YOK!';
END
GO

-- ============================================
-- 2. UserComments Tablosu Kontrolü
-- ============================================
PRINT '';
PRINT '=== UserComments Tablosu Kontrolü ===';
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'UserComments')
BEGIN
    PRINT '✅ UserComments tablosu mevcut';
    
    -- AuthorAvatar kolonu var mı?
    IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'UserComments' AND COLUMN_NAME = 'AuthorAvatar')
    BEGIN
        PRINT '✅ AuthorAvatar kolonu mevcut';
    END
    ELSE
    BEGIN
        PRINT '❌ AuthorAvatar kolonu EKSİK! Aşağıdaki SQL ile ekleyin:';
        PRINT 'ALTER TABLE UserComments ADD AuthorAvatar NVARCHAR(1000) NULL;';
    END
    
    -- UserComments tablosu kolonlarını göster
    SELECT 
        COLUMN_NAME as [Kolon],
        DATA_TYPE as [Tip],
        IS_NULLABLE as [Null Olabilir],
        CHARACTER_MAXIMUM_LENGTH as [Max Uzunluk]
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'UserComments'
    ORDER BY ORDINAL_POSITION;
END
ELSE
BEGIN
    PRINT '❌ UserComments tablosu YOK!';
END
GO

-- ============================================
-- 3. Tüm Gerekli Tablolar Kontrolü
-- ============================================
PRINT '';
PRINT '=== Tüm Tablolar Kontrolü ===';
SELECT 
    TABLE_NAME as [Tablo Adı],
    CASE 
        WHEN TABLE_NAME = 'Users' THEN '✅ Kullanıcılar (PhotoUrl gerekli)'
        WHEN TABLE_NAME = 'UserComments' THEN '✅ Yorumlar (AuthorAvatar gerekli)'
        WHEN TABLE_NAME = 'UserFavorites' THEN '✅ Favoriler'
        WHEN TABLE_NAME = 'UserRequests' THEN '✅ Talepler'
        WHEN TABLE_NAME = 'UserServices' THEN '✅ Hizmetler'
        ELSE '❓ Diğer'
    END as [Açıklama]
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = 'BASE TABLE'
    AND TABLE_NAME IN ('Users', 'UserComments', 'UserFavorites', 'UserRequests', 'UserServices')
ORDER BY TABLE_NAME;
GO

-- ============================================
-- 4. Eksik Kolonları Düzeltme (Gerekirse)
-- ============================================
PRINT '';
PRINT '=== Eksik Kolonları Düzeltme ===';
PRINT 'Eğer yukarıda eksik kolonlar varsa, aşağıdaki SQL komutlarını çalıştırın:';
PRINT '';
PRINT '-- Users tablosuna PhotoUrl ekle (eğer yoksa)';
PRINT 'IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = ''Users'' AND COLUMN_NAME = ''PhotoUrl'')';
PRINT 'BEGIN';
PRINT '    ALTER TABLE Users ADD PhotoUrl NVARCHAR(1000) NULL;';
PRINT '    PRINT ''PhotoUrl kolonu eklendi'';';
PRINT 'END';
PRINT '';
PRINT '-- UserComments tablosuna AuthorAvatar ekle (eğer yoksa)';
PRINT 'IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = ''UserComments'' AND COLUMN_NAME = ''AuthorAvatar'')';
PRINT 'BEGIN';
PRINT '    ALTER TABLE UserComments ADD AuthorAvatar NVARCHAR(1000) NULL;';
PRINT '    PRINT ''AuthorAvatar kolonu eklendi'';';
PRINT 'END';
GO

