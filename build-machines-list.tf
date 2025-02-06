########################################################
# This just builds the list of masters and workers nodes
########################################################
locals {
  nodes   = yamldecode(file("vars/nodes.yaml"))
  network = yamldecode(file("vars/network.yaml"))

  offset        = 210
  master_offset = 0

  masters = {
    for index, node in local.nodes.masters :
    "master${index}" => {
      name  = format("tls-ctrl-%d", index)
      cores = node.cores
      ram   = node.ram
      # The following 2 parameters are a workaround to fix two bugs:
      # - a bug in Talos DHCP use (issue #10086), so I fix the MAC address and make reservations for them in my DHCP server.
      # - a bug in either Telmate provider 3.0.1-rc4 or Proxmox 8.1.1, where deploying VMs reuse the same two VM IDs
      macaddr = format("7A:00:00:00:05:%02d", index)       # Private MAC address. 
      vmid    = local.offset + local.master_offset + index # Can be commented out
    }
  }
  worker_offset = length(local.nodes.masters)
  workers = {
    for index, node in local.nodes.workers :
    "worker${index}" => {
      name  = format("tls-wrkr-%d", index)
      cores = node.cores
      ram   = node.ram
      # The following 2 parameters are a workaround to fix two bugs:
      # - a bug in Talos DHCP use (issue #10086), so I fix the MAC address and make reservations for them in my DHCP server.
      # - a bug in either Telmate provider 3.0.1-rc4 or Proxmox 8.1.1, where deploying VMs reuse the same two VM IDs
      macaddr = format("7A:00:00:00:05:%02d", local.worker_offset + index)
      vmid    = local.offset + local.worker_offset + index # Can be commented out
    }
  }
  all_nodes = merge(local.masters, local.workers)

}
