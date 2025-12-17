-- Tabloları Kontrol Etme Sorgusu
-- SSMS'te bu sorguyu çalıştırarak tabloların oluşturulup oluşturulmadığını kontrol edebilirsiniz

USE [ZoozyApi]; -- Database adınızı buraya yazın
GO

-- Tüm tabloları listele
SELECT 
    TABLE_NAME as [Tablo Adı],
    CASE 
        WHEN TABLE_NAME = 'UserRequests' THEN '✅ Kullanıcı Talepleri'
        WHEN TABLE_NAME = 'UserFavorites' THEN '✅ Kullanıcı Favorileri'
        WHEN TABLE_NAME = 'UserComments' THEN '✅ Kullanıcı Yorumları'
        WHEN TABLE_NAME = 'UserServices' THEN '✅ Kullanıcı Hizmetleri'
        ELSE '❓ Diğer'
    END as [Açıklama]
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = 'BASE TABLE'
    AND TABLE_NAME IN ('UserRequests', 'UserFavorites', 'UserComments', 'UserServices')
ORDER BY TABLE_NAME;
GO

-- Eğer sonuç boşsa, tablolar oluşturulmamış demektir
-- Eğer 4 satır varsa, tüm tablolar oluşturulmuş demektir

-- Tablo sütunlarını da kontrol etmek isterseniz:
/*
SELECT 
    TABLE_NAME as [Tablo],
    COLUMN_NAME as [Sütun],
    DATA_TYPE as [Veri Tipi],
    IS_NULLABLE as [Null Olabilir]
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN ('UserRequests', 'UserFavorites', 'UserComments', 'UserServices')
ORDER BY TABLE_NAME, ORDINAL_POSITION;
*/

