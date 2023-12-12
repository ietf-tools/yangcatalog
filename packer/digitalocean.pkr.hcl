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
    inline = "cloud-init status --wait"
  }

  provisioner "shell" {
    scripts = [
      "scripts/base.sh",
      "scripts/docker.sh",
      "scripts/yangcatalog.sh",
      "scripts/cleanup.sh"
    ]
  }
}
