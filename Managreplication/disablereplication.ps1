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
Stop-DbaAgentJob -SqlInstance $SqlInstance -SqlCredential $sqlcredential -Job $SqlInstance-AdventureWorksLT2019-$PublisherName-1
Stop-DbaAgentJob -SqlInstance $SqlInstance -SqlCredential $sqlcredential -Job $SqlInstance-AdventureWorksLT2019-$PublisherName-$SqlInstance-3 
Stop-DbaAgentJob -SqlInstance $SqlInstance -SqlCredential $sqlcredential -Job $SqlInstance-AdventureWorksLT2019-1
Set-DbaAgentJob -SqlInstance $SqlInstance -SqlCredential $sqlcredential -Job $SqlInstance-AdventureWorksLT2019-1 -Disabled
Set-DbaAgentJob -SqlInstance $SqlInstance -SqlCredential $sqlcredential -Job $SqlInstance-AdventureWorksLT2019-$PublisherName-$SqlInstance-3 -Disabled
Set-DbaAgentJob -SqlInstance $SqlInstance -SqlCredential $sqlcredential -Job $SqlInstance-AdventureWorksLT2019-$PublisherName-1 -Disabled