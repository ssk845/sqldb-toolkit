# Connect to Azure and suppress the output
Connect-AzAccount | Out-Null
# Get input
$SQLInstance = Read-Host "Input SQL Instance" 
$Database = Read-Host "Input Database Name"
# define variables
# key details from key vault
$vault = 'sqlkeyvault-sk'
$secretname1 = 'EKMKeyVault'
$secretdetail1 = Get-AzKeyVaultSecret -VaultName $vault -Name 'EKMKeyVault' -AsPlainText
# sql account to configure key vault
$secretname2 = 'sqlakv'
$secretdetail2 = Get-AzKeyVaultSecret -VaultName $vault -Name $secretname2
$sqladmin = New-Object System.Management.Automation.PSCredential ($secretdetail2.Name, $secretdetail2.SecretValue)
# sql account for sqltde (this is an admin/DBA account) 
$secretname3 = 'sqltde'
$secretdetail3 = Get-AzKeyVaultSecret -VaultName $vault -Name $secretname3
$sqltde = New-Object System.Management.Automation.PSCredential ($secretdetail3.Name, $secretdetail3.SecretValue)
# check replication status
Invoke-DbaQuery -SqlInstance $SqlInstance -SqlCredential $sqladmin -Query "Use master
GO
SELECT DB_NAME(database_id) AS DatabaseName, encryption_state,
encryption_state_desc =
CASE encryption_state
         WHEN '0'  THEN  'No database encryption key present, no encryption'
         WHEN '1'  THEN  'Unencrypted'
         WHEN '2'  THEN  'Encryption in progress'
         WHEN '3'  THEN  'Encrypted'
         WHEN '4'  THEN  'Key change in progress'
         WHEN '5'  THEN  'Decryption in progress'
         WHEN '6'  THEN  'Protection change in progress (The certificate or asymmetric key that is encrypting the database encryption key is being changed.)'
         ELSE 'No Status'
         END,
percent_complete,encryptor_thumbprint, encryptor_type  FROM sys.dm_database_encryption_keys
GO"
# enable configuration to support TDE
Invoke-DbaQuery -SqlInstance $SqlInstance -SqlCredential $sqladmin -Query "USE master
GO
sp_configure 'show advanced options', 1
GO
RECONFIGURE
GO
sp_configure 'EKM provider enabled', 1
GO
RECONFIGURE
GO
CREATE CRYPTOGRAPHIC PROVIDER AzureKeyVault_EKM_Prov
FROM FILE = 'C:\Program Files\SQL Server Connector for Microsoft Azure Key Vault\Microsoft.AzureKeyVaultService.EKM.dll'
GO"
# Configure Credential and get secert from the vault
Invoke-DbaQuery -SqlInstance $SqlInstance -SqlCredential $sqladmin -Query "USE master
GO
CREATE CREDENTIAL EKMKeyVault
WITH IDENTITY = N'$vault',
SECRET = N'$secretdetail1'
FOR CRYPTOGRAPHIC PROVIDER AzureKeyVault_EKM_Prov
GO
ALTER LOGIN $secretname3
ADD CREDENTIAL $secretname1
GO"
# configure key, open the key and update the login to TDE_Login
Invoke-DbaQuery -SqlInstance $SqlInstance -SqlCredential $sqltde -Query "USE master
GO
CREATE ASYMMETRIC KEY SQLEKMKey
FROM PROVIDER AzureKeyVault_EKM_Prov
WITH PROVIDER_KEY_NAME = N'SQLEKMKeyVault',
CREATION_DISPOSITION = OPEN_EXISTING
GO
CREATE LOGIN TDE_Login
FROM ASYMMETRIC KEY SQLEKMKey
GO
ALTER LOGIN $secretname3
DROP CREDENTIAL $secretname1
GO
ALTER LOGIN TDE_Login
ADD CREDENTIAL $secretname1
GO"
# enable database encryption
Invoke-DbaQuery -SqlInstance $SqlInstance -SqlCredential $sqltde -Database $Database -Query "CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_256 
ENCRYPTION BY SERVER ASYMMETRIC KEY SQLEKMKey
GO
ALTER DATABASE $Database SET ENCRYPTION ON
GO"
# check on TDE status
Invoke-DbaQuery -SqlInstance $SqlInstance -SqlCredential $sqladmin -Query "Use master
GO
SELECT DB_NAME(database_id) AS DatabaseName, encryption_state,
encryption_state_desc =
CASE encryption_state
         WHEN '0'  THEN  'No database encryption key present, no encryption'
         WHEN '1'  THEN  'Unencrypted'
         WHEN '2'  THEN  'Encryption in progress'
         WHEN '3'  THEN  'Encrypted'
         WHEN '4'  THEN  'Key change in progress'
         WHEN '5'  THEN  'Decryption in progress'
         WHEN '6'  THEN  'Protection change in progress (The certificate or asymmetric key that is encrypting the database encryption key is being changed.)'
         ELSE 'No Status'
         END,
percent_complete,encryptor_thumbprint, encryptor_type  FROM sys.dm_database_encryption_keys
GO"