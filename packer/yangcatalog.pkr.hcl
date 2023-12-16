packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
    digitalocean = {
      version = ">= 1.0.4"
      source  = "github.com/digitalocean/digitalocean"
    }
  }
}

source "amazon-ebs" "yang" {
  skip_create_ami = true
  region =  "us-east-1"
  source_ami =  "ami-0fc5d935ebf8bc3bc"
  instance_type =  "m6a.xlarge"
  ssh_username =  "ubuntu"
  ami_name =  "yangcatalog-${formatdate("YYYY-MM-DD_hh-mm", timestamp())}"
  shutdown_behavior = "terminate"

  launch_block_device_mappings {
    device_name = "/dev/sda1"
    volume_size = 50
    volume_type = "gp3"
    delete_on_termination = true
  }
}

source "digitalocean" "yang" {
  image        = "ubuntu-22-04-x64"
  region       = "nyc3"
  size         = "s-4vcpu-16gb-amd"
  ssh_username = "root"
  snapshot_name = "yangcatalog-${timestamp()}"
}

build {
  sources = [
    "source.amazon-ebs.yang",
    "source.digitalocean.yang"
  ]

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
    source = "../pt-topology-0.1.0.tgz"
    destination = "/var/yang/pt-topology-0.1.0.tgz"
  }

  provisioner "file" {
    source = "../yumapro-client-21.10-12.deb11.amd64.deb"
    destination = "/var/yang/yumapro-client-21.10-12.deb11.amd64.deb"
  }

  provisioner "shell" {
    execute_command = "sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
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

  provisioner "shell" {
    scripts = [
      "scripts/build.sh"
    ]
  }
}
