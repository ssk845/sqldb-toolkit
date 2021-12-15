# Connect to Azure and suppress the output
Connect-AzAccount | Out-Null
# Get input values
$SQLInstance = Read-Host "Input SQL Instance" 
$StartAudit = Read-Host "Input Start Audit Date (YYYY-MM-DD)"
$EndAudit = Read-Host "Input End Audit Date (YYYY-MM-DD)"
#$Path = Read-Host "Input Path Generate Audit File" 
# Get sql login from keyvault
$sqladmin = 'sqlprb'
$vault='toolscreds'
$secretdetail = Get-AzKeyVaultSecret -VaultName $vault -Name $sqladmin
$sqlcredential = New-Object System.Management.Automation.PSCredential ($secretdetail.Name, $secretdetail.SecretValue)
$output = Invoke-DbaQuery -SqlInstance $SQLInstance  -SqlCredential $sqlcredential -Query "SELECT 
event_time,
action_id,
succeeded,
server_principal_name,
database_name,
schema_name,
object_name,
statement,
host_name
FROM sys.fn_get_audit_file ( 'C:\audit\*.sqlaudit' , DEFAULT , DEFAULT)
where action_id not in ('AUSC')
and cast(event_time as date) between N'$StartAudit' and N'$EndAudit'"
$output | Export-Csv -Path $Path\output.csv -NoTypeInformation