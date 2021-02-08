# SCCM documentation

## Scripts

### Download SQL Intallation
```
$sqlDownloadLink = "https://download.microsoft.com/download/5/E/9/5E9B18CC-8FD5-467E-B5BF-BADE39C51F73/SQLServer2017-SSEI-Expr.exe"
    Set-Location C:/
    Invoke-WebRequest $sqlDownloadLink -OutFile SQLServer.exe
    Start-Process -FilePath ./SQLServer.exe -ArgumentList "/action=download /quiet /enu /MediaPath=C:/" -wait
    Remove-Item ./SQLServer.exe
```

### Automate SQL installation
```
$pathToConfigurationFile = "C:\Program Files\Microsoft SQL Server\140\Setup Bootstrap\Log\20201129_055113\ConfigurationFile.ini"
$copyFileLocation = "C:\Temp\ConfigurationFile.ini"
$errorOutputFile = "C:\Temp\ErrorOutput.txt"
$standardOutputFile = "C:\Temp\StandardOutput.txt"

Write-Host "Copying the ini file."

New-Item "C:\Temp" -ItemType "Directory" -Force
Remove-Item $errorOutputFile -Force
Remove-Item $standardOutputFile -Force
Copy-Item $pathToConfigurationFile $copyFileLocation -Force

Write-Host "Getting the name of the current user to replace in the copy ini file."

$user = "$env:UserDomain\$env:USERNAME"

write-host $user

Write-Host "Replacing the placeholder user name with your username"
$replaceText = (Get-Content -path $copyFileLocation -Raw) -replace "##MyUser##", $user
Set-Content $copyFileLocation $replaceText

Write-Host "Starting the install of SQL Server"
Start-Process C:\SQLEXPR_x64_ENU.exe "/ConfigurationFile=$copyFileLocation" -Wait -RedirectStandardOutput $standardOutputFile -RedirectStandardError $errorOutputFile

$standardOutput = Get-Content $standardOutputFile -Delimiter "\r\n"

Write-Host $standardOutput

$errorOutput = Get-Content $errorOutputFile -Delimiter "\r\n"

Write-Host $errorOutput
```

### SCCM automation
```
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
    Install-WindowsFeature WDS
    dism /online /enable-feature /featurename:NetFX3 /all /Source:d:\sources\sxs /LimitAccess
```

# ADK installation

```
$ADKDownloadLink = "https://download.microsoft.com/download/E/F/A/EFA17CF0-7140-4E92-AC0A-D89366EBD79E/adkwinpeaddons/adkwinpesetup.exe"
    Invoke-WebRequest $ADKDownloadLink -OutFile ADK.exe
    .\ADK.exe /installpath "C:\Program Files (x86)\Windows Kits\10" /features OptionId.WindowsPreinstallationEnvironment /ceip off /norestart
```

# Installing WSUS Features

```
Install-WindowsFeature -Name UpdateServices-Services, UpdateServices-DB -IncludeManagementTools
```

# SCCM installation

```
   $DownloadLink ="https://download.microsoft.com/download/D/8/E/D8E795CE-44D7-40B7-9067-D3D1313865E5/Configmgr_TechPreview2010.exe"

    Set-Location C:/
    Invoke-WebRequest $DownloadLink -OutFile ssms.exe

    .\Configmgr_TechPreview2010\SMSSETUP\BIN\X64\setup.exe /script .\SCCM\Config.ini
```
    
