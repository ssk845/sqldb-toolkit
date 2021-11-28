$ServerName = Read-Host "Input servername" 
$Database = Read-Host "Input databasename"
$BackupLocation = Read-Host "Input backupfile blob location"
$FileName = Read-Host "Input filename (e.g. database_name_date.bak)"
Backup-DbaDatabase -SqlInstance $ServerName -SqlCredential $SqlCredential -Database $Database -AzureBaseUrl $BackupLocation -FilePath $FileName -Type Full