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