#join domain
$domain = "CORONA2020.local"
$username = "Administrator"
$password = "vagrant" | ConvertTo-SecureString -AsPlainText -Force
$credential = New-Object System.management.Automation.PSCredential($username, $password)
Add-Computer -DomainName $domain -Credential $credential
Restart-Computer