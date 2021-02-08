# Test plan *service* 

Global description of what is going to be tested and what the outcome should be.


## Testing environment

Pull this complete repository to make sure you have all the files required for this test. You will also need [Vagrant](https://www.vagrantup.com/) and the latest version of [VirtualBox](https://www.virtualbox.org/) installed. Restart your device after installing the programs you did not have installed yet.

## Vagrant

Before continuing you should make sure there are no Vagrant environments remaining from any other tests. You can destroy these environments by going to their corresponding directories and opening a PowerShell command line there. You can do this by entering `powershell` in the address bar.


Enter `vagrant destory -f` in the PowerShell command line to destroy the remaining environments.

Open a PowerShell command line in `/src/linux` and run the `vagrant up *machine*` command which will bring up the DNS server. It will take a couple of minutes before the Vagrant environment is set up.

## Service 

Once the machine is up and running, use `vagrant ssh *machine*` to connect to the machine. To ensure that the service is running perform the following command: `systemctl status *service*`. 

## Other tests


## Vagrant cleanup

When the test has concluded you should destroy the Vagrant environment by using the `vagrant destroy -f` command in your PowerShell command line.
<p>&nbsp;</p>
Authors: 
