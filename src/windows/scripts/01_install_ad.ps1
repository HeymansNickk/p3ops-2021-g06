# processing commandline parameter
param (
    [string]$domain = "CORONA2020.local",
    [string]$DomainMode = "WinThreshold",
    [string]$ip = "192.100.100.194",
    [string]$dns1 = "192.100.100.195",
    [string]$PlainPassword
 )

# - Variables ---------------------------------------------------------------
# set default value for netbiosDomain if empty
$netbiosDomain = $domain.ToUpper() -replace "\.\w*$",""

# define subnet based on ip
$subnet = $ip -replace "\.\w*$", ""


# - Main --------------------------------------------------------------------
Write-Host '= Start setup DC ======================================='
Write-Host "Domain              : $domain"
Write-Host "Domain Mode         : $DomainMode"
Write-Host "IP                  : $ip"
Write-Host "DNS 1               : $dns1"
Write-Host "Default Password    : $PlainPassword"

# initiate AD setup if system is not yet part of a domain
if ((gwmi win32_computersystem).partofdomain -eq $false) {
    Import-Module ServerManager
    Add-WindowsFeature RSAT-AD-PowerShell,RSAT-AD-AdminCenter,RSAT-ADDS-Tools

    Write-Host '- Relax password complexity --------------------------------'
    # Disable password complexity policy
    secedit /export /cfg C:\secpol.cfg
    (gc C:\secpol.cfg).replace("PasswordComplexity = 1", "PasswordComplexity = 0") | Out-File C:\secpol.cfg
    secedit /configure /db C:\Windows\security\local.sdb /cfg C:\secpol.cfg /areas SECURITYPOLICY
    rm -force C:\secpol.cfg -confirm:$false

    # Set administrator password
    $computerName = $env:COMPUTERNAME
    $adminUser = [ADSI] "WinNT://$computerName/Administrator,User"
    $adminUser.SetPassword($PlainPassword)
    $adminUser.SetInfo()

    $SecurePassword = $PlainPassword | ConvertTo-SecureString -AsPlainText -Force
    
    Write-Host '- Configuring network adapter --------------------------------'
    $newDNSServers = $dns1

    $adapters = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.IPAddress -And ($_.IPAddress).StartsWith($subnet) }
    if ($adapters) {
        Write-Host Setting DNS
        $adapters | ForEach-Object {$_.SetDNSServerSearchOrder($newDNSServers)}
    }

    # Set-NetIPAddress -InterfaceAlias "Ethernet 2" -IPAddress $ip -PrefixLength 27 -DefaultGateway $ip
    # Set-DnsClientServerAddress -InterfaceAlias "Ethernet 2" -ServerAddresses $dns1

    Write-Host '- Creating domain controller -------------------------------'
    # Create AD Forest for Windows Server 2012 R2
    Install-WindowsFeature AD-domain-services
    Import-Module ADDSDeployment
    Install-ADDSForest `
        -DatabasePath "C:\Windows\NTDS" `
        -DomainMode "WinThreshold" `
        -DomainName $domain `
        -DomainNetbiosName "CORONA" `
        -SafeModeAdministratorPassword $SecurePassword `
        -ForestMode "WinThreshold" `
        -InstallDns:$false `
        -LogPath "C:Windows\NTDS" `
        -NoRebootOnCompletion:$true `
        -SysvolPath "C:\Windows\SYSVOL" `
        -Force:$true

}
Write-Host '= Finish AD deployment ============================================'
# --- EOF --------------------------------------------------------------------
