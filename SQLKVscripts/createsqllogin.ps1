# Connect to Azure and suppress the output
Connect-AzAccount | Out-Null
# Get input
$serverName = Read-Host "Input servername" 
$sqllogin = Read-Host "Input SQL login" 
$database = Read-Host "Input database name"
$rolename = Read-Host "Input role name (e.g. db_datareader, db_datawriter, db_owner)"
# Get sql login from keyvault
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
# define variables
$key1 = $sqllogin
$vault = 'toolscreds'
$secret1 = $password
# Check if key exists
$present = Get-AzKeyVaultSecret -VaultName $vault -Name $key1 -ErrorAction SilentlyContinue
# Create if key does not exists
if (! $present.id) 
{ 
    Write-Host "`nCreating new SQL Login - $key1" 
    $value = ConvertTo-SecureString -String $secret1 -AsPlainText -Force 
    Set-AzKeyVaultSecret -VaultName $vault -Name $key1 -SecretValue $value 
} 
else 
{ 
    Write-Host "`nSQL Login exists - $key1" 
    Get-AzKeyVaultSecret -VaultName $vault -Name $key1 
}
#convert password to an encrypted string
$securepassword = ConvertTo-SecureString  $password -asplaintext -force
# create login from keyvault on sql instance
New-DbaLogin -SqlInstance $serverName -SqlCredential $sqlcredential -Login $sqllogin -SecurePassword $securepassword -Confirm:$false
# assign database to the login
New-DbaDbUser -SqlInstance $serverName -SqlCredential $sqlcredential -Database $database -Login $sqllogin -Confirm:$false
# give database permission
Add-DbaDbRoleMember -SqlInstance $serverName -SqlCredential $sqlcredential -Role $rolename -User $sqllogin -Database $database -Confirm:$false