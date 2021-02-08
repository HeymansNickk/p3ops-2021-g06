# GNS3 Remote Server Troubleshooting

## General

During the installation of the remote server of GNS3 we had multiple problems:

- GNS3 Remote server can't be installed
- Couldn't connect to the remote server
- Free server isn't powerfull enough
- Can't add local VM's to the remote server
- Even when running the remote server on a powerfull enough pc, the import of virtualbox appliances is not possible
- We don't see the use of a remote server, it's only usefull if everything is running on the cloud.
- Can't drag and drop appliances on MacOS

## Solutions

### GNS3 Remote Server can't be installed

After multiple installations of different tutorials we have got it to work after a while.

### Couldn't connect to the remote server

We tried to connect to the remote server via public ip address. This worked with Nick Heymans' installation but not with Michiel Vanreybrouck or Glenn Delanghe.
After a while and multiple setting changes (enabling/disabling the local/vm server) this worked.

### Free server isn't powerfull enough

In order to run the setup in the cloud, we need to create the virtualboxes on the server itself. This is not possible seeing that every VM takes 2GB of ram (4*2=8Gb of ram). We only have 1GB of RAM available on the free box.

### Can't add local VM's to the remote server

In GNS3 it is not possible to add VM's on the local host to the setup of the remote server. Because of this we are not able replicate the setup on the cloud.

### Running the remote server on a remote pc

Running the virtualboxes on a pc that is powerfull enough, we are still unable to import the virtualboxes into the server running on the pc.

### We don't see the use of a remote server, it's only usefull if everythin is running on the cloud

Seeing as we can't add the virtualboxes from a local host to the server, we should, if we could, run everything on the cloud to import the boxes. Seeing as it's not possible to import the virtualboxes, this isn't possible either.

### Can't drag and drop appliances on MacOS

Sometimes, when GNS3 feels like it, you are not able to drag and drop appliances to the project. The solution to fix this is to uninstall gns3, then reinstall gns3, then hope it works.

## References

[Link1](https://computingforgeeks.com/how-to-install-latest-gns3-network-simulator-on-ubuntu-linux/)
[Link2](https://docs.gns3.com/docs/getting-started/installation/one-server-multiple-clients/)
[Link3](https://www.youtube.com/watch?v=hVPW5ijvNFo&ab_channel=DavidBombal)
[Link4](https://www.howtogeek.com/115116/how-to-configure-ubuntus-built-in-firewall/)

Author: Michiel Vanreybrouck, Nick Heymans, Glenn Delanghe
