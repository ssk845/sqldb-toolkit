$ServerName = Read-Host "Input servername" 
$Login = Read-Host "Input username" 
Remove-DbaDbUser -SqlInstance $ServerName -SqlCredential $SqlCredential -User $Login
Remove-DbaLogin -SqlInstance $ServerName -SqlCredential $SqlCredential -Login $Login