# Windows Server 2019 Domain Controller Automation

### Initiate AD domain services installation
This will provide our requirements to install and promote our Domain Controller. We will set the IP, DNS on the right adapter, check if everything is working and update the script user with debug info on the status.
All these settings can be configured through the config file (/config/config.yml).

```
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
```

### Promote to domain controller
This script will promote our server to Domain Controller with the configured options.
```
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
```

### Creation of organizational Units
We will create the organisational units on the domain controller to fit our internal needs.

```
New-ADOrganizationalUnit -Name "IT Administratie" -Path "DC=CORONA2020,DC=local"
New-ADOrganizationalUnit -Name "Verkoop" -Path "DC=CORONA2020,DC=local"
New-ADOrganizationalUnit -Name "Administratie" -Path "DC=CORONA2020,DC=local"
New-ADOrganizationalUnit -Name "Ontwikkeling" -Path "DC=CORONA2020,DC=local"
New-ADOrganizationalUnit -Name "Directie" -Path "DC=CORONA2020,DC=local"
```

### Creation of users, computers and groups
In this scenario we create the CSV file but you can also import your own. This csv file will import a couple of useraccounts on the domain controller and put them in the correct organisational unit.

```
# Create directory C:\Data
New-Item -Path "c:\" -Name "Data" -ItemType "directory"

# Create CSV file with User data
Add-Content -Path C:\Data\Users.csv  -Value 'firstname,middleInitial,lastname,username,email,streetaddress,city,zipcode,state,country,department,password,telephone,jobtitle,company,ou'

  $users = @(

  'Dries,M,Melkebeke,DMel,dries@corona2020.local,fl leirensstraat 57,Wetteren,9230,Oost-Vlaanderen,Belgium,IT Administratie,Pass123,0478827652,Admin,Corona,"OU=IT Administratie,DC=CORONA2020,DC=local"'
  'Glenn,D,Delanghe,GDel,glenn@corona2020.local,dummystraat 100,Gent,9000,Oost-Vlaanderen,Belgium,Verkoop,Pass123,0478827653,Sales Manager,Corona,"OU=Verkoop,DC=CORONA2020,DC=local"'
  'Timothy,W,Williame,TWil,timothy@corona2020.local,dummystraat 100,Gent,9000,Oost-Vlaanderen,Belgium,Administratie,Pass123,0478827654,Sales rep,Corona,"OU=Administratie,DC=CORONA2020,DC=local"'
  'Wouter,B,Borlee,WBor,wouter@corona2020.local,dummystraat 100,Gent,9000,Oost-Vlaanderen,Belgium,Ontwikkeling,Pass123,0478827655,Rnd manager,Corona,"OU=Ontwikkeling,DC=CORONA2020,DC=local"'
  'Nick,H,Heymans,NHey,nick@corona2020.local,dummystraat 100,Gent,9000,Oost-Vlaanderen,Belgium,Directie,Pass123,0478827655,General Manager,Corona,"OU=Directie,DC=CORONA2020,DC=local"'
  'Michiel,V,Reebroek,MRee,michiel@corona2020.local,dummystraat 100,Gent,9000,Oost-Vlaanderen,Belgium,Directie,Pass123,0478827657,CEO,Corona,"OU=Directie,DC=CORONA2020,DC=local"'
  )

  $users | foreach { Add-Content -Path  C:\Data\Users.csv -Value $_ }


# Import users into OU's
# Import active directory module for running AD cmdlets
Import-Module activedirectory
  
#Store the data from ADUsers.csv in the $ADUsers variable
$ADUsers = Import-csv C:\Data\Users.csv

#Loop through each row containing user details in the CSV file 
foreach ($User in $ADUsers)
{
	#Read user data from each field in each row and assign the data to a variable as below
		
	$Username 	= $User.username
	$Password 	= $User.password
	$Firstname 	= $User.firstname
	$Lastname 	= $User.lastname
	$OU 		= $User.ou #This field refers to the OU the user account is to be created in
    $email      = $User.email
    $streetaddress = $User.streetaddress
    $city       = $User.city
    $zipcode    = $User.zipcode
    $state      = $User.state
    $country    = $User.country
    $telephone  = $User.telephone
    $jobtitle   = $User.jobtitle
    $company    = $User.company
    $department = $User.department
    $Password = $User.Password

	#Check to see if the user already exists in AD
	if (Get-ADUser -F {SamAccountName -eq $Username})
	{
		 #If user does exist, give a warning
		 Write-Warning "A user account with username $Username already exist in Active Directory."
	}
	else
	{
		#User does not exist then proceed to create the new user account
		
        #Account will be created in the OU provided by the $OU variable read from the CSV file
		New-ADUser `
            -SamAccountName $Username `
            -UserPrincipalName "$Username@CORONA2020.local" `
            -Name "$Firstname $Lastname" `
            -GivenName $Firstname `
            -Surname $Lastname `
            -Enabled $True `
            -DisplayName "$Lastname, $Firstname" `
            -Path $OU `
            -City $city `
            -Company $company `
            -State $state `
            -StreetAddress $streetaddress `
            -OfficePhone $telephone `
            -EmailAddress $email `
            -Title $jobtitle `
            -Department $department `
            -AccountPassword (convertto-securestring $Password -AsPlainText -Force) -ChangePasswordAtLogon $True
	}
}
```

### Rules on user level

Only give IT Administratie access to Control Panel, Disable games links menu and Disable network adapter access for Administratie and Verkoop

```
# Set GPO names
$gpoControlPanel = "Disable control panel"
$gpoGamesLink = "Disable games link"
$gpoNetworkSettings = "Disable Network Adapter settings"

# Set target OU's
$ouControlPanel = @('OU=Administratie,DC=CORONA2020,DC=local', 'OU=Verkoop,DC=CORONA2020,DC=local', 'OU=Ontwikkeling,DC=CORONA2020,DC=local', 'OU=Directie,DC=CORONA2020,DC=local')
$ouGamesLink = @('OU=Administratie,DC=CORONA2020,DC=local', 'OU=Verkoop,DC=CORONA2020,DC=local', 'OU=Ontwikkeling,DC=CORONA2020,DC=local', 'OU=Directie,DC=CORONA2020,DC=local', 'OU=IT Administratie,DC=CORONA2020,DC=local')
$ouNetwork = @('OU=Administratie,DC=CORONA2020,DC=local', 'OU=Verkoop,DC=CORONA2020,DC=local')

# Disable control panel access with Registry key
New-GPO -Name $gpoControlPanel -Comment "Disable control panel"
Set-GPRegistryValue -Name $gpoControlPanel -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ValueName NoControlPanel -Type DWord -Value 1

# Disable Games Links Menu with Registry key
New-GPO -Name $gpoGamesLink -Comment "Disable Games Link Menu"
Set-GPRegistryValue -Name $gpoGamesLink -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ValueName NoStartMenuMyGames -Type DWord -Value 1

# Disable Network Adapter settings with Registry key
New-GPO -Name $gpoNetworkSettings -Comment "Disable Network Adapter Settings"
Set-GPRegistryValue -Name $gpoNetworkSettings -Key "HKCU\Software\Policies\Microsoft\Windows\Network Connections" -ValueName NC_LanChangeProperties -Type DWord -Value 1

# Link GPO's to OU's
foreach($ou in $ouControlPanel) {New-GPLink -Name $gpoControlPanel -Target $ou }
foreach($ou in $ouGamesLink) {New-GPLink -Name $gpoGamesLink -Target $ou }
foreach($ou in $ouNetwork) {New-GPLink -Name $gpoNetworkSettings -Target $ou }
```

### DFS
DFS installation requires few commands. We create a SMB share and make a Dfsfolder with it to share accross the network.

```
#Install DFS features
install-windowsfeature FS-DFS-Namespace, FS-DFS-Replication -IncludeManagementTools -restart

#Create folder for sharing
mkdir c:\DFSRoot\Public

#Create MsbShare and Namespace within DFS
New-SmbShare –Name Public –Path C:\DFSRoot\Public -ReadAccess "Everyone"
New-DfsnRoot -TargetPath "\\alfa\Public" -Type DomainV2 -Path "\\CORONA2020.local\Public"
```

Author: Dries Melkebeke
