# Installation -and userguide GNS3

## Installation

Follow these steps to download GNS3 to your PC. Using a web browser, browse to https://gns3.com/software/download and click the Free Download link. Login with your GNS3 account(or create on if you don't have one yet).

Next follow the install guide at https://docs.gns3.com/docs/getting-started/installation/windows/ (or https://docs.gns3.com/docs/getting-started/installation/mac/ if you're on an apple machine). You don't need to change anything in the wizards so just click on through. 

When starting GNS3 for the first time you will get this screen ![](https://i.imgur.com/qRcrUfd.png). Just click "Cancel". When the window is closed look at the "Servers Summary" section to check if GNS3 is connected. It should look like this: ![](https://i.imgur.com/jAYdKTd.png)
If the "Servers Summary" is empty you have to restart GNS3 (or your entire pc), this usually fixes the issues. If that does not fix it, you might want to check if your firewall or antivirus software is blocking GNS3. You can also use the "GNS3 doctor" (Help > GNS3 Doctor) to check for any errors thrown by GNS3.

To create a new project, simple go to File > New Black Project and give it a name and a location on your drive.

## GNS3 vm[^1]
- prerequisites:
  - VirtualBox
  - GNS3 vm (https://gns3.com/software/download-vm)

### Usage
Why do we need the GNS3 vm? The GNS3 vm is needed to run network appliances (Switches, routers,...), because they need to be emulated.   

#### Installing the vm
Import the downloaded vm in virtualbox (File > Import Appliance > "/localPath/to/GNS3 VM.ova"). 
Start GNS3 and go to Edit > Preferences > GNS3 VM > "Enable the GNS3 VM" > Virtualization Engine = VirtualBox > Set RAM and vCPU cores  (only adjust these parameters in de GNS3 GUI, not in virtualBox) > Click OK
You might the following error: [^2]
 
> Cannot enable nested VT-x/AMD-V without nested-paging and unresricted guest execution! (VERR_CPUM_INVALID_HWVIRT_CONFIG). 

This happens because Hyper-V and other VM programs can't always run together. The fix is fairly simple: 
- Run this command (as administrator) 
> bcdedit /set hypervisorlaunchtype off
- Next search for "Windows features" on your local pc and disable "Virtual Machine Platform"
- reboot your pc
<small>Sidenote: if you want to use "Windows Subsystem For Linux" you will have to revert these steps.</small>

Wait until the vm has booted. On the first screen, check if KVM support is set to true. If it is not set to true, you have to go to the settings of the vm (in virtualbox) and enable Nested VT-x/AMD-v (under System > Processor). If is still not available, reboot the pc and enter the BIOS. Under Advanced, make sure that "Intel Virtualization Technology" is enabled. This is necessary for nested virtualization in VirtualBox. Save the settings and reboot the pc. 

## Using Cisco IOS images
#### Download
First you  need to download the images, you find them [here](https://drive.google.com/drive/folders/102jxZ9ECpe6ZFtXYdK_81iEVuuFoGOGR). Find the neccesary images and download them. 

#### importing images
- First we are going to import a router image (this is the same process as importing a Swicht image). Click on the routers tab > New Template 
![](https://i.imgur.com/5c8MaCl.png)
- Select "Install an appliance from the GNS3 server" 
![](https://i.imgur.com/WyTJwSf.png) 
- Click Next and select the neccesary device, then click Install.
![](https://i.imgur.com/pjlNCiB.png)
- Select "Install the appliance on the GNS3 VM", then click Next 
![](https://i.imgur.com/h9KOwgy.png)
- Leave the QEMU settings at default and click Next 
![](https://i.imgur.com/yzLK5m8.png)
- Click on the 'vios....M3' file and then click on 'Import'. Select the file in your directory  
![](https://i.imgur.com/16C5BEB.png)
![](https://i.imgur.com/11PkVPx.png)
- Click Yes on the pop-up 
![](https://i.imgur.com/hPceA3I.png)
- Do the same for the 'startup_config-img' file and click Next 
- Click Yes on the pop-up
![](https://i.imgur.com/vwVrxSZ.png)
- Wait until the image is uploaded to the vm click Finish and OK
![](https://i.imgur.com/EqVxUsn.png)

## Building a network
To create a network we will need routers, switches, end devices etc. These can be found in their respective categories ![](https://i.imgur.com/V91iLvN.png). 
By right-clicking on devices they can be configured and connected. If you select "Console" Solar-PuTTY will open a console connection to the selected device.

## Adding Vitualbox vm's 
- prerequisites:
  - vm's are installed and configured
### Adding the VMs
- Open your GNS3 project. Go to Edit > Preferences > Virtualbox > VirtualBox VMs and click New
![](https://i.imgur.com/sM1hhxk.png)
- Select "Run this VirtualBox VM on my local computer" and click Next 
![](https://i.imgur.com/h353qoh.png)
- Select which vm you would like to import and click Finish
![](https://i.imgur.com/sUn7wsG.png) 
- Select the imported vm and click Edit
![](https://i.imgur.com/sAlOkr6.png)
- Under the network tab, check the box to allow GNS3 to use the virtualBox network adaptor
![](https://i.imgur.com/B3SBf1R.png)
- Click OK until you are back to your topology 
- Go to the "All devices" tab, there you will find all of your imported VMs. You can now drag them into the topology.
![](https://i.imgur.com/68H5ftq.png)

### ToDo
- Remote server for one unified topology. The GNS3 vm can be installed on a remote server (Cloud provider or raspberry pi?). Every client can connect to the server through a VPN connection. 

## Resources
Solar-PuTTY videos:
- https://www.youtube.com/watch?v=3utfGQyQOkA
- https://www.youtube.com/watch?v=iuev1Hyc-f4
- https://www.youtube.com/watch?v=mQKbXMIxHSk
- https://www.youtube.com/watch?v=Q2TnxcJa0wI
- https://www.youtube.com/watch?v=shoDldraAsE

GNS3 Remote server: 
- On Azure https://www.youtube.com/watch?v=FfJXcoqTvrs&t=269s
- https://docs.gns3.com/docs/getting-started/installation/remote-server
- https://docs.gns3.com/docs/getting-started/installation/one-server-multiple-clients

Other: 
- [^1] https://www.youtube.com/watch?v=A0DEnMi09LY&list=PLhfrWIlLOoKNFP_e5xcx5e2GDJIgk3ep6&index=2
- [^2] https://github.com/GNS3/gns3-gui/issues/3032 / https://www.reddit.com/r/virtualization/comments/ci7tmv/virtualbox_vm_not_starting_after_installing/
- https://dtechsmag.com/vm-in-gns3-add-virtualbox-server-to-your-network-lab/ 