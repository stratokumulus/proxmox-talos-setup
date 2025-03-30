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
    }
  }
  worker_offset = length(local.nodes.masters)
  workers = {
    for index, node in local.nodes.workers :
    "worker${index}" => {
      name  = format("tls-wrkr-%d", index)
      cores = node.cores
      ram   = node.ram
    }
  }
  all_nodes = merge(local.masters, local.workers)
}
