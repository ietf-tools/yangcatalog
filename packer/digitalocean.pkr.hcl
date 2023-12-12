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
    environment_vars = [
      "FOO=hello world",
    ]
    inline = [
      "echo Installing Redis",
      "sleep 30",
      "sudo apt-get update",
      "sudo apt-get install -y redis-server",
      "echo \"FOO is $FOO\" > example.txt",
    ]
  }
}
      
