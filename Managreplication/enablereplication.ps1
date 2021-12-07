# Connect to Azure and suppress the output
Connect-AzAccount | Out-Null
# Get input
$SqlInstance = Read-Host "Input SQL Instance" 
$PublisherName = 'TestPub'
# Get sql login from keyvault
$vault = 'toolscreds'
$sqladmin = 'sqladmin'
$secretdetail = Get-AzKeyVaultSecret -VaultName $vault -Name $sqladmin
$sqlcredential = New-Object System.Management.Automation.PSCredential ($secretdetail.Name, $secretdetail.SecretValue)
#Stop and disable replication related 
Set-DbaAgentJob -SqlInstance $SqlInstance -SqlCredential $sqlcredential -Job $SqlInstance-AdventureWorksLT2019-1 -Enabled
Set-DbaAgentJob -SqlInstance $SqlInstance -SqlCredential $sqlcredential -Job $SqlInstance-AdventureWorksLT2019-$PublisherName-$SqlInstance-3 -Enabled
Set-DbaAgentJob -SqlInstance $SqlInstance -SqlCredential $sqlcredential -Job $SqlInstance-AdventureWorksLT2019-$PublisherName-1 -Enabled
# start Sanpshot SQL Job 
Start-DbaAgentJob -SqlInstance $SqlInstance -SqlCredential $sqlcredential -Job $SqlInstance-AdventureWorksLT2019-$PublisherName-1