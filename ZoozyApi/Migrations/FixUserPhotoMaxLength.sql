-- UserPhoto kolonunu NVARCHAR(MAX) yap
-- Base64 encoded resimler çok uzun olabilir (5000 karakterden fazla)

ALTER TABLE [UserRequests]
ALTER COLUMN [UserPhoto] NVARCHAR(MAX) NULL;

PRINT 'UserPhoto kolonu NVARCHAR(MAX) olarak güncellendi.';

