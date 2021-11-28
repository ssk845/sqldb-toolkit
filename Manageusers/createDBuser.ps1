$ServerName = Read-Host "Input servername" 
$Newlogin = Read-Host "Input username" 
$SecurePassword = Read-Host "Input password" -AsSecureString
$RoleName = Read-Host "Input rolename (e.g. db_datareader, db_datawriter, db_owner)"
$Database = Read-Host "Input databasename"
New-DbaLogin -SqlInstance $ServerName -SqlCredential $SqlCredential -Login $Newlogin -SecurePassword $SecurePassword 
New-DbaDbUser -SqlInstance $ServerName -SqlCredential $SqlCredential -Database $Database -Login $Newlogin
Add-DbaDbRoleMember -SqlInstance $ServerName -SqlCredential $SqlCredential -Role $RoleName -User $Newlogin -Database $Database