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
    disk_size    = "10G"
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
  cores          = 4
  memory         = 1024
  http_directory = "config"
  boot_command = [
    "<esc><wait>",
    "<esc><wait>",
    "<enter><wait>",
    "/install/vmlinuz<wait>",
    " initrd=/install/initrd.gz",
    " auto-install/enable=true",
    " debconf/priority=critical",
    " fb=false debconf/frontend=noninteractive ",
    " keyboard-configuration/modelcode=SKIP keyboard-configuration/layout=USA ",
    " keyboard-configuration/variant=USA console-setup/ask_detect=false ",
    " preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg<wait>",
    " -- <enter>"
  ]
  boot_wait                = "2m"
  proxmox_url              = "https://pve1.s1.lan:8006/api2/json"
  node                     = "pve1"
  insecure_skip_tls_verify = true
  ssh_password             = "vagrant"
  ssh_timeout              = "15m"
  ssh_username             = "vagrant"
  template_description     = "Ubuntu 20.04, generated on ${timestamp()}"
  template_name            = "ubuntu-2004"
}

build {
  sources = ["source.proxmox-iso.ubuntu-template"]
}
