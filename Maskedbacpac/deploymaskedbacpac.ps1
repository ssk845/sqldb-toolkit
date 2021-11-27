# Get input values
$SQLInstance = Read-Host "Input SQL Instance" 
$SDatabase = Read-Host "Input Source Database Name" 
$TDatabase = Read-Host "Input Target Database Name" 
$Path = Read-Host "Input Path to Get Extract"
# Get sql login from keyvault
$sqladmin = 'sqlprb'
$secretdetail = Get-AzKeyVaultSecret -VaultName $vault -Name $sqladmin
$sqlcredential = New-Object System.Management.Automation.PSCredential ($secretdetail.Name, $secretdetail.SecretValue)
Publish-DbaDacPackage -SqlInstance $SQLInstance  -SqlCredential $sqlcredential -Database $TDatabase -Path $Path'\'$SDatabase'.bacpac' -confirm:$false