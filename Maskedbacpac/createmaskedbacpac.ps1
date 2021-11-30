# Connect to Azure
Connect-AzAccount
# Get input values
$SQLInstance = Read-Host "Input SQL Instance" 
$Database = Read-Host "Input Database Name" 
$Path = Read-Host "Input Path to Extract"
# Get sql login from keyvault
$sqladmin = 'sqlprb'
$secretdetail = Get-AzKeyVaultSecret -VaultName $vault -Name $sqladmin
$sqlcredential = New-Object System.Management.Automation.PSCredential ($secretdetail.Name, $secretdetail.SecretValue)
# Generate masking rules database
New-DbaDbMaskingConfig -SqlInstance $SQLInstance -SqlCredential $sqlcredential -Database $Database -Path $Path
# Apply masking rules to the database 
$RSqlInstance = $SQLInstance.replace("\","$")
Invoke-DbaDbDataMasking -SqlInstance $SQLInstance -SqlCredential $sqlcredential -Database $Database -FilePath $Path'\'$RSqlInstance'.'$Database'.DataMaskingConfig.json' -Confirm:$false
# Generate a Bacpac file
Export-DbaDacPackage -SqlInstance $SQLInstance -SqlCredential $sqlcredential -Database $Database -type Bacpac  -FilePath $Path'\'$Database'.bacpac'