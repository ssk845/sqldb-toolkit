param(
    [parameter(Mandatory=$true)]
	[String] $SourceSqlInstance,
    [parameter(Mandatory=$true)]   
    [String] $DestinationSqlInstance,
    [parameter(Mandatory=$true)]
    [String] $BackupShare,
    [parameter(Mandatory=$true)]
    [String] $Database,
    [parameter(Mandatory=$true)]
    [String] $LocalSecondaryPath
      )

$credential = Get-AutomationPSCredential -Name 'sqlps'

Backup-DbaDatabase -SqlInstance $SourceSqlInstance -SqlCredential $credential -Database $Database -Type Full -CompressBackup -Path $BackupShare -BackupFileName $Databasename.bak
Restore-DbaDatabase -SqlInstance $DestinationSqlInstance -SqlCredential $credential -Path $BackupShare -DatabaseName $Database -NoRecovery

Invoke-Sqlcmd -ServerInstance $SourceSqlInstance -Credential $credential -Query "DECLARE @LS_BackupJobId	AS uniqueidentifier `
DECLARE @LS_PrimaryId	AS uniqueidentifier `
DECLARE @SP_Add_RetCode	As int `
`
EXEC @SP_Add_RetCode = master.dbo.sp_add_log_shipping_primary_database `
	@database = N'$Database' `
	,@backup_directory = N'$BackupShare' `
	,@backup_share = N'$BackupShare' `
	,@backup_job_name = N'LSBackup_$Database' `
	,@backup_retention_period = 4320 `
	,@backup_compression = 1`
	,@monitor_server = N'$SourceSqlInstance' `
	,@monitor_server_security_mode = 1 `
	,@backup_threshold = 60 `
	,@threshold_alert_enabled = 1`
	,@history_retention_period = 5760 `
	,@backup_job_id = @LS_BackupJobId OUTPUT `
	,@primary_id = @LS_PrimaryId OUTPUT `
	,@overwrite = 1 `
IF (@@ERROR = 0 AND @SP_Add_RetCode = 0) `
BEGIN `
DECLARE @LS_BackUpScheduleUID	As uniqueidentifier `
DECLARE @LS_BackUpScheduleID	AS int `
EXEC msdb.dbo.sp_add_schedule `
		@schedule_name =N'LSBackupSchedule_$SourceSqlInstance'`
		,@enabled = 1 `
		,@freq_type = 4 `
	    ,@freq_interval = 1 `
		,@freq_subday_type = 4 `
		,@freq_subday_interval = 15 `
		,@freq_recurrence_factor = 0 `
		,@active_start_date = 20211115 `
		,@active_end_date = 99991231 `
		,@active_start_time = 0 `
		,@active_end_time = 235900 `
		,@schedule_uid = @LS_BackUpScheduleUID OUTPUT `
		,@schedule_id = @LS_BackUpScheduleID OUTPUT `
`
EXEC msdb.dbo.sp_attach_schedule `
		@job_id = @LS_BackupJobId `
		,@schedule_id = @LS_BackUpScheduleID  `
`
EXEC msdb.dbo.sp_update_job `
		@job_id = @LS_BackupJobId `
		,@enabled = 1 `
`
END `
`
EXEC master.dbo.sp_add_log_shipping_alert_job `
EXEC master.dbo.sp_add_log_shipping_primary_secondary `
		@primary_database = N'$Database' `
		,@secondary_server = N'$DestinationSqlInstance' `
		,@secondary_database = N'$Database' `
		,@overwrite = 1 "


Invoke-Sqlcmd -ServerInstance $DestinationSqlInstance -Credential $credential -Query "`
DECLARE @LS_Secondary__CopyJobId	AS uniqueidentifier `
DECLARE @LS_Secondary__RestoreJobId	AS uniqueidentifier `
DECLARE @LS_Secondary__SecondaryId	AS uniqueidentifier `
DECLARE @LS_Add_RetCode	As int `

EXEC @LS_Add_RetCode = master.dbo.sp_add_log_shipping_secondary_primary `
		@primary_server = N'$SourceSqlInstance' `
		,@primary_database = N'$Database' `
		,@backup_source_directory = N'$BackupShare' `
		,@backup_destination_directory = N'$LocalSecondaryPath' `
		,@copy_job_name = N'LSCopy_$Database' `
		,@restore_job_name = N'LSRestore_$Database' `
		,@file_retention_period = 4320 `
		,@monitor_server = N'$SourceSqlInstance' `
		,@monitor_server_security_mode = 1 `
		,@overwrite = 1 `
		,@copy_job_id = @LS_Secondary__CopyJobId OUTPUT `
		,@restore_job_id = @LS_Secondary__RestoreJobId OUTPUT `
		,@secondary_id = @LS_Secondary__SecondaryId OUTPUT `
`
IF (@@ERROR = 0 AND @LS_Add_RetCode = 0) `
BEGIN `
`
DECLARE @LS_SecondaryCopyJobScheduleUID	As uniqueidentifier `
DECLARE @LS_SecondaryCopyJobScheduleID	AS int `
`
EXEC msdb.dbo.sp_add_schedule `
		@schedule_name =N'DefaultCopyJobSchedule' `
		,@enabled = 1 `
		,@freq_type = 4 `
		,@freq_interval = 1 `
		,@freq_subday_type = 4 `
		,@freq_subday_interval = 15 `
		,@freq_recurrence_factor = 0 `
		,@active_start_date = 20211115 `
		,@active_end_date = 99991231 `
		,@active_start_time = 0 `
		,@active_end_time = 235900 `
		,@schedule_uid = @LS_SecondaryCopyJobScheduleUID OUTPUT `
		,@schedule_id = @LS_SecondaryCopyJobScheduleID OUTPUT `
`
EXEC msdb.dbo.sp_attach_schedule `
		@job_id = @LS_Secondary__CopyJobId `
		,@schedule_id = @LS_SecondaryCopyJobScheduleID  `
`
DECLARE @LS_SecondaryRestoreJobScheduleUID	As uniqueidentifier `
DECLARE @LS_SecondaryRestoreJobScheduleID	AS int `
`
EXEC msdb.dbo.sp_add_schedule `
		@schedule_name =N'DefaultRestoreJobSchedule' `
		,@enabled = 1 `
		,@freq_type = 4 `
		,@freq_interval = 1 `
		,@freq_subday_type = 4 `
		,@freq_subday_interval = 15 `
		,@freq_recurrence_factor = 0 `
		,@active_start_date = 20211115 `
		,@active_end_date = 99991231 `
		,@active_start_time = 0 `
		,@active_end_time = 235900 `
		,@schedule_uid = @LS_SecondaryRestoreJobScheduleUID OUTPUT `
		,@schedule_id = @LS_SecondaryRestoreJobScheduleID OUTPUT `
`
EXEC msdb.dbo.sp_attach_schedule `
		@job_id = @LS_Secondary__RestoreJobId `
		,@schedule_id = @LS_SecondaryRestoreJobScheduleID  `
`
END `
`
DECLARE @LS_Add_RetCode2	As int `
`
IF (@@ERROR = 0 AND @LS_Add_RetCode = 0) `
BEGIN `
`
EXEC @LS_Add_RetCode2 = master.dbo.sp_add_log_shipping_secondary_database `
		@secondary_database = N'$Database' `
		,@primary_server = N'$SourceSqlInstance' `
		,@primary_database = N'$Database' `
		,@restore_delay = 0 `
		,@restore_mode = 0 `
		,@disconnect_users	= 0 `
		,@restore_threshold = 45 `
		,@threshold_alert_enabled = 1 `
		,@history_retention_period	= 5760 `
		,@overwrite = 1 `
END `
`
IF (@@error = 0 AND @LS_Add_RetCode = 0) `
BEGIN `
EXEC msdb.dbo.sp_update_job `
		@job_id = @LS_Secondary__CopyJobId `
		,@enabled = 1 `
`
EXEC msdb.dbo.sp_update_job `
		@job_id = @LS_Secondary__RestoreJobId `
		,@enabled = 1 `
`
END"

Start-DbaAgentJob -SqlInstance $SourceSqlInstance -SqlCredential $credential -Job LSBackup_$Database
Start-DbaAgentJob -SqlInstance $DestinationSqlInstance -SqlCredential $credential -Job @('LSCopy_'+$Database,'LSRestore_'+$Database) -Wait
Start-DbaAgentJob -SqlInstance $SourceSqlInstance -SqlCredential $credential -Job Alert_$SourceSqlInstance