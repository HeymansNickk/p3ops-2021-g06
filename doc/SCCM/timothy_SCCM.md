# SCCM

## Desired outcome

A working SCCM-server with MDT using PXE boot.

## Research

### Microsoft Endpoint Configuration Manager

Microsoft Endpoint Manager is an integrated solution for managing all of your devices. Microsoft brings together Configuration Manager and Intune

### Microsoft Deployment Toolkit

MDT is a unified collection of tools, processes, and guidance for automating desktop and server deployment. You can use it to create reference images or as a complete deployment solution.

## Installation guide

We set the policy to unrestricted. We set a variable for the password, change the computername to echo and restart the computer.

```powershell
Set-ExecutionPolicy Unrestricted
$passwd=ConvertTo-SecureString "Admin2020" -asPlainText -Force
$cred=Get-Credential CORONA.local\Administrator
Rename-Computer -NewName "echo" -Restart -Force
```

Set static IP address

```powershell
Net-NetIPAddress -InterfaceIndex 2 -IPAddress 192.168.0.197 -Prefixlength 29 -DefaultGateway 10.0.2.199
```

Add the server to the CORONA.local domain

```powershell
Add-Computer -DomainName "CORONA.local" -ComputerName "echo" -Credential
$cred
Restart-Computer -Force
```

### Install SQL Server

Mount the ISO-file to the D-disk and install the module for SQL Server

```powershell
Mount-DiskImage -ImagePath "Z:\en_sql_server_2019_developer_x64_dvd_baea4195.iso"
Install-Module -Name SQLServer
```

Install SQL Server 2019 and enable TCP and NP to connect with SCCM. For SCCM the collocation “SQL_latin1_general_CP1_CI_AS” is necessary.

```powershell
E:\setup.exe /Q /IACCEPTSQLSERVERLICENSETERMS /ACTION="install"
/FEATURES=SQL,AS,IS,Tools /INSTANCENAME=MSSQLSERVER
/SQLSVCACCOUNT="CORONA.local\Administrator" /SQLSVCPASSWORD="Admin2020"
/SQLSYSADMINACCOUNTS="CORONA.local\Administrator" /SQLCOLLATION=SQL_latin1_general_CP1_CI_AS
/AGTSVCACCOUNT="CORONA.local\Administrator" /AGTSVCPASSWORD="Admin2020"
/ASSVCACCOUNT="CORONA.local\Administrator" /ASSVCPASSWORD="Admin2020"
/ISSVCAccount="CORONA.local\Administrator" /ISSVCPASSWORD="Admin2020"
/ASSYSADMINACCOUNTS="CORONA.local\Administrator" /TCPENABLED=1 /NPENABLED=1
```

Download and install SQL Server Management Studio

```powershell
$InstallerSQL = $env:TEMP + “\SSMS-Setup-ENU.exe”;
Invoke-WebRequest “https://aka.ms/ssmsfullsetup" -OutFile $InstallerSQL;
start $InstallerSQL /Quiet
Remove-Item $InstallerSQL;
```

Finally we allow port 1433 on the firewall so we SQL connections can be used.

```powershell
netsh advfirewall firewall add rule name = SQLPort dir = in protocol = tcp action = allow localport =
1433 remoteip = localsubnet profile = DOMAIN
```

### Installing Windows Features

On the Site Sever computer, open a PowerShell command prompt as an administrator and type the following commands. This will install the required features

```powershell
Get-Module servermanager
Install-WindowsFeature Web-Windows-Auth
Install-WindowsFeature Web-ISAPI-Ext
Install-WindowsFeature Web-Metabase
Install-WindowsFeature Web-WMI
Install-WindowsFeature BITS
Install-WindowsFeature RDC
Install-WindowsFeature NET-Framework-Features
Install-WindowsFeature Web-Asp-Net
Install-WindowsFeature Web-Asp-Net45
Install-WindowsFeature NET-HTTP-Activation
Install-WindowsFeature NET-Non-HTTP-Activ
```

Ensure that all components are showing as SUCCESS as an EXIT Code. It’s normal to have Windows Update warnings at this point.

![Voorbeeld](https://i.imgur.com/IBzxapv.png)

### Installing ADK

Download the ADKsetup.exe from <http://go.microsoft.com/fwlink/p/?LinkId=526740&ocid=tia-235208000>

Install the ADK(Assesment and Deployment Kit) with following features

- Deployment Tools
- User state Migration tool
- Windows PE

```powershell
Set-Location -Path c:\%USER%\Downloads
.\ADKSetup.exe /quiet /Features OptionId.DeploymentTools OptionId.UserStateMigrationTool OptionId.WindowsPreinstallationEnvironment /forcerestart
```

### Extend the Active Directory Shema

Mount the SCCM iso and extend the AD schema

```powershell
Mount-DiskImage -ImagePath "Z:\mu_microsoft_endpoint_configuration_manager_current_branch_version_2002_x86_x64_dvd_0a4d9a67.iso"
Set-Location -Path E:\SMSSETUP\BIN\X64
.\extadsch.exe
```

### Create the System Management Container

```powershell
# Load the AD module

Import-Module ActiveDirectory

# Figure out our domain

$root = (Get-ADRootDSE).defaultNamingContext

# Get or create the System Management container

$ou = $null
try
{
$ou = Get-ADObject "CN=System Management,CN=System,$root"
}
catch
{
Write-Verbose "System Management container does not currently exist."
}


if ($ou -eq $null)
{
$ou = New-ADObject -Type Container -name "System Management" -Path "CN=System,$root" -Passthru
}

# Get the current ACL for the OU

$acl = get-acl "ad:CN=System Management,CN=System,$root"

# Get the computer's SID

$computer = get-adcomputer $env:ComputerName
$sid = [System.Security.Principal.SecurityIdentifier] $computer.SID

# Create a new access control entry to allow access to the OU

$ace = new-object System.DirectoryServices.ActiveDirectoryAccessRule $sid, "GenericAll", "Allow", "All"

# Add the ACE to the ACL, then set the ACL to save the changes

$acl.AddAccessRule($ace)
Set-acl -aclobject $acl "ad:CN=System Management,CN=System,$root"
```

### Install a Configuration Manager Console

```powershell
Set-Location -Path E:\\SMSSetup\BIN\I386
.\consolesetup.exe /q TargetDir="C:\Program Files\ConfigMgr" EnableSQM=0 DefaultSiteServerName=SCCM.Corona.local
```
### Install SCCM

```powershell
E:\SMSSETUP\BIN\X64\setup.exe /script Z:\Site-setup.ini
```

### Making Boundary and Boundary groups

```powershell
New-CMBoundary -Type ADSite -DisplayName "Active Directory Site" -Value "Default-FirstSite-Name" New-CMBoundaryGroup -Name "ADsite" Set-CMBoundaryGroup -Name "ADsite" -
AddSiteSystemServerName "echo.CORONA2020.local" -DefaultSiteCode "BEL" Add-CMBoundaryToGroup -
BoundaryGroupName "ADSite" -BoundaryName "Active Directory Site" Write-Host
"boundaries/groups Creation completed!" -ForeGroundColor "Green"
```

### Create network access account

```powershell
New-CMAccount -UserName "$username" -Password $passwd -SiteCode "BEL" SetCMSoftwareDistributionComponent -SiteCode "BEL" -AddNetworkAccessAccountName
"CORONA2020\Administrator"
```

### Configure discovery methods

```powershell
Set-CMDiscoveryMethod -ActiveDirectoryForestDiscovery -SiteCode "BEL" -Enabled $true
Set-CMDiscoveryMethod -NetworkDiscovery -SiteCode "BEL" -Enabled $true -
NetworkDiscoveryType ToplogyAndClient
Set-CMDiscoveryMethod -
ActiveDirectorySystemDiscovery -SiteCode "BEL" -Enabled $true -ActiveDirectoryContainer
"LDAP://DC=bel,DC=local"
Set-CMDiscoveryMethod -ActiveDirectoryUserDiscovery -SiteCode
"BEL" -Enabled $true -ActiveDirectoryContainer "LDAP://DC=bel,DC=local" $discoveryScope =
New-CMADGroupDiscoveryScope -LDAPlocation "LDAP://DC=bel,DC=local" -Name
"ADdiscoveryScope" -RecursiveSearch $true
Set-CMDiscoveryMethod -
ActiveDirectoryGroupDiscovery -SiteCode "BEL" -Enabled $true -AddGroupDiscoveryScope
$discoveryScope
```

### Making PXE boot configuration

```powershell
Set-CMDistributionPoint -SiteSystemServerName "echo.CORONA2020.local" -enablePXE $true -AllowPxeResponse $true -EnableUnknownComputerSupport $true -RespondToAllNetwork
```

### WSUS Instalation and Configuration

Install the neccesary Windows roles/features

```powershell
Install-WindowsFeature -Name UpdateServices-DB, UpdateServices-Services -IncludeManagementTools
```

Configure WSUS

```powershell
.\wsusutil.exe postinstall CONTENT_DIR=C:\WSUS
```

Install SoftwareUpdatePoint role on the SCCM console

```powershell
Add-CMSoftwareUpdatePoint -SiteCode "BEL" -
SiteSystemServerName "echo.CORONA2020.local" -ClientConnectionType "Intranet"
```

## Sources

<https://docs.microsoft.com/en-us/windows/deployment/deploy-windows-mdt/get-started-with-the-microsoft-deployment-toolkit>

<https://github.com/MicrosoftDocs/memdocs/tree/master/memdocs>

<https://systemcenterdudes.com/complete-sccm-installation-guide-and-configuration/#sccm>

<https://docs.microsoft.com/en-us/windows-hardware/get-started/adk-offline-install>

<https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-8.1-and-8/dn621910(v=win.10>

<https://docs.microsoft.com/en-us/previous-versions/system-center/system-center-2012-r2/gg712264(v=technet.10>

<https://kimberlydeclercq.be/wp-content/uploads/2020/06/declercq.periode1.pdf>

Author: Timothy Williame

Extra Resources:

<https://www.youtube.com/watch?v=3Mr3Fka8Gb8>

<https://www.youtube.com/playlist?list=PLuB-nSPBO_bNRt9FwrocOlZf4prT-Oa3J>
