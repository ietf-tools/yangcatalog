packer {
  required_plugins {
    digitalocean = {
      version = ">= 1.0.4"
      source  = "github.com/digitalocean/digitalocean"
    }
  }
}

source "digitalocean" "yang" {
  image        = "ubuntu-22-04-x64"
  region       = "nyc3"
  size         = "s-4vcpu-16gb-amd"
  ssh_username = "root"
  snapshot_name = "yangcatalog-snapshot-${timestamp()}"
}

build {
  sources = ["source.digitalocean.yang"]

  provisioner "shell" {
    inline = [
      "cloud-init status --wait",
      "mkdir -p /var/yang"
    ]
  }

  provisioner "file" {
    source = "../confd-8.0.linux.x86_64.installer.bin"
    destination = "/var/yang/confd-8.0.linux.x86_64.installer.bin"
  }

  provisioner "file" {
    source = "../yumapro-client-21.10-12.deb11.amd64.deb"
    destination = "/var/yang/yumapro-client-21.10-12.deb11.amd64.deb"
  }

  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
      "LC_ALL=C",
      "LANG=en_US.UTF-8",
      "LC_CTYPE=en_US.UTF-8"
    ]
    scripts = [
      "scripts/base.sh",
      "scripts/docker.sh",
      "scripts/yangcatalog.sh",
      "scripts/cleanup.sh"
    ]
  }
}
