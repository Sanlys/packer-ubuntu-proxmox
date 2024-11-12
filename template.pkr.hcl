packer {
  required_plugins {
    proxmox = {
      version = "~> 1"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

source "proxmox-iso" "ubuntu-template" {
  disks {
    disk_size    = "5G"
    storage_pool = "local-lvm"
    type         = "scsi"
    format       = "raw"
  }
  boot_iso {
    iso_file = "ceph-iso:iso/ubuntu-24.04.1-live-server-amd64.iso"
  }
  network_adapters {
    bridge = "vmbr0"
    model  = "virtio"
  }
  http_directory = "config"
  boot_command = [
    "<esc><wait>",
    "<esc><wait>",
    "<enter><wait>",
    "/install/vmlinuz<wait>",
    " initrd=/install/initrd.gz",
    " auto-install/enable=true",
    " debconf/priority=critical",
    " preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg<wait>",
    " -- <wait>",
    "<enter><wait>"
  ]
  boot_wait                = "2m"
  node                     = "pve1"
  proxmox_url              = "https://pve1.s1.lan:8006/api2/json"
  insecure_skip_tls_verify = true
  ssh_password             = "packer_example"
  ssh_timeout              = "15m"
  ssh_username             = "root"
  template_description     = "Ubuntu 20.04, generated on ${timestamp()}"
  template_name            = "ubuntu-2004"
}

build {
  sources = ["source.proxmox-iso.ubuntu-template"]
}
