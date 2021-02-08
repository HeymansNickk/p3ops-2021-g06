# Test report Domain Controller

In this test report the stept to reproduce a functional Domain Controller were followed using the Vagrant Option.


## (PART 1: OPTIONAL) Vagrant

The `vagrant destroy -f` command was run to ensure that there were no previous build present, this completed without a problem.

Next `vagrant up bravo` was performed in the `/src/linux` folder to start the installation of the DNS server.

Then `vagrant up` was performed to start the install of the Domain Controller, after a few minutes the Domain Controller was up and running.

## (PART 3) Confirming everything works

### 3.1 Check AD functionality

1. `dcdiag /test:dns /v /s:alfa /DnsBasic /f:dcdiagreport.txt` was executed.

![DNS-DC Connection](./ScreenShots/DNS-DC%20Conn.png)

1. Domain was set correctly
2. IP was set correctly

![Domain and IP Settings](./ScreenShots/Domain%20-%20IP.png)


### 3.2 Check Organisational Units

Navigating to `TOOLS -> Active directory Users and Computers` gave the following results.

![OU](./ScreenShots/OU.png)

### 3.3 Create user accounts through CSV file

The OU's had following users added to them.  
![User Administratie](./ScreenShots/User%20Administratie.png)  
![User Directie](./ScreenShots/User%20Directie.png)  
![User IT Administratie](./ScreenShots/User%20IT%20Administratie.png)  
![User Ontwikkeling](./ScreenShots/User%20Ontwikkeling.png)  
![User Verkoop](./ScreenShots/User%20Verkoop.png)  

### 3.4 Creating group policies

Navigating to `Tools -> Group policy management`, `Forest: CORONA2020.local -> Domains -> CORONA2020.local -> Group Policy Objects` gave the following results.

![GPO](./ScreenShots/GPO.png)


### 3.5 DFS

The next check was not possible due to the lack of a working SCCM server at this point in time.
```
On the server manager, navigate to `Tools -> DFS management`. In the left panel, when you expand Namespaces, there should be one namespace enabled for our domain.
```


Author: Glenn Delanghe
