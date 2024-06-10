PowerShell DB scripts mostly using dbatools. Each folder is based on various operations. 

- Backuprestore: 
    - backupDBblob.ps1: Powershell script to create a full backup to Azure Blob Storage 
    - getlastDBbackup.ps1: Get last backup details and display in Grid view

- Configurations:
    - configure_enable_sql_replication.ps1: Sample script to configure SQL Replication of Product Table from AdventureWorks Database. Script uses Azure keyvault to manage the passwords. 
    - configure_sql_log_shipping.ps1: Azure automatation script to configure SQL Server Log Shipping 

- Manageusers:
    - createDBuser.ps1: Powershell script to create SQL Login, SQL Users and assign permissions using roles as required
    - dropDBuser.ps1: Powershell script to drop SQL user and SQL Login as required

- Managreplication: 
    - enablereplication.ps1: Powershell script to enable SQL jobs for logical replication. Script uses Azure keyvault to manage the passwords. 
    - disablereplication.ps1: Powershell script to disable SQL jobs for logical replication. Script uses Azure keyvault to manage the passwords. 

- Maskedbacpac:
   - createmaskedbacpac.ps1: Powershell script to generate a bacpac file which will be masked using database masking. Script uses Azure keyvault to manage the passwords.
   - deploymaskedbacpac.ps1:  Powershell script to deploy bacpac file. Script uses Azure keyvault to manage the passwords.

- Reporting: 
    - auditentriessql.ps1: Script to generate audit information from fn_get_audit_file and results are exported in a CSV file.

- SQLKVscripts:
    - configureTDE.ps1: Powershell script to configure TDE. It uses Azure keyvault to manage the credentials.
    - createsqllogin.ps1: Create a new sql login, generates a random password, creates sql user for a given database and assign permission using roles. It uses Azure keyvault to manage the credentials.
    - updatesqllogin.ps1: Rotates SQL login password with a new random password. It uses Azure keyvault to manage the credentials.









