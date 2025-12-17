-- Tabloları Doğrulama Sorgusu
-- Bu sorguyu çalıştırarak tabloların düzgün oluşturulduğunu kontrol edebilirsiniz

USE [ZoozyApi];
GO

-- 1. Tablo sayısını kontrol et
PRINT '=== TABLO KONTROLÜ ===';
SELECT 
    TABLE_NAME as [Tablo Adı],
    CASE 
        WHEN TABLE_NAME = 'UserRequests' THEN '✅ Kullanıcı Talepleri'
        WHEN TABLE_NAME = 'UserFavorites' THEN '✅ Kullanıcı Favorileri'
        WHEN TABLE_NAME = 'UserComments' THEN '✅ Kullanıcı Yorumları'
        WHEN TABLE_NAME = 'UserServices' THEN '✅ Kullanıcı Hizmetleri'
    END as [Açıklama]
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = 'BASE TABLE'
    AND TABLE_NAME IN ('UserRequests', 'UserFavorites', 'UserComments', 'UserServices')
ORDER BY TABLE_NAME;
GO

-- 2. Foreign Key ilişkilerini kontrol et
PRINT '';
PRINT '=== FOREIGN KEY İLİŞKİLERİ ===';
SELECT 
    fk.name AS [Foreign Key Adı],
    tp.name AS [Tablo],
    cp.name AS [Sütun],
    rt.name AS [Referans Tablo],
    cr.name AS [Referans Sütun]
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
INNER JOIN sys.tables tp ON fkc.parent_object_id = tp.object_id
INNER JOIN sys.columns cp ON fkc.parent_object_id = cp.object_id AND fkc.parent_column_id = cp.column_id
INNER JOIN sys.tables rt ON fkc.referenced_object_id = rt.object_id
INNER JOIN sys.columns cr ON fkc.referenced_object_id = cr.object_id AND fkc.referenced_column_id = cr.column_id
WHERE tp.name IN ('UserRequests', 'UserFavorites', 'UserComments', 'UserServices')
ORDER BY tp.name, fk.name;
GO

-- 3. Index'leri kontrol et
PRINT '';
PRINT '=== İNDEX KONTROLÜ ===';
SELECT 
    t.name AS [Tablo],
    i.name AS [Index Adı],
    i.type_desc AS [Index Tipi]
FROM sys.indexes i
INNER JOIN sys.tables t ON i.object_id = t.object_id
WHERE t.name IN ('UserRequests', 'UserFavorites', 'UserComments', 'UserServices')
    AND i.name IS NOT NULL
    AND i.name LIKE 'IX_%'
ORDER BY t.name, i.name;
GO

-- 4. Tablo kayıt sayılarını kontrol et (başlangıçta 0 olmalı)
PRINT '';
PRINT '=== KAYIT SAYILARI ===';
SELECT 
    'UserRequests' as [Tablo], COUNT(*) as [Kayıt Sayısı] FROM UserRequests
UNION ALL
SELECT 'UserFavorites', COUNT(*) FROM UserFavorites
UNION ALL
SELECT 'UserComments', COUNT(*) FROM UserComments
UNION ALL
SELECT 'UserServices', COUNT(*) FROM UserServices;
GO

PRINT '';
PRINT '✅ Tüm kontroller tamamlandı!';

