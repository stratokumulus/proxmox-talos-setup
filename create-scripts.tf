# This will generate the first Shell script, that will apply the config to the nodes based on their type
resource "local_file" "nodes" {
  content = templatefile("templates/setup.tmpl",
    {
      clustername = local.network.clustername
      masterip    = proxmox_vm_qemu.talos-nodes["master0"].default_ipv4_address
      masters     = [for k, j in local.all_nodes : proxmox_vm_qemu.talos-nodes[k].default_ipv4_address if strcontains(k, "master")]
      workers     = [for k, j in local.all_nodes : proxmox_vm_qemu.talos-nodes[k].default_ipv4_address if strcontains(k, "worker")]
    }
  )
  filename = "files/1st-setup-nodes.sh"
}

# This will generate the second script, that will bootstrap the cluster and create the kubeconfig file
resource "local_file" "cluster" {
  content = templatefile("templates/deploy.tmpl",
    {
      masterip = proxmox_vm_qemu.talos-nodes["master0"].default_ipv4_address
    }
  )
  filename = "files/2nd-deploy-cluster.sh"
}
