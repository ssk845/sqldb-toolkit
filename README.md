### 🧰 SQLDB Toolkit

A personal collection of PowerShell and SQL scripts leveraging **[dbatools](https://dbatools.io/)** to automate and streamline Microsoft SQL Server administration tasks — including backups, user management, replication, reporting, managing SA passwords using Azure Key Vault and more.

> ✅ This repo is for **learning, reference, and demonstration purposes only.**

---

## 📦 Toolkit Overview

| Folder           | Purpose |
|------------------|---------|
| `Backuprestore/`     | Automates full, differential, and log backups and restore processes using dbatools commands. |
| `Configurations/`    | Scripts to review or configure SQL Server instance settings. |
| `Manageusers/`       | Automates creation and permission management of logins and users via dbatools. |
| `Managreplication/`  | Tools to monitor or validate SQL Server replication status. |
| `Maskedbacpac/`      | Export masked datasets using BACPAC for dev/test environments. |
| `Reporting/`         | Basic scripts for auditing and reporting (e.g. performance or usage). |
| `SQLKVscripts/`      | managing SA passwords using Azure Key Vault and custom scripts for general use cases. |


---

## 🚀 Getting Started

Clone the repository:
```bash
   git clone https://github.com/ssk845/sqldb-toolkit.git
   cd sqldb-toolkit
```
Ensure you have PowerShell 5.1+ and install dbatools module if you haven't already:

powershell
```
Install-Module dbatools -Scope CurrentUser
```
Explore and run scripts from the relevant folders.

Many scripts uses dbatools cmdlets — refer to [dbatools documentation](https://dbatools.io/) for more info.

## 🔐  Notes on Security

No sensitive credentials are included.
Always use secure methods when handling passwords (e.g., Read-Host -AsSecureString).
Masked exports should be tested carefully before sharing.

🧪 Tested On
- Windows Server 2019 / 2022
- SQL Server 2016 – 2022
- PowerShell 5.1+
- dbatools latest stable version

👤 Author
Created and maintained by Saad Kanwar

🔗 GitHub: @ssk845

💼 Sharing for personal portfolio, DevOps learning, and project visibility.


📄 License
[MIT LICENSE](https://opensource.org/license/MIT)


