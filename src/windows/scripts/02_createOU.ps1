Write-Host "Waiting until system fully booted"
Start-Sleep -s 360
New-ADOrganizationalUnit -Name "IT Administratie" -Path "DC=CORONA2020,DC=local"
New-ADOrganizationalUnit -Name "Verkoop" -Path "DC=CORONA2020,DC=local"
New-ADOrganizationalUnit -Name "Administratie" -Path "DC=CORONA2020,DC=local"
New-ADOrganizationalUnit -Name "Ontwikkeling" -Path "DC=CORONA2020,DC=local"
New-ADOrganizationalUnit -Name "Directie" -Path "DC=CORONA2020,DC=local"