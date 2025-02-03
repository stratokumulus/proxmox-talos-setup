provider "proxmox" {
  pm_api_url  = var.api_url
  pm_user     = var.user
  pm_password = var.passwd
  # Leave to "true" for self-signed certificates
  pm_tls_insecure = "true"
  pm_debug        = true
  pm_timeout      = 300
}

locals {
  vm_settings = merge(flatten([for i in fileset(".", "vars/nodes.yaml") : yamldecode(file(i))["nodes"]])...)
  network     = yamldecode(file("vars/network.yaml"))
  #  db          = yamldecode(file("vars/db.yaml"))
}

resource "proxmox_vm_qemu" "talos-nodes" {
  for_each    = local.vm_settings
  name        = each.key
  vmid        = try(each.value.vmid, null)
  target_node = var.target_host
  boot        = "order=ide2;scsi0;net0" # "c" by default, which renders the coreos35 clone non-bootable. "cdn" is HD, DVD and Network
  agent       = 0
  tags        = "talos,${each.value.type}"
  vm_state    = "started" # start VM by default
  cores       = each.value.cores
  memory      = each.value.ram
  scsihw      = "virtio-scsi-pci"
  bootdisk    = "scsi0"
  hotplug     = 0
  ipconfig0   = "dhcp"
  disks {
    ide {
      ide2 {
        cdrom {
          iso = var.image
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          storage = "vm-data"
          size    = "120G"
        }
      }
    }
  }
  network {
    model   = "virtio"
    bridge  = local.network.bridge
    tag     = local.network.vlan
    macaddr = try(each.value.macaddr, null)
  }
}

resource "local_file" "nodes" {
  content = templatefile("templates/setup.tmpl",
    {
      clustername = local.network.clustername
      masterip    = local.vm_settings.master0.ip
      masters     = [for j in local.vm_settings : j.ip if j.type == "master"]
      workers     = [for j in local.vm_settings : j.ip if j.type == "worker"]
    }
  )
  filename = "files/setup-nodes.sh"
}

resource "local_file" "cluster" {
  content = templatefile("templates/deploy.tmpl",
    {
      masterip = local.vm_settings.master0.ip
    }
  )
  filename = "files/deploy-cluster.sh"
}
