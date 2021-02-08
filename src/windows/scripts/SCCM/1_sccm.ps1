#this script changes the hostname of the deployment server & sets the ip addresses
Write-Host "Setting hostname"
Rename-Computer -NewName WIN-SCCM

#setting the time zone for the server to Brussels
Write-Host "Changing time zone to Brussels"
Set-TimeZone -name "Romance Standard Time"

#setting static ip-address and assigning dns server
Write-Host "Setting static ip and setting dns-server"
netsh interface ip set address "Ethernet" static 192.168.100.40 255.255.255.0
Set-DnsClientServerAddress -InterfaceAlias Ethernet -ServerAddresses 192.168.100.10

#restarting the domain controller
Write-Host "Restarting the deployment server"
Restart-Computer -Force