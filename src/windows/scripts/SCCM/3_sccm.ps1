#this script will install sccm

$SECMDownloadLink = "https://download.microsoft.com/download/e/0/a/e0a2dd5e-2b96-47e7-9022-3030f8a1807b/MEM_Configmgr_2002.exe"

#Extend the active directory scheme
Set-Location C:/
Invoke-WebRequest $SECMDownloadLink -OutFile SECM.exe
add-type -AssemblyName System.IO.Compression.FileSystem
[system.io.compression.zipFile]::ExtractToDirectory('c:\SECM.exe','c:\SECM')
Set-Location C:\SECM\SMSSETUP\bin\x64\
.\extadsch

#create container for management in AD
#load the AD module
Import-Module ActiveDirectory
#figure out our domain
$root = (Get-ADRootDSE).defaultNamingContext
$ou = $null 
#get or create system management container
try 
{ 
$ou = Get-ADObject "CN=System Management,CN=System,$root" 
} 
catch 
{ 
Write-Verbose "System Management container does not currently exist." 
}
#get acl OU
if ($ou -eq $null) 
{ 
$ou = New-ADObject -Type Container -name "System Management" -Path "CN=System,$root" -Passthru 
}
$acl = get-acl "ad:CN=System Management,CN=System,$root"
#get computer SID
$computer = get-adcomputer $env:ComputerName 
$sid = [System.Security.Principal.SecurityIdentifier] $computer.SID
#create access enty
$ace = new-object System.DirectoryServices.ActiveDirectoryAccessRule $sid, "GenericAll", "Allow", "All"

$acl.AddAccessRule($ace) 
Set-acl -aclobject $acl "ad:CN=System Management,CN=System,$root"

#Create service and user account
Import-Module ActiveDirectory
New-ADGroup -Name "SCCM_Admins"  -GroupScope Global

New-ADUser -Name "SCCM_SQLService" -SamAccountName "sqlsccm" -Path "CN=SCCM-Admins, CN=Users, DC=michiel, DC=corona" -AccountPassword(Read-Host -AsSecureString "Admin2020") -Enabled $true
New-ADUser -Name "SCCM_SQLSvrAgent" -SamAccountName "sqlsvragent" -Path "CN=SCCM-Admins, CN=Users, DC=michiel, DC=corona" -AccountPassword(Read-Host -AsSecureString "Admin2020") -Enabled $true
New-ADUser -Name "SCCMAdmin" -SamAccountName "sccmadmin" -Path "CN=SCCM-Admins, CN=Users, DC=michiel, DC=corona" -AccountPassword(Read-Host -AsSecureString "Admin2020") -Enabled $true

#firewall configuration
netsh advfirewall firewall add rule name=“SQL Server” dir=in action=allow protocol=TCP localport=1433
netsh advfirewall firewall add rule name=“SQL Admin Connection” dir=in action=allow protocol=TCP localport=1434
netsh advfirewall firewall add rule name=“SQL Service Broker” dir=in action=allow protocol=TCP localport=4022
netsh advfirewall firewall add rule name=“SQL Debugger/RPC” dir=in action=allow protocol=TCP localport=135
netsh advfirewall firewall add rule name=“Analysis Services” dir=in action=allow protocol=TCP localport=2383
netsh advfirewall firewall add rule name=“SQL Browser” dir=in action=allow protocol=TCP localport=2382
netsh advfirewall firewall add rule name=“HTTP” dir=in action=allow protocol=TCP localport=80
netsh advfirewall firewall add rule name=“SSL” dir=in action=allow protocol=TCP localport=443
netsh advfirewall firewall add rule name=“SQL Browser” dir=in action=allow protocol=TCP localport=1434
netsh advfirewall firewall add rule name=“ICMP Allow incoming V4 echo request” protocol=icmpv4:8,any dir=in action=allow

#windows server roles and features
Get-Module ServerManager
Install-WindowsFeature Web-Windows-Auth
Install-WindowsFeature Web-ISAPI-Ext
Install-WindowsFeature Web-Metabase
Install-WindowsFeature Web-WMI
Install-WindowsFeature BITS
Install-WindowsFeature RDC
Install-WindowsFeature NET-Framework-Features -source \\servername\source\sxs
Install-WindowsFeature Web-Asp-Net
Install-WindowsFeature Web-Asp-Net45
Install-WindowsFeature NET-HTTP-Activation
Install-WindowsFeature NET-WCF-HTTP-Activation45

#report viewer
Set-Location C:\
$linkCLR = "https://download.microsoft.com/download/1/3/0/13089488-91FC-4E22-AD68-5BE58BD5C014/ENU/x64/SQLSysClrTypes.msi"
$linkReport = "https://download.microsoft.com/download/A/1/2/A129F694-233C-4C7C-860F-F73139CF2E01/ENU/x86/ReportViewer.msi"
Invoke-WebRequest $linkCLR -OutFile CLR.exe
Invoke-WebRequest $linkReport -OutFile Report.msi
.\CLR.exe
.\Report.msi


#ADK for windows + WSUS
Set-Location C:\
$ADKDownloadLink = "https://download.microsoft.com/download/B/E/6/BE63E3A5-5D1C-43E7-9875-DFA2B301EC70/adk/adksetup.exe"
$pedow = "https://download.microsoft.com/download/3/c/2/3c2b23b2-96a0-452c-b9fd-6df72266e335/adkwinpeaddons/adkwinpesetup.exe"
Invoke-WebRequest $ADKDownloadLink -OutFile ADK.exe
Invoke-WebRequest $pedown -OutFile pedown.exe
.\ADK.exe /installpath "C:\Program Files (x86)\Windows Kits\10" OptionId.DeploymentToolsOptionId.DeploymentTools /ceip off /norestart
.\pedown.exe /installpath "C:\Program Files (x86)\Windows Kits" OptionId.WindowsPreinstallationEnvironment /ceip off /norestart
#install wsus
Set-Location c:\
Install-WindowsFeature -Name UpdateServices-DB, UpdateServices-Services -IncludeManagementTools
.\wsusutil.exepostinstall SQL_INSTANCE_NAME="WIN-SCCM" CONTENT_DIR=C:\WSUS

#install dedicated SQL instance
$sqllink = "https://download.microsoft.com/download/d/a/2/da259851-b941-459d-989c-54a18a5d44dd/SQL2019-SSEI-Dev.exe"
Invoke-WebRequest $sqllink -OutFile sqlserv2019.exe
Start-Process -FilePath ./sqlserv2019.exe -ArgumentList "/action=download /quiet /enu /MediaPath=C:/" -wait
Remove-Item ./sqlserv2019.exe
Start-Process -FilePath C:/SQL2019_x64_ENU.exe -WorkingDirectory C:/ /qs -wait
Start-Process -FilePath C:/SQL2019_x64_ENU/SETUP.EXE -ArgumentList "/Q /Action=install /IAcceptSQLServerLicenseTerms /FEATURES=SQL,RS,Tools /TCPENABLED=1 /SECURITYMODE=`"SQL`" /SQLSVCACCOUNT="$domain\SQLServAgent" /SQLSYSADMINACCOUNTS=`"$domain\Domain Admins`" /INSTANCENAME=`"MSSQLSERVER`" /INSTANCEID=`"SQL`" /AGTSVCACCOUNT="NT AUTHORITY\Network Service" SQLCOLLATION=SQL_Latin1_General_CP1_CI_AS /SQLSVCPASSWORD=`"Admin2020`"" -wait

#preq check
C:\SECM\SMSSETUP\BIN\X64\prereqchk.exe /AdminUI

#secm install
Set-Location C:\
.\SECM\SMSSETUP\BIN\X64\setup.exe /script .\config.ini