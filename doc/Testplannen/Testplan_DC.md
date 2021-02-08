# Test plan Domain Controller

In this test plan we are going to set up the Domain Controller server with powershell scripts or optionally you can use vagrant to fully automate the process.

## Testing environment

Pull this complete repository to make sure you have all the files required for this test. You will also need [Vagrant](https://www.vagrantup.com/) and the latest version of [VirtualBox](https://www.virtualbox.org/) installed. Restart your device after installing the programs you did not have installed yet.


**IMPORTANT**
Before you begin testing, make sure the DNS server Bravo is running. You can find more information on that here: https://github.com/HoGentTIN/p3ops-2021-g06/tree/master/doc/DNS.

## (PART 1: OPTIONAL) Vagrant

Before continuing you should make sure there are no Vagrant environments remaining from any other tests. You can destroy these environments by going to their corresponding directories and opening a PowerShell command line there. You can do this by entering `powershell` in the address bar.

Enter `vagrant destroy -f` in the PowerShell command line to destroy the remaining environments.

Before continueing, configure the config.yml found at /src/windows/config/config.yml to your needs.

Open a PowerShell command line in `/src/windows` and run the `vagrant up` command which will bring up the DC server. It will take a couple of minutes before the Vagrant environment is set up.

After around 10 minutes the machine should be ready. Open it up with VirtualBox and skip to **PART 3** of this testplan.

## (PART 2: SKIP IF YOU USED VAGRANT) Powershell scripts

Get a clean install of windows server 2019 using VirtualBox and the ISO's found on the official microsoft website. (https://www.microsoft.com/en-US/evalcenter/evaluate-windows-server-2019?filetype=ISO). You may also want to install Guest Additions. This addon for virtualbox will greatly improve performance, as will as utilities such as Drag and Dropping files, Copy and pasting from host to virtual server, etc..

Navigate to the /src/windows/scripts folder and copy the whole scripts folder over to the Virtualbox server.

### 2.1 AD installation
Execute script `01_install_ad.ps1`. This script will configure your virtual adapter options to your configured settings and will install the domain services and promote the server to domain controller. 
When this script finishes the server will reboot. Give it a couple of minutes to apply computer setting.

### 2.2 Organisational Units
Execute script `02_createOU.ps1`. 
This will create the organisational units. No restart is required.

### 2.3 Creating users
Execute script `03_createUsers.ps1`
This script will create a CSV file with users. If needed you can edit the script file and edit the information with your user accounts. Alternatively you can also import your own CVS file with users as long as it follows the same format as this one.

### 2.4 Group policies
Execute script `04_policies.ps1`
This script will create some group policies and set them on the correct Organisational units.

### 2.5 DFS
Execute script `05_DFS.ps1`
This script will install the DFS role and configure a Namespace to be used within our network.


## (PART 3) Confirming everything works

### 3.1 Check AD functionality

1. Execute this script with powershell to make sure the DC and DNS are configured correctly to work together:
`dcdiag /test:dns /v /s:alfa /DnsBasic /f:dcdiagreport.txt`
This will generate a diagreport.txt at the location you executed the script at. If you scroll down to the bottom of the script, both tests should have passed.
2. Open op your server manager. At the top the domain should be set to your configured domain (default: CORONA2020.local).
3. When you open your adapter options for ethernet adapter 2, check the Ipv4 settings and make sure they match your configuration.

### 3.2 Check Organisational Units

On the server manager, navigate to `TOOLS -> Active directory Users and Computers`. When you expand CORONA2020.local (or equivalent to your configured domain name the Organisational units should be created right there. (Administratie, Directie, IT Administratie, Ontwikkeling and Verkoop)).

### 3.3 Create user accounts through CSV file

On the server manager, navigate to the organisational units (See 3.2) and check the members of each OU. There should be atleast 1 member in each OU.

### 3.4 Creating group policies

In the server manager, navigate to `Tools -> Group policy management`. 
There, navigate to `Forest: CORONA2020.local -> Domains -> CORONA2020.local -> Group Policy Objects`. 
There should be 5 policies in total with 3 added by this script: "Disable control panel", "Disables games link" and "Disable network adapter settings". These should all be set to Enabled.

### 3.5 DFS

On the server manager, navigate to `Tools -> DFS management`. In the left panel, when you expand Namespaces, there should be one namespace enabled for our domain.

Author: Dries Melkebeke
