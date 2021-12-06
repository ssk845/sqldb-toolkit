Connect-AzAccount | Out-null
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
Invoke-DbaQuery -SqlInstance $SqlInstance -SqlCredential $sqltde -Database $Database -Query "CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_256 
ENCRYPTION BY SERVER ASYMMETRIC KEY SQLEKMKey
GO
ALTER DATABASE $Database SET ENCRYPTION ON
GO"