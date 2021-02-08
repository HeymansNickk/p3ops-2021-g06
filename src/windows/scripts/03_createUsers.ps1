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