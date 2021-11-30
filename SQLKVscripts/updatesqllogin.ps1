# Connect to Azure
Connect-AzAccount
# Get input
$serverName = Read-Host "Input servername" 
$sqllogin = Read-Host "Input SQL login" 
# Get sql login from keyvault
$vault = 'toolscreds'
$sqladmin = 'sqlprb'
$secretdetail = Get-AzKeyVaultSecret -VaultName $vault -Name $sqladmin
$sqlcredential = New-Object System.Management.Automation.PSCredential ($secretdetail.Name, $secretdetail.SecretValue)
# Generate random password - change the rules according to the policy 
# Generate password ~ length = 50 
Add-Type -Assembly System.Web 
$password = [System.Web.Security.Membership]::GeneratePassword(50, 1) 
# Remove unwanted characters 
$pattern = '[^a-zA-Z0-9#$!]' 
# Trim password ~ length = 16 
$password = ($password -replace $pattern, '').Substring(1, 16)
# Update secert with the new password
Write-Host "`nUpdating password for login - $key1" 
$secret1 = $password
$value = ConvertTo-SecureString -String $secret1 -AsPlainText -Force 
Set-AzKeyVaultSecret -VaultName $vault -Name $key1 -SecretValue $value 
#convert password to an encrypted string and define variables
$key1 = $sqllogin
$securepassword = ConvertTo-SecureString  $password -asplaintext -force
Set-DbaLogin -SqlInstance $serverName -SqlCredential $sqlcredential -Login $sqllogin -SecurePassword $securepassword -Confirm:$false