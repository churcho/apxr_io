data "digitalocean_image" "example1" {
  name = "example-1.0.0"
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
  image  = "${data.digitalocean_image.example1.image}"
  name = "${var.droplet_name}"
  region = "${var.droplet_region}"
  size = "${var.droplet_size}"
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