packer {
  required_plugins {
    proxmox = {
      version = "~> 1"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

source "proxmox-iso" "ubuntu-template" {
  proxmox_url              = "https://pve1.s1.lan:8006/api2/json"
  insecure_skip_tls_verify = true
  node                     = "pve1"
  template_name            = "ubuntu-2204"
  template_description     = "Ubuntu 22.04, generated on ${timestamp()}"

  cloud_init              = true
  cloud_init_storage_pool = "local-lvm"

  qemu_agent      = true
  scsi_controller = "virtio-scsi-pci"

  disks {
    disk_size         = "10G"
    storage_pool      = "local-lvm"
    type              = "sata"
    storage_pool_type = "lvm"
    format            = "raw"
  }
  boot_iso {
    iso_file = "ceph-iso:iso/ubuntu-22.04.5-live-server-amd64.iso"
    unmount  = true
  }
  network_adapters {
    bridge = "vmbr0"
    model  = "virtio"
  }

  cores          = 1
  memory         = 2048
  http_directory = "http"
  boot           = "c"
  boot_wait      = "10s"
  boot_command = [
    "<esc><wait>",
    "e<wait>",
    "<down><down><down><end>",
    "<bs><bs><bs><bs><wait>",
    "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
    "<f10><wait>"
  ]

  ssh_username = "packer"
  ssh_password = "packer"
  ssh_timeout  = "15m"
}

build {
  sources = ["source.proxmox-iso.ubuntu-template"]
}
