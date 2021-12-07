#Sample script to configure SQL Replication of Product Table from AdventureWorks Database
# Connect to Azure and suppress the output
Connect-AzAccount | Out-Null
# Get input
$SqlInstance = Read-Host "Input SQL Instance" 
$DestinationDB = Read-Host "Input Destination Database"
# Set Publisher Name
$PublisherName = 'TestPub'
# Get sql login from keyvault
$vault = 'toolscreds'
$sqladmin = 'sqladmin'
$secretdetail = Get-AzKeyVaultSecret -VaultName $vault -Name $sqladmin
$sqlcredential = New-Object System.Management.Automation.PSCredential ($secretdetail.Name, $secretdetail.SecretValue)
# Set Snapshot and Subscription Settings
Invoke-DbaQuery -SqlInstance $SqlInstance -SqlCredential $sqlcredential -Query " use master
exec sp_adddistributor @distributor = N'$SqlInstance ', @password = N''
GO
use master
exec sp_adddistributiondb @database = N'distribution', @data_folder = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQL1\MSSQL\Data',
@log_folder = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQL1\MSSQL\Data', @log_file_size = 2, @min_distretention = 0, @max_distretention = 72, 
@history_retention = 48, @deletebatchsize_xact = 5000, @deletebatchsize_cmd = 2000, @security_mode = 1
GO
use [distribution] 
if (not exists (select * from sysobjects where name = 'UIProperties' and type = 'U ')) 
create table UIProperties(id int) 
if (exists (select * from ::fn_listextendedproperty('SnapshotFolder', 'user', 'dbo', 'table', 'UIProperties', null, null))) 
EXEC sp_updateextendedproperty N'SnapshotFolder', N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQL1\MSSQL\ReplData', 'user', dbo, 'table', 'UIProperties' 
else 
EXEC sp_addextendedproperty N'SnapshotFolder', N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQL1\MSSQL\ReplData', 'user', dbo, 'table', 'UIProperties'
GO
use master
exec sp_adddistpublisher @publisher = N'$SqlInstance ', @distribution_db = N'distribution', @security_mode = 1, 
@working_directory = N'C:\tmp\repldata\', @trusted = N'false', @thirdparty_flag = 0, @publisher_type = N'MSSQLSERVER'
GO
use [AdventureWorksLT2019]
exec sp_replicationdboption @dbname = N'AdventureWorksLT2019', @optname = N'publish', @value = N'true'
GO
use [AdventureWorksLT2019]
exec sp_addpublication @publication = N'$PublisherName', 
@description = N'Transactional publication of database ''AdventureWorksLT2019'' from Publisher ''$SqlInstance ''.', 
@sync_method = N'concurrent', @retention = 0, @allow_push = N'true', @allow_pull = N'true', @allow_anonymous = N'true', 
@enabled_for_internet = N'false', @snapshot_in_defaultfolder = N'true', @compress_snapshot = N'false', @ftp_port = 21, 
@allow_subscription_copy = N'false', @add_to_active_directory = N'false', @repl_freq = N'continuous', @status = N'active', 
@independent_agent = N'true', @immediate_sync = N'true', @allow_sync_tran = N'false', @allow_queued_tran = N'false', @allow_dts = N'false', 
@replicate_ddl = 1, @allow_initialize_from_backup = N'false', @enabled_for_p2p = N'false', @enabled_for_het_sub = N'false'
GO
use [AdventureWorksLT2019]
exec sp_addpublication_snapshot @publication = N'$PublisherName', @frequency_type = 1, @frequency_interval = 1, @frequency_relative_interval = 1, 
@frequency_recurrence_factor = 0, @frequency_subday = 8, @frequency_subday_interval = 1, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, 
@active_start_date = 0, @active_end_date = 0, @job_login = null, @job_password = null, @publisher_security_mode = 1
use [AdventureWorksLT2019]
exec sp_addarticle @publication = N'$PublisherName', @article = N'Product', @source_owner = N'SalesLT', @source_object = N'Product', 
@type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', 
@schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'Product', 
@destination_owner = N'SalesLT', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_SalesLTProduct', 
@del_cmd = N'CALL sp_MSdel_SalesLTProduct', @upd_cmd = N'SCALL sp_MSupd_SalesLTProduct'
GO"

# Set Publication Settings
Invoke-DbaQuery -SqlInstance $SqlInstance -SqlCredential $sqlcredential -Query "use [AdventureWorksLT2019]
exec sp_addsubscription @publication = N'$PublisherName', @subscriber = N'$SqlInstance', @destination_db = N'$DestinationDB', @subscription_type = N'Push', 
@sync_type = N'automatic', @article = N'all', @update_mode = N'read only', @subscriber_type = 0
exec sp_addpushsubscription_agent @publication = N'$PublisherName', @subscriber = N'$SqlInstance', @subscriber_db = N'$DestinationDB', 
@job_login = null, @job_password = null, @subscriber_security_mode = 1, @frequency_type = 64, @frequency_interval = 0, 
@frequency_relative_interval = 0, @frequency_recurrence_factor = 0, @frequency_subday = 0, @frequency_subday_interval = 0, 
@active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 20211104, @active_end_date = 99991231, 
@enabled_for_syncmgr = N'False', @dts_package_location = N'Distributor'
GO"

# start Sanpshot SQL Job 
Start-DbaAgentJob -SqlInstance $SqlInstance -SqlCredential $sqlcredential -Job $SqlInstance-AdventureWorksLT2019-$PublisherName-1 