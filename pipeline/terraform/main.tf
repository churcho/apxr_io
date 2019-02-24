data "digitalocean_image" "apxr_io" {
  name = "apxr_io-1.0.0"
}

resource "digitalocean_tag" "apxr_io" {
    name = "apxr_io"
}

resource "digitalocean_tag" "env" {
    name = "env:production"
}

resource "digitalocean_tag" "blue" {
    name = "blue"
}

resource "digitalocean_droplet" "axpr_io" {
  image  = "${data.digitalocean_image.apxr_io.image}"
  name = "apxr_io"
  region = "ams3"
  size = "s-1vcpu-2gb"
  monitoring = true
  ipv6 = false
  private_networking = true
  tags               = [
    "${digitalocean_tag.apxr_io.id}",
    "${digitalocean_tag.env.id}",
    "${digitalocean_tag.blue.id}"
  ]
  ssh_keys = [
    "${var.ssh_fingerprint}"
  ]
}