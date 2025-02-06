# Setting up Talos on Proxmox 8.3, using Terraform

I am running Proxmox 8.3 on a Dell R630, with plenty of RAM and CPUs. I decided to check this [Talos-thingy](https://talos.dev), because I like to tinker when I can't sleep at night (and I'm a IaC architect during the day).

I came up with this quick solution to deploy a Talos cluster, and automate its config as much as I can. 

## The file vars/nodes.yaml

This file contains the description of the nodes. Thanks to my friend Werner for suggesting (and providing the code !) this format. Much simpler, less cluter in the YAML file. 

Basically, create one list for control plane nodes (under `- master:`) to specify the number of cores and the RAM. Ditto for the worker nodes (under `- worker:`)

The Terraform code will create all nodes, and use DHCP to get them an IP address.

## A note on some bugs I've encountered

At the time of pushing this code to GitHub, there are two bugs that are affecting this deployment : 

- issue #10086 at Talos, where the DHCP request after the initial reboot doesn't add the requested IP address. Which means, the node gets another IP after getting its initial config. Not cool ... The solution I have is to fix the MAC address when createing the VM, and using that MAC address to create a reserved IP address on my DHCP server. Lots of work, but done only once ... 

- a weird issue in either the provider I use (Telmate) or Proxmox itself : if I don't specify the VM ID, only 2 IDs are used, and so Terraform tries to create nodes as per the 3rd one re-using IDs. Which crashes the deployment. The solution : fix the VM IDs.

## Once it's all booted ...

There are two scripts created on the `files` directory : 1st and 2nd :D Run the first one, see the nodes reboot, and when things are stable (etcd being up in the logs), run the second script. Then export KUBECONFIG=files/kubeconfig, and then wait for the cluster to finish booting. It takes 3-4 minutes before I get from a connection error when using kubectl to a fully provisionned cluster. 

Enjoy ... 