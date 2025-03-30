provider "proxmox" {
  pm_api_url  = var.api_url
  pm_user     = var.user
  pm_password = var.passwd
  # Leave to "true" for self-signed certificates
  pm_tls_insecure = "true"
  pm_debug        = true
  pm_timeout      = 300
}

resource "proxmox_vm_qemu" "talos-nodes" {
  depends_on  = [proxmox_pool.talospool]
  for_each    = local.all_nodes
  name        = each.value.name
  agent       = 1 # I'm using the QEMU agent enabled image from Talos. Necessary to read the IP address after creation of the VM
  vmid        = try(each.value.vmid, null)
  target_node = var.target_host
  boot        = "order=ide2;scsi0;net0" # "c" by default, which renders the coreos35 clone non-bootable. "cdn" is HD, DVD and Network
  tags        = "talos"
  pool        = var.pool
  vm_state    = "started" # start VM by default
  cores       = each.value.cores
  memory      = each.value.ram
  scsihw      = "virtio-scsi-pci"
  bootdisk    = "scsi0"
  hotplug     = 0
  ipconfig0   = "ip=dhcp"
  skip_ipv6   = true
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
    id      = 0
    model   = "virtio"
    bridge  = local.network.bridge
    tag     = local.network.vlan
    macaddr = try(each.value.macaddr, null) #  I have to fix the MAC address for DHCP reservation, otherwise the node gets a new IP address after a reboot. Apparently a bug in Talos 1.9.2
  }
}

# Took me a while to figure out why this wasn't working : the user/token must have pool.Audit privilege
resource "proxmox_pool" "talospool" {
  poolid  = var.pool
  comment = "Dev Talos Cluster"
}
