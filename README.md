# Setting up Talos on Proxmox 8.3, using Terraform

I am running Proxmox 8.3 on a Dell R630, with plenty of RAM and CPUs. I decided to check this Talos-thingy, because by trade I'm a IaC kind of guy, and I like to tinker when I can't sleep at night.

I came up with this quick solution to deploy a Talos cluster, and automate its config as much as I can. 

The Terraform code will create 6 nodes, 3 control plane nodes and 3 worker ones. I noticed a tiny bug where, when using DHCP for the nodes, the IP address doesn't survive a reboot (found an issue in the Talos github page that confirms I'm not the only one).

So, for the time being, I'm creating fixed MAC addresses, and reservations in my DHCP server. That works... But in the future, I'll use fully dynamic addresses (both IP and MAC). And maybe VM IDs, and add the nodes in a proxmox pool, so I can find them out easily. FOr the moment, I'm setting VM IDs so the nodes are grouped together ^^ !

The Terraform code will not only create the nodes, but also will generate two scripts : one that will assign a role to each node, and once rebooted, a script to finalise the configuration and download the kubeconfig file. 

Enjoy ... 