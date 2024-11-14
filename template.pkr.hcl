packer {
  required_plugins {
    proxmox = {
      version = "~> 1"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

source "proxmox-iso" "ubuntu-template" {
  proxmox_url              = "https://10.0.5.101:8006/api2/json"
  insecure_skip_tls_verify = true
  node                     = "pve1"
  vm_name                  = "vagrant"
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
  name    = "vagrant"
  sources = ["source.proxmox-iso.ubuntu-template"]

  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      "sudo rm /etc/ssh/ssh_host_*",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo apt -y autoremove --purge",
      "sudo apt -y clean",
      "sudo apt -y autoclean",
      "sudo cloud-init clean",
      "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
      "sudo rm -f /etc/netplan/00-installer-config.yaml",
      "sudo sync"
    ]
  }

  provisioner "file" {
    source      = "files/99-pve.cfg"
    destination = "/tmp/99-pve.cfg"
  }

  provisioner "shell" {
    inline = ["sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg"]
  }
}
