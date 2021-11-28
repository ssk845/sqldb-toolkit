$ServerName = Read-Host "Input servername" 
$Database = Read-Host "Input databasename"
Get-DbaLastBackup -SqlInstance $ServerName -SqlCredential $SqlCredential  -Database $Database | Select-Object * | Out-Gridview