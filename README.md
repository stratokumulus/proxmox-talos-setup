# Setting up Talos on Proxmox 8.3, using Terraform

I am running Proxmox 8.3 on a Dell R630, with plenty of RAM and CPUs. I decided to check this [Talos-thingy](https://talos.dev), because I like to tinker when I can't sleep at night (and I'm a IaC architect during the day).

I came up with this quick solution to deploy a Talos cluster, and automate its config as much as I can. 

I'm creating a cluster with 6 nodes, all with 4 CPUs and 16GB of RAM. Because I'm not setting the VM ID, they appear everywhere in the list of VMs in Proxmox, so I tag them ("talos") and put them in a pool. 

## The file vars/nodes.yaml

This file contains the description of the nodes. Thanks to my friend Werner for suggesting this format. Much simpler, less cluter in the terraform code. 

Basically, create one list for control plane nodes (under `- master:`) to specify the number of cores and the RAM. Ditto for the worker nodes (under `- worker:`)

The Terraform code will create all nodes, and use DHCP to get them an IP address (funny enough, when using fixed IP addresses, the cluster is up and running in a few seconds ! When using DHCP, it takes about 4 minutes and 30s... DHCP is slow :D ).

## Once it's all booted ...

There are two scripts created in the `files` directory : 1st and 2nd :D Run the first one, see the nodes reboot, and when things are stable (etcd being up in the logs), run the second script. Then export KUBECONFIG=files/kubeconfig, and then wait for the cluster to finish booting. It takes 3-4 minutes before I get from a connection error when using kubectl to a fully provisionned cluster. 

Enjoy ... 